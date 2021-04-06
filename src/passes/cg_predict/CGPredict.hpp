#ifndef WPD_CG_PREDICT_HPP
#define WPD_CG_PREDICT_HPP

#include <llvm/Analysis/GlobalsModRef.h>
#include <llvm/Analysis/PostDominators.h>
#include <llvm/IR/IRBuilder.h>
#include <llvm/Analysis/LoopInfo.h>

#include <set>
#include <unordered_set>
#include <iostream>
#include <fstream>
#include <sstream>


using namespace llvm;
using namespace std;


struct CGPredict {

  public:

    void init_types(Module &M);
    void instrument_func_start(Function *f,
                               Instruction *inst_before,
                               unsigned int func_id);

    Function *debprof_print_args_func;
    Function *debprof_print_func_end;
    Function *debrt_cgmonitor_func;
    unordered_set<Function *> app_funcs;
    map<CallInst *, unsigned int> call_inst_to_id;
    map<string, unsigned int> func_name_to_id;
    unsigned int func_count;
    Type *int32Ty;
    Type *int64Ty;
    Type *ptr_i8;

    void dump_stats(void);

};

#endif
