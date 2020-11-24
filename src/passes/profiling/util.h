#ifndef WPD_UTIL_H
#define WPD_UTIL_H

#include <llvm/Demangle/Demangle.h>
#include <llvm/IR/Module.h>

using namespace llvm;

std::string getDemangledName(const Function &F);

#endif
