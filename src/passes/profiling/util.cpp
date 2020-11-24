#include "util.h"

// TODO move these to a util function when we leave the llvm tree
std::string getDemangledName(const Function &F)
{
    ItaniumPartialDemangler IPD;
    std::string name = F.getName().str();
    if(IPD.partialDemangle(name.c_str())){
        return name;
    }
    if(IPD.isFunction()){
        return IPD.getFunctionBaseName(nullptr, nullptr);
    }
    return IPD.finishDemangle(nullptr, nullptr);
}

