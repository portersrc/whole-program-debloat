#ifndef WPD_UTIL_H
#define WPD_UTIL_H

#include <llvm/IR/Function.h>
#include <llvm/Demangle/Demangle.h>

using namespace llvm;


std::string getDemangledName(const Function &F);

#endif
