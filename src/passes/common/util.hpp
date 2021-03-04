#ifndef WPD_UTIL_H
#define WPD_UTIL_H

#include <llvm/IR/Function.h>
#include <llvm/Demangle/Demangle.h>
#include <llvm/Analysis/LoopInfo.h>
#include <llvm/IR/IRBuilder.h>

#include <set>
#include <iostream>
#include <fstream>
#include <sstream>


#include "backslice.hpp"



using namespace llvm;
using namespace std;

typedef struct{
    unsigned int max_num_args;
    unsigned int num_calls_not_in_loops;
    unsigned int num_calls_in_loops;
    unsigned int num_loops_no_preheader;
}deb_stats_t;



string getDemangledName(const Function &F);

bool can_ignore_called_func(Function *called_func, CallInst *call_inst);

#endif
