#ifndef WPD_UTIL_H
#define WPD_UTIL_H

#include "DebloatInstrument.hpp"

#include <llvm/Demangle/Demangle.h>


std::string getDemangledName(const Function &F);

#endif
