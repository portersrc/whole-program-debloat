#include "util.hpp"


string getDemangledName(const Function &F)
{
    ItaniumPartialDemangler IPD;
    string name = F.getName().str();
    if(IPD.partialDemangle(name.c_str())){
        return name;
    }
    if(IPD.isFunction()){
        return IPD.getFunctionBaseName(nullptr, nullptr);
    }
    return IPD.finishDemangle(nullptr, nullptr);
}


bool can_ignore_called_func(Function *called_func,
                            CallInst *call_inst,
                            unordered_set<Function *> &app_funcs)
{
    if(called_func == NULL){
        LLVM_DEBUG(dbgs()<<"called_func is NULL\n");
        return true;
    }
    if(called_func->isIntrinsic()){
        LLVM_DEBUG(dbgs()<<"called_func isIntrinsic\n");
        return true;
    }
    if(!called_func->hasName()){
        LLVM_DEBUG(dbgs()<<"called_func !hasName\n");
        return true;
    }
    if(call_inst->getDereferenceableBytes(0)){
        LLVM_DEBUG(dbgs()<<"Skipping derefereceable bytes: "<<*call_inst<<"\n");
        return true;
    }
    if(app_funcs.find(called_func) == app_funcs.end()){
        return true;
    }
    string callInstrString;
    raw_string_ostream callrso(callInstrString);
    call_inst->print(callrso);
    string toFindin = callrso.str();
    string ignoreclassStr("%class.");
    if(toFindin.find(ignoreclassStr) != string::npos){
        LLVM_DEBUG(dbgs()<<"Skipping ignoreclass: "<<*call_inst<<"\n");
        return true;
    }
    return false;
}


bool call_inst_is_in_loop(Instruction *call_inst, LoopInfo *LI, deb_stats_t *stats)
{
    if(LI && LI->getLoopFor(call_inst->getParent())) {
        LLVM_DEBUG(dbgs() << "i see this call_inst inside a loop\n");
        stats->num_calls_in_loops++;
        return true;
    }
    stats->num_calls_not_in_loops++;
    return false;
}


void instrument_callsite(Instruction *call_inst,
                         unsigned int callsite_id,
                         unsigned int called_func_id,
                         set<Value *> func_arguments_set,
                         Function *debloat_func,
                         set<Instruction *> &jump_phi_nodes,
                         deb_stats_t *stats,
                         LoopInfo *LI,
                         map<Loop *, set<int> *> &loop_to_func_ids)
{
    if(!call_inst_is_in_loop(call_inst, LI, stats)){
        create_the_call(call_inst,
                        callsite_id,
                        called_func_id,
                        func_arguments_set,
                        false,
                        debloat_func,
                        jump_phi_nodes,
                        stats);
    }else{
        instrument_outside_loop_basic(call_inst,
                                      callsite_id,
                                      called_func_id,
                                      func_arguments_set,
                                      LI,
                                      debloat_func,
                                      stats,
                                      loop_to_func_ids);
    }
}


void create_the_call(Instruction *inst_before,
                     unsigned int callsite_id,
                     unsigned int called_func_id,
                     set<Value *> func_arguments_set,
                     bool do_backslice,
                     Function *debloat_func,
                     set<Instruction *> &jump_phi_nodes,
                     deb_stats_t *stats)
{

    IRBuilder<> builder(inst_before);
    vector<Value *> ArgsV;
    Type *int32Ty;
    Module *m;

    m = inst_before->getModule();
    int32Ty = IntegerType::getInt32Ty(m->getContext());

    LLVM_DEBUG(dbgs() << "Instrumented for callins::" << inst_before
               << " callsite::"  << callsite_id << "\n");


    // We have to instrument a call to our debloat lib. To do that, we need
    // to build a list of arguments to pass to it. The first argument
    // to our debloat lib is the number of variadic args to follow.
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
    // to our debloat lib. Subtract 1 to get the number of variadic args,
    // and update argument 0 accordingly.
    unsigned int num_variadic_args = ArgsV.size() - 1;
    LLVM_DEBUG(dbgs() << "num_variadic_args::" << num_variadic_args << "\n");
    ArgsV[0] = llvm::ConstantInt::get(int32Ty, num_variadic_args, false);

    // Track the max number of args that our debloat lib is going to write
    // to file.
    if(num_variadic_args > stats->max_num_args){
        stats->max_num_args = num_variadic_args;
    }

    // Create the call to our debloat lib
    Value *callinstr = builder.CreateCall(debloat_func, ArgsV);
    LLVM_DEBUG(dbgs() << "callinstr::" << *callinstr << "\n");


}

// FIXME adjusted from https://llvm.org/doxygen/CFG_8cpp_source.html#l00128
// surely there's a public function for it?
Loop *get_outermost_loop(Loop *L)
{
    while(Loop *parent = L->getParentLoop()){
        L = parent;
    }
    return L;
}



void instrument_outside_loop_basic(Instruction *call_inst,
                                   unsigned int callsite_id,
                                   unsigned int called_func_id,
                                   set<Value *> func_arguments_set,
                                   LoopInfo *LI,
                                   Function *debloat_func,
                                   deb_stats_t *stats,
                                   map<Loop *, set<int> *> &loop_to_func_ids)
{
    Loop *L;
    Instruction *inst_before;
    BasicBlock *preHeaderBB;

    Type *int32Ty;
    int32Ty = IntegerType::getInt32Ty(call_inst->getModule()->getContext());

    L = get_outermost_loop(LI->getLoopFor(call_inst->getParent()));
    preHeaderBB = L->getLoopPreheader();
    if(preHeaderBB){
        if(loop_to_func_ids.count(L) == 0){
            loop_to_func_ids[L] = new set<int>;
            inst_before = preHeaderBB->getTerminator();
            // FIXME for now, instrument just the callsite_id and the
            // called_func_id
            IRBuilder<> builder(inst_before);
            vector<Value *> ArgsV;
            ArgsV.push_back(llvm::ConstantInt::get(int32Ty, 2, false));
            ArgsV.push_back(llvm::ConstantInt::get(int32Ty, callsite_id, false));
            ArgsV.push_back(llvm::ConstantInt::get(int32Ty, called_func_id, false));
            Value *callinstr = builder.CreateCall(debloat_func, ArgsV);
            LLVM_DEBUG(dbgs() << "callinstr(loop)::" << *callinstr << "\n");
        }
        loop_to_func_ids[L]->insert(called_func_id);
    }else{
        // FIXME see LLVM doxygen on getLoopPreheader. The fix is to walk
        // incoming edges to the first BB of the loop
        stats->num_loops_no_preheader++;
    }
}


void instrument_return(Instruction *inst_before,
                       unsigned int func_id,
                       Function *debrt_return_func,
                       Function *debrt_return_func_intrinsic)
{
    Value *retinstrIntrinsic;
    Module *m;
    Type *int32Ty;
    Type *int64Ty;
    Type *ptr_i8;
    vector<Value *> ArgsVIntrinsic;

    m = inst_before->getModule();
    ptr_i8 = PointerType::get(Type::getInt8Ty(m->getContext()), 0);
    int32Ty = IntegerType::getInt32Ty(inst_before->getModule()->getContext());
    int64Ty = IntegerType::getInt64Ty(inst_before->getModule()->getContext());

    IRBuilder<> builderIntrinsic(inst_before);
    ArgsVIntrinsic.push_back(llvm::ConstantInt::get(int32Ty, 0, false));
    LLVM_DEBUG(dbgs() << "Instrumenting ret-inst::" << inst_before << "\n");
    retinstrIntrinsic =
      builderIntrinsic.CreateCall(debrt_return_func_intrinsic, ArgsVIntrinsic);
      //builderIntrinsic.CreateCall(debrt_return_func_intrinsic);
    LLVM_DEBUG(dbgs() << "retinstrIntrinsic::" << *retinstrIntrinsic << "\n");


    IRBuilder<> builder(inst_before);
    vector<Value *> ArgsV;
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
    //vector<Value *> ArgsV;
    //ArgsV.push_back(llvm::ConstantInt::get(int32Ty, func_id, false));
    //LLVM_DEBUG(dbgs() << "Instrumenting ret-inst::" << inst_before << "\n");
    //Value *retinstr = builder.CreateCall(debrt_return_func, ArgsV);
    //LLVM_DEBUG(dbgs() << "retinstr::" << *retinstr << "\n");




}


void _instrument_protect_loop(map<Loop *, set<int> *> &loop_to_func_ids,
                              Function *debrt_protect_loop_func,
                              Function *debrt_protect_loop_end_func)
{
    Loop *L;
    BasicBlock *preHeaderBB;
    BasicBlock *uniqueExitBB;
    Instruction *inst_before;
    set<int> *func_ids;
    int func_id;

    for(map<Loop *, set<int> *>::iterator it = loop_to_func_ids.begin();
      it != loop_to_func_ids.end();
      it++){
        L        = it->first;
        func_ids = it->second;

        // instrument the loop begin.
        preHeaderBB = L->getLoopPreheader();
        if(preHeaderBB){
            vector<Value *> ArgsV;
            Type *int32Ty;
            inst_before = preHeaderBB->getTerminator();
            IRBuilder<> builder(inst_before);
            int32Ty = IntegerType::getInt32Ty(inst_before->getModule()->getContext());
            ArgsV.push_back(llvm::ConstantInt::get(int32Ty, func_ids->size(), false));
            for(set<int>::iterator itt = func_ids->begin();
              itt != func_ids->end();
              itt++){
                func_id = *itt;
                ArgsV.push_back(llvm::ConstantInt::get(int32Ty, func_id, false));
            }
            Value *callinstr = builder.CreateCall(debrt_protect_loop_func, ArgsV);
            LLVM_DEBUG(dbgs() << "callinstr(loop)::" << *callinstr << "\n");
        }else{
            // TODO
        }

        // instrument the loop end.
        uniqueExitBB = L->getUniqueExitBlock();
        if(uniqueExitBB){
            vector<Value *> ArgsV;
            Type *int32Ty;
            inst_before = uniqueExitBB->getTerminator();
            IRBuilder<> builder(inst_before);
            int32Ty = IntegerType::getInt32Ty(inst_before->getModule()->getContext());
            ArgsV.push_back(llvm::ConstantInt::get(int32Ty, func_ids->size(), false));
            for(set<int>::iterator itt = func_ids->begin();
              itt != func_ids->end();
              itt++){
                func_id = *itt;
                ArgsV.push_back(llvm::ConstantInt::get(int32Ty, func_id, false));
            }
            Value *callinstr = builder.CreateCall(debrt_protect_loop_end_func, ArgsV);
            LLVM_DEBUG(dbgs() << "callinstr(loop)::" << *callinstr << "\n");
        }else{
            // TODO : look at getExitBlocks(), etc.
            // https://llvm.org/doxygen/LoopInfoImpl_8h_source.html#l00062
        }
    }
}


bool run_on_function(deb_pass_e which_pass,
                     Function &F,
                     Function *debloat_func,
                     set<Instruction *> &jump_phi_nodes,
                     LoopInfo *LI,
                     Function *debrt_return_func,
                     Function *debrt_return_func_intrinsic,
                     Function *debrt_protect_loop_func,
                     Function *debrt_protect_loop_end_func,
                     Function *debrt_monitor_func,
                     map<CallInst *, unsigned int> &call_inst_to_id,
                     unsigned int *call_inst_count,
                     unsigned int *func_count,
                     deb_stats_t *stats,
                     map<Loop *, set<int> *> &loop_to_func_ids,
                     unordered_set<Function *> &app_funcs,
                     map<string, unsigned int> &func_name_to_id)
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
                if(can_ignore_called_func(called_func, call_inst, app_funcs)){
                    continue;
                }

                string called_func_name = called_func->getName().str();
                LLVM_DEBUG(dbgs()<<"called_func_name: "<<called_func_name<<"\n");

                //LLVM_DEBUG(dbgs()<<"\n callinst:"<<*call_inst);
                //LLVM_DEBUG(dbgs()<<"\n called func:"<<called_func->getName());
                //LLVM_DEBUG(dbgs()<<"\n does not throw:"<<call_inst->doesNotThrow());
                //LLVM_DEBUG(dbgs()<<"\n does not throw:"<<called_func->doesNotThrow());
                //LLVM_DEBUG(dbgs()<<"\n get getDereferenceableBytes:"<<call_inst->getDereferenceableBytes(0));

                if(call_inst_to_id.find(call_inst) == call_inst_to_id.end()){
                    call_inst_to_id[call_inst] = (*call_inst_count)++;
                    LLVM_DEBUG(dbgs() << "Hit init\n");
                }
                //LLVM_DEBUG(dbgs() <<"\ninstrument_profile call_inst_count:"<<(*call_inst_count));
                //LLVM_DEBUG(dbgs() << " CallPredictionTrain: got call instr "<<*call_inst<<"\n");
                if(func_name_to_id.find(called_func_name) == func_name_to_id.end()){
                    if(which_pass == DEB_PROFILE){
                        func_name_to_id[called_func_name] = (*func_count)++;
                    }else{
                        if(called_func_name == "debrt_protect" || called_func_name == "debrt_monitor"){
                            continue;
                        }
                        LLVM_DEBUG(dbgs()<<"assert 0 called_func_name: "<<called_func_name<<"\n");
                        assert(0); // this is instrumentation... func name should already exist.
                        //func_name_to_id[called_func_name] = (*func_count)++;
                    }
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
                    string prnt_type;
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
                        //string rdf_info_str = instrumentRDF(RDFBlocks, call_inst_to_id[call_inst], i+1 );
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
                    if(which_pass == DEB_MONITOR){
                        debloat_func = debrt_monitor_func;
                    }
                    instrument_callsite(call_inst,
                                        call_inst_to_id[call_inst],
                                        func_name_to_id[called_func_name],
                                        func_arguments_set,
                                        debloat_func,
                                        jump_phi_nodes,
                                        stats,
                                        LI,
                                        loop_to_func_ids);
                }
            }

            if(which_pass == DEB_PROTECT){
                ret_inst = dyn_cast<ReturnInst>(&*it_inst);
                if(ret_inst){
                    instrument_return(ret_inst,
                                      func_name_to_id[func_name],
                                      debrt_return_func,
                                      debrt_return_func_intrinsic);
                }
            }
        }
    }

    if(which_pass == DEB_PROTECT){
        _instrument_protect_loop(loop_to_func_ids,
                                 debrt_protect_loop_func,
                                 debrt_protect_loop_end_func);
    }

    return true;
}

