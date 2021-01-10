
#include "DebloatProfile.hpp"
#include "backslice.hpp"
#include "util.hpp"




const int LOOP_BASIC = 1;




typedef struct{
    unsigned int max_num_args;
    unsigned int num_calls_not_in_loops;
    unsigned int num_calls_in_loops;
    unsigned int num_loops_no_preheader;
}dp_stats_t;



namespace {

    struct DebloatProfile : public FunctionPass {

      public:
        static char ID;
        LoopInfo *LI;

        DebloatProfile() : FunctionPass(ID) {}

        bool doInitialization(Module &) override;
        bool runOnFunction(Function &) override;
        bool doFinalization(Module &) override;

        void getAnalysisUsage(AnalysisUsage &au) const override
        {
            au.addRequired<PostDominatorTreeWrapperPass>();
            au.addRequired<LoopInfoWrapperPass>();
            au.setPreservesCFG();
            au.addPreserved<GlobalsAAWrapperPass>();
        }

      private:
        Function *debprof_print_args_func;
        map<CallInst *, unsigned int> call_inst_to_id;
        std::map<std::string, unsigned int> func_name_to_id;
        unsigned int call_inst_count;
        unsigned int func_count;
        dp_stats_t stats;
        set<Loop *> instrumented_loops;
        set<Instruction *> jump_phi_nodes;
        Type *int32Ty;

        bool call_inst_is_in_loop(Instruction *call_inst);
        bool can_ignore_called_func(Function *, CallInst *);
        void init_debprof_print_func(Module &);
        void dump_stats(void);
        void dump_func_name_to_id(void);

        void instrument_callsite(Instruction *call_inst,
                                 unsigned int callsite_id,
                                 unsigned int called_func_id,
                                 set<Value *> func_arguments_set);
        void instrument_outside_loop_basic(Instruction *call_inst,
                                           unsigned int callsite_id,
                                           unsigned int called_func_id,
                                           set<Value *> func_arguments_set);
        void instrument_outside_loop_avail_args(Instruction *call_inst,
                                                unsigned int callsite_id,
                                                unsigned int called_func_id,
                                                set<Value *> func_arguments_set);
        void create_the_call(Instruction *inst_before,
                             unsigned int callsite_id,
                             unsigned int called_func_id,
                             set<Value *> func_arguments_set,
                             bool do_backslice);
    };
}


bool DebloatProfile::doInitialization(Module &M)
{
    call_inst_count = 0;
    func_count = 0;

    int32Ty = IntegerType::getInt32Ty(M.getContext());

    init_debprof_print_func(M);
    stats.max_num_args = 0;
    stats.num_calls_not_in_loops = 0;
    stats.num_calls_in_loops = 0;
    stats.num_loops_no_preheader = 0;
    return false;
}

bool DebloatProfile::doFinalization(Module &M)
{
    dump_stats();
    dump_func_name_to_id();
    return false;
}


void DebloatProfile::dump_stats(void)
{
    FILE *fp = fopen("debprof_pass_stats.txt", "w");
    fprintf(fp, "max_num_args: %u\n", stats.max_num_args);
    fprintf(fp, "num_calls_in_loops: %u\n", stats.num_calls_in_loops);
    fprintf(fp, "num_calls_not_in_loops: %u\n", stats.num_calls_not_in_loops);
    fprintf(fp, "num_loops_no_preheader: %u\n", stats.num_loops_no_preheader);
    fclose(fp);
}


void DebloatProfile::dump_func_name_to_id(void)
{
    FILE *fp = fopen("debprof_func_name_to_id.txt", "w");
    for(auto it = func_name_to_id.begin(); it != func_name_to_id.end(); it++){
        fprintf(fp, "%s %u\n", it->first.c_str(), it->second);
    }
    fclose(fp);
}


bool DebloatProfile::call_inst_is_in_loop(Instruction *call_inst)
{
    if(LI && LI->getLoopFor(call_inst->getParent())) {
        LLVM_DEBUG(dbgs() << "i see this call_inst inside a loop\n");
        stats.num_calls_in_loops++;
        return true;
    }
    stats.num_calls_not_in_loops++;
    return false;
}


bool DebloatProfile::can_ignore_called_func(Function *called_func, CallInst *call_inst)
{
    if(called_func == NULL){
        LLVM_DEBUG(dbgs()<<"called_func is NULL\n");
        return true;;
    }
    if(called_func->isIntrinsic()){
        LLVM_DEBUG(dbgs()<<"called_func isIntrinsic\n");
        return true;;
    }
    if(!called_func->hasName()){
        LLVM_DEBUG(dbgs()<<"called_func !hasName\n");
        return true;;
    }
    if(call_inst->getDereferenceableBytes(0)){
        LLVM_DEBUG(dbgs()<<"Skipping derefereceable bytes: "<<*call_inst<<"\n");
        return true;;
    }
    std::string callInstrString;
    llvm::raw_string_ostream callrso(callInstrString);
    call_inst->print(callrso);
    std::string toFindin = callrso.str();
    std::string ignoreclassStr("%class.");
    if(toFindin.find(ignoreclassStr) != std::string::npos){
        LLVM_DEBUG(dbgs()<<"Skipping ignoreclass: "<<*call_inst<<"\n");
        return true;;
    }
    return false;
}


bool DebloatProfile::runOnFunction(Function &F)
{
    unsigned int num_args;
    bool can_instrument;
    string func_name;
    CallInst *call_inst;

    func_name = getDemangledName(F);
    if(func_name == "main"){
        LLVM_DEBUG(dbgs() << "FOUND MAIN\n");
    }else{
        LLVM_DEBUG(dbgs() << "NOT MAIN: " << func_name << "\n");
    }
    LI  = &getAnalysis<LoopInfoWrapperPass>().getLoopInfo();

    for(Function::iterator it_bb = F.begin();
        it_bb != F.end();
        ++it_bb){

        BasicBlock *bb = &*it_bb;
        for(BasicBlock::iterator it_inst = bb->begin();
            it_inst != bb->end();
            ++it_inst){

            if(dyn_cast<InvokeInst>(&*it_inst)){
                continue;
            }

            call_inst = dyn_cast<CallInst>(&*it_inst);
            if(call_inst){
                Function *called_func = call_inst->getCalledFunction();
                if(DebloatProfile::can_ignore_called_func(called_func, call_inst)){
                    continue;
                }

                std::string called_func_name = called_func->getName().str();
                LLVM_DEBUG(dbgs()<<"called_func_name: "<<called_func_name<<"\n");

                //LLVM_DEBUG(dbgs()<<"\n callinst:"<<*call_inst);
                //LLVM_DEBUG(dbgs()<<"\n called func:"<<called_func->getName());
                //LLVM_DEBUG(dbgs()<<"\n does not throw:"<<call_inst->doesNotThrow());
                //LLVM_DEBUG(dbgs()<<"\n does not throw:"<<called_func->doesNotThrow());
                //LLVM_DEBUG(dbgs()<<"\n get getDereferenceableBytes:"<<call_inst->getDereferenceableBytes(0));

                if(call_inst_to_id.find(call_inst) == call_inst_to_id.end()){
                    call_inst_to_id[call_inst] = call_inst_count++;
                    LLVM_DEBUG(dbgs() << "Hit init\n");
                }
                //LLVM_DEBUG(dbgs() <<"\ninstrument_profile call_inst_count:"<<call_inst_count);
                //LLVM_DEBUG(dbgs() << " CallPredictionTrain: got call instr "<<*call_inst<<"\n");
                if(func_name_to_id.find(called_func_name) == func_name_to_id.end()){
                    func_name_to_id[called_func_name] = func_count++;
                }
                //LLVM_DEBUG(dbgs()<<"with arguments ::\n" );

                num_args = call_inst->getNumArgOperands();
                LLVM_DEBUG(dbgs()
                  << "\n#_CALL_instrument:funcID:" << func_name_to_id[called_func_name]
                  << ":call_inst_count:" << call_inst_to_id[call_inst]<<":"
                  << "num_args:" << num_args << "\n");

                set<Value*> func_arguments_set;
                can_instrument = true;

                for(unsigned int i = 0 ; i < num_args; i++){
                    Value *argV = call_inst->getArgOperand(i);
                    std::string prnt_type;
                    llvm::raw_string_ostream rso(prnt_type);
                    argV->getType()->print(rso);
                    LLVM_DEBUG(dbgs() << "argument:: " << i << " = " << *argV
                               << " of type::" << rso.str() << "\n");
                    if(dyn_cast<InvokeInst>(argV)){
                        can_instrument = false;
                        LLVM_DEBUG(dbgs() << "IS invoke instr should ignore: "
                                   << *argV);
                        break;
                    }
                    if(Instruction *argI = dyn_cast<Instruction>(argV)){
                        if(auto *c = dyn_cast<CallInst>(argI)){
                            if(c->getDereferenceableBytes(0)){
                                can_instrument = false;
                                LLVM_DEBUG(dbgs()
                                           << "IS invoke instr should ignore: "
                                           << *argV);
                                break;
                            }
                        }

                        //SmallPtrSet<BasicBlock *, 16> needRDFofBBs;
                        //get_parent_PHI_def_for(argI, needRDFofBBs);

                        // Now the needrdf is set, so get the rdfs and then
                        // instrument them, before moving on to next function call
                        //LLVM_DEBUG(dbgs() << "argument::" << *argI);
                        if(dyn_cast<Instruction>(argV)
                        && (argV->getType()->isIntegerTy()
                           || argV->getType()->isFloatTy()
                           || argV->getType()->isDoubleTy()
                           || argV->getType()->isPointerTy())){
                            LLVM_DEBUG(dbgs() << "valid type argument::" << *argI << "\n");
                            func_arguments_set.insert(argV);
                        }else{
                            LLVM_DEBUG(dbgs() << "wtf 1\n");
                        }
                        //SmallVector<BasicBlock *, 32> RDFBlocks;
                        //PostDominatorTree &PDT = getAnalysis<PostDominatorTreeWrapperPass>().getPostDomTree();
                        //computeControlDependence(PDT, needRDFofBBs, RDFBlocks);
                        //LLVM_DEBUG(dbgs()<<"Calling rdf instrument::"<<RDFBlocks.size());
                        //std::string rdf_info_str = instrumentRDF(RDFBlocks, call_inst_to_id[call_inst], i+1 );
                    }else{
                        LLVM_DEBUG(dbgs() << "wtf 2z\n");
                        if((argV->getType()->isIntegerTy()
                         || argV->getType()->isFloatTy()
                         || argV->getType()->isDoubleTy()
                         || argV->getType()->isPointerTy())){
                            LLVM_DEBUG(dbgs() << "valid type argument\n");
                            func_arguments_set.insert(argV);
                        }
                    }
                }
                if(can_instrument){
                    instrument_callsite(call_inst,
                                        call_inst_to_id[call_inst],
                                        func_name_to_id[called_func_name],
                                        func_arguments_set);
                }
            }
        }
    }
    return true;
}

void DebloatProfile::instrument_callsite(Instruction *call_inst,
                                        unsigned int callsite_id,
                                        unsigned int called_func_id,
                                        set<Value *> func_arguments_set)
{

    if(!call_inst_is_in_loop(call_inst)){
        create_the_call(call_inst,
                        callsite_id,
                        called_func_id,
                        func_arguments_set,
                        false);
    }else{
        if(LOOP_BASIC){
            instrument_outside_loop_basic(call_inst,
                                          callsite_id,
                                          called_func_id,
                                          func_arguments_set);
        }else{
            instrument_outside_loop_avail_args(call_inst,
                                               callsite_id,
                                               called_func_id,
                                               func_arguments_set);
        }
    }
}








void DebloatProfile::create_the_call(Instruction *inst_before,
                                     unsigned int callsite_id,
                                     unsigned int called_func_id,
                                     set<Value *> func_arguments_set,
                                     bool do_backslice)
{

    IRBuilder<> builder(inst_before);
    std::vector<Value *> ArgsV;


    LLVM_DEBUG(dbgs() << "Instrumented for callins::" << inst_before
               << " callsite::"  << callsite_id << "\n");


    // We have to instrument a call to debprof_print_args. To do that, we need
    // to build a list of arguments to pass to it. The first argument
    // to debprof_print_args is the number of variadic args to follow.
    // But we can't just use func_arguments_set.size() to help us here,
    // because we might ignore some arguments. So, push a 0 into the list
    // as a placeholder. We'll update it after we finish adding the other
    // arguments.
    ArgsV.push_back(llvm::ConstantInt::get(int32Ty, 0, false));

    // The next two arguments are always the callsite_id, followed by the
    // called_func_id.
    ArgsV.push_back(llvm::ConstantInt::get(int32Ty, callsite_id, false));
    ArgsV.push_back(llvm::ConstantInt::get(int32Ty, called_func_id, false));


    // Now push the args that were passed at the callsite
    for(Value *funcArg : func_arguments_set){
        LLVM_DEBUG(dbgs() << "checking funcArg\n");
        Value *castedArg = nullptr;
        if(funcArg != NULL){
            if (funcArg->getType()->isFloatTy() || funcArg->getType()->isDoubleTy()){
                LLVM_DEBUG(dbgs() << "float or double\n");
                castedArg = builder.CreateFPToSI(funcArg, int32Ty);
            }else if(funcArg->getType()->isIntegerTy()){
                LLVM_DEBUG(dbgs() << "integer\n");
                castedArg = builder.CreateIntCast(funcArg, int32Ty, true);
            }else if(funcArg->getType()->isPointerTy()){
                LLVM_DEBUG(dbgs() << "pointer\n");
                castedArg = builder.CreatePtrToInt(funcArg, int32Ty);
            }

            if(castedArg == nullptr){
                continue;
            }
            Instruction *backslice_me = dyn_cast<Instruction>(castedArg);
            if(do_backslice && backslice_me){
                backslice(backslice_me, jump_phi_nodes);
                // works, but it dumps the ptr, not the pointed-to value
                //ArgsV.push_back(backslice_me->getOperand(0));

                // fails at runtime
                //ArgsV.push_back(builder.CreateIntCast(backslice_me->getOperand(0), int32Ty, true));
                // not sure what this is even doing. behaves like the naive ptr case
                //ArgsV.push_back(builder.CreatePtrToInt(backslice_me->getOperand(0), int32Ty));

                ArgsV.push_back(builder.CreateLoad(int32Ty, backslice_me->getOperand(0)));

                LLVM_DEBUG(dbgs() << "pushing::" << *backslice_me->getOperand(0) << "\n");
                LLVM_DEBUG(dbgs() << "was type:" << *backslice_me->getOperand(0)->getType() << "\n");
                //LLVM_DEBUG(dbgs() << "was type:" << *(*backslice_me->getOperand(0)).getType() << "\n");
            }else{
                ArgsV.push_back(castedArg);
                LLVM_DEBUG(dbgs() << "pushing::" << *castedArg << "\n");
            }
        }
    }
    // The size of ArgsV is equal to the final number of args we're passing
    // to debprof_print_args. Subtract 1 to get the number of variadic args,
    // and update argument 0 accordingly.
    unsigned int num_variadic_args = ArgsV.size() - 1;
    LLVM_DEBUG(dbgs() << "num_variadic_args::" << num_variadic_args << "\n");
    ArgsV[0] = llvm::ConstantInt::get(int32Ty, num_variadic_args, false);

    // Track the max number of args that debprof_print_args is going to write
    // to file.
    if(num_variadic_args > stats.max_num_args){
        stats.max_num_args = num_variadic_args;
    }

    // Create the call to debprof_print_args
    LLVM_DEBUG(dbgs() << "invoking CreateCall\n");
    Value *callinstr = builder.CreateCall(debprof_print_args_func, ArgsV);
    LLVM_DEBUG(dbgs() << "callinstr::" << *callinstr << "\n");


}


void DebloatProfile::instrument_outside_loop_avail_args(Instruction *call_inst,
                                                        unsigned int callsite_id,
                                                        unsigned int called_func_id,
                                                        set<Value *> func_arguments_set)
{
    Loop *L;
    Instruction *inst_before;
    BasicBlock *preHeaderBB;

    L = LI->getLoopFor(call_inst->getParent());
    preHeaderBB = L->getLoopPreheader();
    if(preHeaderBB){
        // if we have not yet instrumented this loop...
        if(instrumented_loops.count(L) == 0){
            instrumented_loops.insert(L);
            inst_before = preHeaderBB->getTerminator();
            create_the_call(inst_before, callsite_id, called_func_id, func_arguments_set, true);
        }
    }else{
        // FIXME see LLVM doxygen on getLoopPreheader. The fix is to walk
        // incoming edges to the first BB of the loop
        stats.num_loops_no_preheader++;
    }
}


void DebloatProfile::instrument_outside_loop_basic(Instruction *call_inst,
                                                   unsigned int callsite_id,
                                                   unsigned int called_func_id,
                                                   set<Value *> func_arguments_set)
{
    Loop *L;
    Instruction *inst_before;
    BasicBlock *preHeaderBB;

    L = LI->getLoopFor(call_inst->getParent());
    preHeaderBB = L->getLoopPreheader();
    if(preHeaderBB){
        if(instrumented_loops.count(L) == 0){
            instrumented_loops.insert(L);
            inst_before = preHeaderBB->getTerminator();

            // FIXME for now, instrument just the callsite_id and the
            // called_func_id
            IRBuilder<> builder(inst_before);
            std::vector<Value *> ArgsV;
            ArgsV.push_back(llvm::ConstantInt::get(int32Ty, 2, false));
            ArgsV.push_back(llvm::ConstantInt::get(int32Ty, callsite_id, false));
            ArgsV.push_back(llvm::ConstantInt::get(int32Ty, called_func_id, false));
            Value *callinstr = builder.CreateCall(debprof_print_args_func, ArgsV);
            LLVM_DEBUG(dbgs() << "callinstr(loop)::" << *callinstr << "\n");
        }
    }else{
        // FIXME see LLVM doxygen on getLoopPreheader. The fix is to walk
        // incoming edges to the first BB of the loop
        stats.num_loops_no_preheader++;
    }

}




void DebloatProfile::init_debprof_print_func(Module &M)
{
    Type *ArgTypes[] = { int32Ty  };
    string custom_instr_func_name("debprof_print_args");

    debprof_print_args_func =
      Function::Create(FunctionType::get(int32Ty, ArgTypes, true),
                       Function::ExternalLinkage,
                       "debprof_print_args",
                       M);


}




char DebloatProfile::ID = 0;
static RegisterPass<DebloatProfile>
Y("DebloatProfile", "Add profiling support for debloating");
