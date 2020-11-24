#ifndef WPD_UTIL_H
#define WPD_UTIL_H

#include <llvm/Demangle/Demangle.h>
#include <llvm/IR/Module.h>

#include "DebloatProfile.hpp"

std::string getDemangledName(const Function &F);

#endif
