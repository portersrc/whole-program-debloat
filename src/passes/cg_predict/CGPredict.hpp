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

    void instrument_func_start(Function *f,
                               Instruction *inst_before,
                               unsigned int func_id);
    void instrument_func_end(Instruction *inst_before,
                             unsigned int func_id);

    Function *debprof_print_args_func;
    Function *debprof_print_func_end;
    Function *debrt_cgmonitor_func;
    unordered_set<Function *> app_funcs;
    map<CallInst *, unsigned int> call_inst_to_id;
    map<string, unsigned int> func_name_to_id;
    unsigned int call_inst_count;
    unsigned int func_count;
    set<Instruction *> jump_phi_nodes;
    Type *int32Ty;

    void init_debprof_print_func(Module &);
    void init_debrt_funcs(Module &);
    void read_func_name_to_id(void);
    void dump_func_name_to_id(void);
    void dump_stats(void);

};

#endif
