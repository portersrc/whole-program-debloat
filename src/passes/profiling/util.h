#ifndef WPD_UTIL_H
#define WPD_UTIL_H

#include <llvm/Demangle/Demangle.h>
#include <llvm/IR/Module.h>
#include <llvm/Support/Debug.h>
#include <llvm/Support/raw_ostream.h>

using namespace llvm;

std::string getDemangledName(const Function &F);

#endif
