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


bool can_ignore_called_func(Function *called_func, CallInst *call_inst)
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


