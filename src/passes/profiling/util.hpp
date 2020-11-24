#ifndef WPD_UTIL_H
#define WPD_UTIL_H

#include "DebloatProfile.hpp"

#include <llvm/Demangle/Demangle.h>


std::string getDemangledName(const Function &F);

#endif
