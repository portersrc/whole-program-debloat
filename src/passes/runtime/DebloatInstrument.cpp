
#include "DebloatInstrument.hpp"
#include "../common/backslice.hpp"
#include "../common/util.hpp"







typedef struct{
    unsigned int max_num_args;
    unsigned int num_calls_not_in_loops;
    unsigned int num_calls_in_loops;
    unsigned int num_loops_no_preheader;
}dp_stats_t;








namespace {

    template<typename Out>
    void split(const string &s, char delim, Out result)
    {
        stringstream ss(s);
        string item;
        while(getline(ss, item, delim)){
            *(result++) = item;
        }
    }

    vector<string> split(const string &s, char delim)
    {
        vector<string> elems;
        split(s, delim, back_inserter(elems));
        return elems;
    }

    struct DebloatInstrument : public FunctionPass {

      public:
        static char ID;
        LoopInfo *LI;

        DebloatInstrument() : FunctionPass(ID) {}

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
        Function *debrt_monitor_func;
        Function *debrt_protect_func;
        Function *debrt_return_func;
        Function *debrt_return_func_intrinsic;
        Function *debrt_protect_loop_func;
        Function *debrt_loop_end_func;
        map<CallInst *, unsigned int> call_inst_to_id;
        std::map<std::string, unsigned int> func_name_to_id;
        unsigned int call_inst_count;
        unsigned int func_count;
        dp_stats_t stats;
        set<Loop *> instrumented_loops;
        set<Instruction *> jump_phi_nodes;
        Type *int32Ty;
        Type *int64Ty;

        bool call_inst_is_in_loop(Instruction *call_inst);

        void init_debrt_funcs(Module &);

        void dump_stats(void);
        void read_func_name_to_id(void);

        void instrument_callsite(Instruction *call_inst,
                                 unsigned int callsite_id,
                                 unsigned int called_func_id,
                                 set<Value *> func_arguments_set);
        void instrument_return(Instruction *ret_inst, unsigned int func_id);
        void instrument_outside_loop_basic(Instruction *call_inst,
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


bool DebloatInstrument::doInitialization(Module &M)
{
    call_inst_count = 0;
    func_count = 0;

    int32Ty = IntegerType::getInt32Ty(M.getContext());
    int64Ty = IntegerType::getInt64Ty(M.getContext());

    init_debrt_funcs(M);

    stats.max_num_args = 0;
    stats.num_calls_not_in_loops = 0;
    stats.num_calls_in_loops = 0;
    stats.num_loops_no_preheader = 0;

    read_func_name_to_id();

    return false;
}


void DebloatInstrument::read_func_name_to_id(void)
{
    string line;
    ifstream ifs;
    vector<string> elems;

    ifs.open("debprof_func_name_to_id.txt");
    if(!ifs.is_open()) {
        perror("Error opening func name to id file");
        exit(EXIT_FAILURE);
    }

    while(getline(ifs, line)){
        elems = split(line, ' ');
        func_name_to_id[elems[0]] = atoi(elems[1].c_str());
    }
}


bool DebloatInstrument::doFinalization(Module &M)
{
    return false;
}




bool DebloatInstrument::call_inst_is_in_loop(Instruction *call_inst)
{
    if(LI && LI->getLoopFor(call_inst->getParent())) {
        LLVM_DEBUG(dbgs() << "i see this call_inst inside a loop\n");
        stats.num_calls_in_loops++;
        return true;
    }
    stats.num_calls_not_in_loops++;
    return false;
}


bool DebloatInstrument::runOnFunction(Function &F)
{
    unsigned int num_args;
    bool can_instrument;
    string func_name;
    CallInst *call_inst;
    ReturnInst *ret_inst;

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
                if(can_ignore_called_func(called_func, call_inst)){
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
                    //if(called_func_name == "debrt_monitor"){
                    if(called_func_name == "debrt_protect"){
                        continue;
                    }
                    LLVM_DEBUG(dbgs()<<"assert 0 called_func_name: "<<called_func_name<<"\n");
                    assert(0); // this is instrumentation... func name should already exist.
                    //func_name_to_id[called_func_name] = func_count++;
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

            ret_inst = dyn_cast<ReturnInst>(&*it_inst);
            if(ret_inst){
                instrument_return(ret_inst, func_name_to_id[func_name]);
            }
        }
    }
    return true;
}

void DebloatInstrument::instrument_callsite(Instruction *call_inst,
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
        //instrument_outside_loop_basic(call_inst,
        //                              callsite_id,
        //                              called_func_id,
        //                              func_arguments_set);
    }
}


void DebloatInstrument::instrument_return(Instruction *inst_before,
                                          unsigned int func_id)
{
    Value *retinstrIntrinsic;
    Module *m;
    Type *ptr_i8;
    std::vector<Value *> ArgsVIntrinsic;

    m = inst_before->getModule();
    ptr_i8 = PointerType::get(Type::getInt8Ty(m->getContext()), 0);

    IRBuilder<> builderIntrinsic(inst_before);
    ArgsVIntrinsic.push_back(llvm::ConstantInt::get(int32Ty, 0, false));
    LLVM_DEBUG(dbgs() << "Instrumenting ret-inst::" << inst_before << "\n");
    retinstrIntrinsic =
      builderIntrinsic.CreateCall(debrt_return_func_intrinsic, ArgsVIntrinsic);
      //builderIntrinsic.CreateCall(debrt_return_func_intrinsic);
    LLVM_DEBUG(dbgs() << "retinstrIntrinsic::" << *retinstrIntrinsic << "\n");


    IRBuilder<> builder(inst_before);
    std::vector<Value *> ArgsV;
    LLVM_DEBUG(dbgs() << "retinstrIntrinsic type: " << *(retinstrIntrinsic->getType()) << "\n");
    if(retinstrIntrinsic->getType()->isPointerTy()){
        LLVM_DEBUG(dbgs() << " that type is a pointer\n");
    }
    Value *castedArg = nullptr;
    castedArg = builder.CreatePtrToInt(retinstrIntrinsic, int64Ty);
    ArgsV.push_back(castedArg);
    //ArgsV.push_back(
    //  llvm::ConstantInt::get(
    //    int64Ty,
    //    builder.CreatePtrToInt(retinstrIntrinsic, int64Ty),
    //    false
    //  )
    //);
    //ArgsV.push_back(
    //  llvm::ConstantInt::get(
    //    ptr_i8,
    //    builder.CreatePointerCast(
    //      retinstrIntrinsic,
    //      ptr_i8),
    //    false
    //  )
    //);
    //ArgsV.push_back(
    //  llvm::ConstantInt::get(
    //    ptr_i8,
    //    builder.CreateIntCast(
    //      retinstrIntrinsic,
    //      int64Ty,
    //      false), //isSigned?
    //    false
    //  )
    //);
    //ArgsV.push_back(llvm::ConstantInt::get(ptr_i8, retinstrIntrinsic, false));
    //ArgsV.push_back(llvm::ConstantInt::get(ptr_i8, 0, false));
    LLVM_DEBUG(dbgs() << "Instrumenting ret-inst::" << inst_before << "\n");
    CallInst *retinstr = builder.CreateCall(debrt_return_func, ArgsV);
    LLVM_DEBUG(dbgs() << "retinstr::" << *retinstr << "\n");




    // This is what we used to use:
    //IRBuilder<> builder(inst_before);
    //std::vector<Value *> ArgsV;
    //ArgsV.push_back(llvm::ConstantInt::get(int32Ty, func_id, false));
    //LLVM_DEBUG(dbgs() << "Instrumenting ret-inst::" << inst_before << "\n");
    //Value *retinstr = builder.CreateCall(debrt_return_func, ArgsV);
    //LLVM_DEBUG(dbgs() << "retinstr::" << *retinstr << "\n");




}








void DebloatInstrument::create_the_call(Instruction *inst_before,
                                     unsigned int callsite_id,
                                     unsigned int called_func_id,
                                     set<Value *> func_arguments_set,
                                     bool do_backslice)
{

    IRBuilder<> builder(inst_before);
    std::vector<Value *> ArgsV;


    LLVM_DEBUG(dbgs() << "Instrumented for callins::" << inst_before
               << " callsite::"  << callsite_id << "\n");


    // We have to instrument a call to debrt_monitor/protect. To do that, we need
    // to build a list of arguments to pass to it. The first argument
    // to debrt_monitor/protect is the number of variadic args to follow.
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
    // to debrt_monitor/protect. Subtract 1 to get the number of variadic args,
    // and update argument 0 accordingly.
    unsigned int num_variadic_args = ArgsV.size() - 1;
    ArgsV[0] = llvm::ConstantInt::get(int32Ty, num_variadic_args, false);

    // Track the max number of args that debrt_monitor/protect is going to write
    // to file.
    if(num_variadic_args > stats.max_num_args){
        stats.max_num_args = num_variadic_args;
    }

    // Create the call to debrt_monitor/protect
    //Value *callinstr = builder.CreateCall(debrt_monitor_func, ArgsV);
    Value *callinstr = builder.CreateCall(debrt_protect_func, ArgsV);
    LLVM_DEBUG(dbgs() << "callinstr::" << *callinstr << "\n");


}


void DebloatInstrument::instrument_outside_loop_basic(Instruction *call_inst,
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
            //Value *callinstr = builder.CreateCall(debrt_monitor_func, ArgsV);
            Value *callinstr = builder.CreateCall(debrt_protect_func, ArgsV);
            LLVM_DEBUG(dbgs() << "callinstr(loop)::" << *callinstr << "\n");
        }
    }else{
        // FIXME see LLVM doxygen on getLoopPreheader. The fix is to walk
        // incoming edges to the first BB of the loop
        stats.num_loops_no_preheader++;
    }

}




void DebloatInstrument::init_debrt_funcs(Module &M)
{
    Type *ptr_i8;
    ptr_i8 = PointerType::get(Type::getInt8Ty(M.getContext()), 0);

    Type *ArgTypes[]    = { int32Ty };
    Type *ArgTypes64[]  = { int64Ty };
    Type *ArgTypesPtr[] = { ptr_i8 };

    //debrt_monitor_func =
    //  Function::Create(FunctionType::get(int32Ty, ArgTypes, true),
    //                   Function::ExternalLinkage,
    //                   "debrt_monitor",
    //                   M);

    debrt_protect_func =
      Function::Create(FunctionType::get(int32Ty, ArgTypes, true),
                       Function::ExternalLinkage,
                       "debrt_protect",
                       M);
    debrt_return_func =
      //Function::Create(FunctionType::get(int32Ty, ArgTypes, true),
      //Function::Create(FunctionType::get(int32Ty, ArgTypesPtr, true),
      Function::Create(FunctionType::get(int32Ty, ArgTypes64, true),
                       Function::ExternalLinkage,
                       "debrt_return",
                       M);

    //Function *func = Function::Create(func_type, GlobalValue::ExternalLinkage, "llvm.addressofreturnaddress", F->getParent());


    ////llvm::Type *ArgTypes[] = { ptr_i8 };
    //llvm::Type *ArgTypes[] = { int32Ty };

    //f = dyn_cast<Function>(
    //  m->getOrInsertFunction(
    //    "llvm.addressofreturnaddress",
    //    FunctionType::get(
    //      //int32Ty, ArgTypes, false /*this is var arg func type*/
    //      ptr_i8, ArgTypes, false /*this is var arg func type*/
    //    )
    //  )
    //);

    //debrt_return_func_intrinsic =
    //  //Function::Create(FunctionType::get(ptr_i8, ArgTypes, false),
    //  //Function::Create(FunctionType::get(ptr_i8, NULL, false),
    //  //Function::Create(FunctionType::get(ptr_i8, ArgTypesEmpty, false),
    //  Function::Create(FunctionType::get(ptr_i8, false),
    //                   Function::ExternalLinkage,
    //                   //"llvm.addressofreturnaddress",
    //                   "llvm.addressofreturnaddress.p0i8",
    //                   &M);
    debrt_return_func_intrinsic =
      //Function::Create(FunctionType::get(ptr_i8, ArgTypes, false),
      //Function::Create(FunctionType::get(ptr_i8, NULL, false),
      //Function::Create(FunctionType::get(ptr_i8, ArgTypesEmpty, false),
      Function::Create(FunctionType::get(ptr_i8, ArgTypes, false),
                       Function::ExternalLinkage,
                       //"llvm.addressofreturnaddress",
                       //"llvm.addressofreturnaddress.p0i8",
                       "llvm.returnaddress",
                       &M);

    debrt_protect_loop_func =
      Function::Create(FunctionType::get(int32Ty, ArgTypes, true),
                       Function::ExternalLinkage,
                       "debrt_protect_loop",
                       M);

    debrt_loop_end_func = 
      Function::Create(FunctionType::get(int32Ty, false),
                       Function::ExternalLinkage,
                       "debrt_loop_end",
                       &M);

}




char DebloatInstrument::ID = 0;
static RegisterPass<DebloatInstrument>
Y("DebloatInstrument", "Add instrumentation support for debloating");
