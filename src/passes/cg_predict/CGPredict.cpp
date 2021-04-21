#include "CGPredict.hpp"
#include "../common/util.hpp"




void CGPredict::dump_stats(void)
{
    FILE *fp = fopen("cgpprof_pass_stats.txt", "w");
    fclose(fp);
}


void CGPredict::init_types(Module &M)
{
    int32Ty = IntegerType::getInt32Ty(M.getContext());
    int64Ty = IntegerType::getInt64Ty(M.getContext());
    ptr_i8  = PointerType::get(Type::getInt8Ty(M.getContext()), 0);
}


void CGPredict::instrument_func_start(Function *call_me,
                                      Instruction *inst_before,
                                      unsigned int func_id)
{
    IRBuilder<> builder(inst_before);
    vector<Value *> ArgsV;
    ArgsV.push_back(llvm::ConstantInt::get(int32Ty, 1, false));
    ArgsV.push_back(llvm::ConstantInt::get(int32Ty, func_id, false));

    LLVM_DEBUG(dbgs() << "Instrumenting func start: " << inst_before << "\n");
    CallInst *debprof_call = builder.CreateCall(call_me, ArgsV);
}


void CGPredict::instrument_func_start_with_args(Function &F,
                                                Function *call_me,
                                                Instruction *inst_before,
                                                unsigned int func_id)
{
    set<Value *> func_arguments_set;

    IRBuilder<> builder(inst_before);
    vector<Value *> ArgsV;
    ArgsV.push_back(llvm::ConstantInt::get(int32Ty, 0, false));
    ArgsV.push_back(llvm::ConstantInt::get(int32Ty, func_id, false));

    for(Function::arg_iterator it_arg = F.arg_begin(); 
        it_arg != F.arg_end();
        it_arg++){

        Value *argV = (Value *) it_arg;

        if((argV->getType()->isIntegerTy()
         || argV->getType()->isFloatTy()
         || argV->getType()->isDoubleTy()
         || argV->getType()->isPointerTy())){
            LLVM_DEBUG(dbgs() << "valid type argument\n");
            func_arguments_set.insert(argV);
        }
    }


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
            ArgsV.push_back(castedArg);
            LLVM_DEBUG(dbgs() << "pushing::" << *castedArg << "\n");
        }
    }

    ArgsV[0] = llvm::ConstantInt::get(int32Ty, ArgsV.size() - 1, false);

    LLVM_DEBUG(dbgs() << "Instrumenting func start: " << inst_before << "\n");
    CallInst *debprof_call = builder.CreateCall(call_me, ArgsV);
}


void CGPredict::identify_calls(Function &F)
{
    unsigned int num_args;
    bool can_instrument;
    string func_name;
    CallInst *call_inst;
    ReturnInst *ret_inst;

    func_name = getDemangledName(F);

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
                continue;
                /*Function *called_func = call_inst->getCalledFunction();
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
                }*/
            }

        }
    }

    return;
}

