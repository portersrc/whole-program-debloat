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
