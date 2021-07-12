#include "llvm/Pass.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/GlobalVariable.h"
#include "llvm/IR/InstrTypes.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/Value.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/Transforms/IPO/PassManagerBuilder.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Analysis/ScalarEvolution.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/Demangle/Demangle.h"
#include "llvm/IR/InlineAsm.h"
#include "llvm/Support/CommandLine.h"

#include <set>
#include <stack>
#include <queue>
#include <string>
#include <map>
#include <algorithm>
#include <iostream>
#include <fstream>
#include <sstream>


using namespace llvm;
using namespace std;

bool ENABLE_INSTRUMENTATION_SINKING = false; // can set via command line option below
cl::opt<bool> EnableInstrumentationSinking(
    "enable-instrumentation-sinking", cl::init(false), cl::Hidden,
    cl::desc("Attempts to sink instrumentation into loops."));
bool ENABLE_INDIRECT_CALL_SINKING = false; // can set via command line option below
cl::opt<bool> EnableIndirectCallSinking(
    "enable-indirect-call-sinking", cl::init(false), cl::Hidden,
    cl::desc("Attempts to sink indirect call instrumentation into loops."));
bool ENABLE_BASIC_INDIRECT_CALL_STATIC_ANALYSIS = false; // can set via command line option below
cl::opt<bool> EnableBasicIndirectCallStaticAnalysis(
    "enable-basic-indirect-call-static-analysis", cl::init(false), cl::Hidden,
    cl::desc("Attempts to apply basic static analysis to indirect calls for mapping them at loop headers."));



namespace {
    struct WholeProgramDebloat : public ModulePass {
        static char ID;

        WholeProgramDebloat() : ModulePass(ID) {}

        Function *debrt_init_func;
        Function *debrt_protect_single_func;
        Function *debrt_protect_single_end_func;
        Function *debrt_protect_reachable_func;
        Function *debrt_protect_reachable_end_func;
        Function *debrt_protect_loop_func;
        Function *debrt_protect_loop_end_func;
        Function *debrt_protect_indirect_func;
        Function *debrt_protect_indirect_end_func;
        Function *debrt_protect_sink_func;
        Function *debrt_protect_sink_end_func;
        Function *ics_map_indirect_call_func;
        Function *ics_unmap_indirect_calls_func;
        map<Function *, int> func_to_id;
        map<int, Function *> func_id_to_func;
        map<int, string> func_id_to_name;
        map<string, int> func_name_to_id;
        Type *int32Ty;
        Type *int64Ty;
        map<Function *, set<Function *> > adj_list;
        map<Function *, set<Function *> > rev_adj_list;
        map<Function *, set<Function *> > adj_list_fps;
        set<Function *> all_funcs;
        // "encompassed funcs" are functions that we aren't
        // allowed to instrument _inside of_, because they are either
        // called inside of a loop, or they are called by a function
        // that's called inside of a loop; they're encompassed by a loop.
        set<Function *> encompassed_funcs;
        // RESTART: rename instrument-funcs.
        set<Function *> toplevel_funcs;
        map<Function *, set<Function *> > static_reachability;
        map<int, set<Function *> > loop_static_reachability;
        vector<set<Function *>> instrumented_sets;
        map<int, set<Function *>> disjoint_sets;
        map<int, int> loop_id_to_func_id; // for debugging
        set<string> func_name_has_addr_taken;
        set<Function *> func_has_addr_taken;
        map<Function *, set<Function *> > func_to_fps;
        map<Function *, set<Function *> > func_to_parents;
        map<int, set<int> > sinks; // sink id to its function IDs
        map<int, int> sink_id_to_func_id; // the function ID that holds the sink, for debugging
        map<string, long> readelf_func_name_to_size;
        int loop_id_counter;
        int sink_id_counter;
        long long text_size;
        set<string> ics_func_names;


        void getAnalysisUsage(AnalysisUsage &AU) const
        {
            AU.addRequired<LoopInfoWrapperPass>();
        }

        bool runOnModule(Module &M) override;
        bool runOnModule_real(Module &M);
        bool doInitialization(Module &) override;
        bool doFinalization(Module &) override;

        void wpd_init(Module &M);
        void build_basic_structs(Module &M);
        void extend_adj_list(void);
        void build_static_reachability(void);
        //void extend_static_reachability(void);
        void build_func_to_parents(void);
        void extend_encompassed_funcs(void);
        void build_toplevel_funcs(void);
        void create_disjoint_sets(void);

        bool instrument_main(Module &M);
        void instrument(void);
        void instrument_loop(int func_id, Loop *loop);
        void instrument_loop_sink(int toplevel_func_id, Loop *toplevel_loop);

        int recurse_sink(Function *toplevel_func,
                         set<Function *> &toplevel_bridge_list,
                         set<Function *> &visited_funcs,
                         pair<Function *, CallBase *> parent_func);
        void instrument_after_invoke(InvokeInst *II,
                                     vector<Value *> &ArgsV,
                                     Function *debrt_func);
        void instrument_indirect(void);

        void get_callees(Loop *loop,
                         vector<pair<Function *, CallBase *> > &callees);
        void get_callees(pair<Function *, CallBase *> parent_func,
                         vector<pair<Function *, CallBase *> > &callees);
        bool sinking_condition_satisfied(vector<pair<Function *, CallBase *> > &callees,
                                                set<Function *> &visited_funcs);
        void instrument_sink_point(pair<Function *, CallBase *> parent_func,
                                   set<Function *> *toplevel_bridge_list);
        int iterative_sink(set<Function *> &toplevel_bridge_list,
                           set<Function *> &visited_funcs,
                           pair<Function *, CallBase *> parent_func);
        void get_callees_aux(vector<pair<Function *, CallBase *> > &callees,
                                     Instruction &I);
        void read_readelf_sections(void);
        void read_readelf(void);
        int get_set_byte_size(set<Function *> &functions);
        void get_address_taken_uses(Function &F, vector<User *> &offenders);
        void build_func_to_fps(Module &M);


        string get_demangled_name(const Function &F);
        void dump_static_reachability(void);
        void dump_loop_static_reachability(void);
        void dump_encompassed_funcs(void);
        void dump_loop_id_to_func_id(void);
        void dump_sink_id_to_func_id(void);
        void dump_sinks(void);
        void dump_func_name_to_id(void);
        void dump_func_ptrs(void);
        void dump_disjoint_sets(void);
        void dump_stats(void);
    };
}

struct wpd_stats{
    int num_toplevel_loops;
    int num_instrumented_basic_loops;
    int num_instrumented_sunk_loops;
    int num_instrumented_sunk_multilevel_loops;
    int sink_fail_no_calles;
    int sink_fail_due_to_visited;
    int sink_fail_thresh_check;
}stats;


void WholeProgramDebloat::get_callees_aux(vector<pair<Function *, CallBase *> > &callees,
                                                  Instruction &I)
{
    pair<Function *, CallBase *> fcb;
    CallBase   *CB = dyn_cast<CallBase>(&I);
    CallInst   *CI = dyn_cast<CallInst>(&I);
    InvokeInst *II = dyn_cast<InvokeInst>(&I);
    if(CB){
        Function *callee = CB->getCalledFunction();
        if(func_to_id.count(callee) > 0){
            //callee_blocks_set.insert(&B); // FIXME dont want duplicates
            //callee_blocks.push_back(&B);
            //block_to_callee[&B] = callee;
            callees.push_back(make_pair(callee, CB));
        }
    }
}
void WholeProgramDebloat::get_callees(pair<Function *, CallBase *> parent_func,
                                      vector<pair<Function *, CallBase *> > &callees)
{
    for(auto &B : *(parent_func.first)){
        for(auto &I : B){
            get_callees_aux(callees, I);
        }
    }
}
void WholeProgramDebloat::get_callees(Loop *loop,
                                      vector<pair<Function *, CallBase *> > &callees)
{
    for(auto B : loop->getBlocks()){
        for(auto &I : (*B)){
            get_callees_aux(callees, I);
        }
    }
}

int WholeProgramDebloat::get_set_byte_size(set<Function *> &functions)
{
    int sum = 0;
    for(auto f : functions){
        sum += readelf_func_name_to_size[f->getName().str()];
    }
    return sum;
}


// Based on llvm 11 source tree's hasAddressTaken.
// For some function F, adds to offenders any "users" that take the address
// of F.
void WholeProgramDebloat::get_address_taken_uses(Function &F, vector<User *> &offenders)
{
  for (const Use &U : F.uses()) {
    User *FU = U.getUser();
    if (isa<BlockAddress>(FU))
      continue;

    const auto *Call = dyn_cast<CallBase>(FU);
    if (!Call) {
      offenders.push_back(FU);
    }
    if (!Call->isCallee(&U)) {
      offenders.push_back(FU);
    }
  }
}


bool WholeProgramDebloat::sinking_condition_satisfied(vector<pair<Function *, CallBase *> > &callees,
                                                      set<Function *> &visited_funcs)
{
    // Debug/dev attempt
    //#define UNION_THRESH 10
    //#define INTERSECT_THRESH 1
    // Thresh settings 1
    static const int UNION_THRESH = text_size * .1f;
    static const int INTERSECT_THRESH = text_size * .05f;
    // Thresh settings 2
    //static const int UNION_THRESH = text_size * .05f;
    //static const int INTERSECT_THRESH = text_size * .05f;
    // Thresh settings 3
    //static const int UNION_THRESH = text_size * .01f;
    //static const int INTERSECT_THRESH = text_size * 1.0f;

    int i;
    vector<set<Function *> > Ss;

    if(callees.size() == 0){
        stats.sink_fail_no_calles++;
        errs() << "sinking condition failed early b/c callees size is 0\n";
        return false;
    }

    // Identify S sets
    for(auto callee : callees){
        // XXX Early termination for threshold calculation:
        // This is a conservative approach for now. Any repeat of a visited
        // func means the threshold condition is not satisfied.
        if(visited_funcs.find(callee.first) != visited_funcs.end()){
            stats.sink_fail_due_to_visited++;
            errs() << "early teriminate sinking condition due to visited-func\n";
            return false;
        }
        Ss.push_back(static_reachability[callee.first]);
    }

    // Find intersection across all S sets
    set<Function *> set_intersect_fin;
    set<Function *> tmp;
    set_intersect_fin.insert(Ss[0].begin(), Ss[0].end());
    for(i = 1; i < Ss.size(); i++){
        tmp.clear();
        tmp.insert(set_intersect_fin.begin(), set_intersect_fin.end());
        set_intersect_fin.clear();
        set_intersection(tmp.begin(),
                         tmp.end(),
                         Ss[i].begin(),
                         Ss[i].end(),
                         inserter(set_intersect_fin, set_intersect_fin.end()));
    }

    // Find union across all S sets
    set<Function *> set_union_fin;
    set_union_fin.insert(Ss[0].begin(), Ss[0].end());
    for(i = 1; i < Ss.size(); i++){
        tmp.clear();
        tmp.insert(set_union_fin.begin(), set_union_fin.end());
        set_union_fin.clear();
        set_union(tmp.begin(),
                  tmp.end(),
                  Ss[i].begin(),
                  Ss[i].end(),
                  inserter(set_union_fin, set_union_fin.end()));
    }

    int union_B     = get_set_byte_size(set_union_fin);
    int intersect_B = get_set_byte_size(set_intersect_fin);

    // FIXME: write a function like get_set_diff_size() which actually gets
    //        the total text size of its functions.  Don't just use the size of
    //        set_diff_fin. That's wrong.  And fix THRESH and THRESH_SMALL. not
    //        simple integers, but probably based on proportions of the total
    //        text size.
    //if(set_union_fin.size() > UNION_THRESH && set_intersect_fin.size() < INTERSECT_THRESH){
    //    errs() << "THRESH success: set_union_size("<<set_union_fin.size()<<") "
    //           << "set_intersect_size("<< set_intersect_fin.size()<<")\n";
    //    return true;
    //}
    //errs() << "THRESH fail: set_union_size("<<set_union_fin.size()<<") "
    //       << "set_intersect_size("<< set_intersect_fin.size()<<")\n";


    errs() << "UNION_THRESH(" << UNION_THRESH << ") "
           << "INTERSECT_THRESH(" << INTERSECT_THRESH << ")\n";
    if(union_B > UNION_THRESH && intersect_B < INTERSECT_THRESH){
        errs() << "THRESH success: "
               << "union_B(" << union_B << ") "
               << "intersect_B(" << intersect_B << ")\n";
        return true;
    }
    errs() << "THRESH fail: set_union_size("<<set_union_fin.size()<<") "
           << "set_intersect_size("<< set_intersect_fin.size()<<")\n";

    stats.sink_fail_thresh_check++;
    return false;
}

void WholeProgramDebloat::instrument_sink_point(pair<Function *, CallBase *> parent_func,
                                                set<Function *> *toplevel_bridge_list)
{
    CallBase *CB = parent_func.second;

    int sink_id = sink_id_counter;
    sink_id_counter++;

    // instrument before callee
    vector<Value *> ArgsV;
    ArgsV.push_back(ConstantInt::get(int32Ty, sink_id, false));
    IRBuilder<> builder(CB);
    builder.CreateCall(debrt_protect_sink_func, ArgsV);

    CallInst   *CI = dyn_cast<CallInst>(CB);
    InvokeInst *II = dyn_cast<InvokeInst>(CB);
    // instrument after callee
    if(CI){
        IRBuilder<> builder_end(CI);
        builder_end.SetInsertPoint(CI->getNextNode());
        builder_end.CreateCall(debrt_protect_sink_end_func, ArgsV);
    }else if(II){
        errs() << "sink-instrument invoke case\n";
        instrument_after_invoke(II, ArgsV, debrt_protect_sink_end_func);
    }else{
        assert(0);
    }

    // Store the sink ID -> func IDs
    // If this is a toplevel function call, then the sink ID corresponds
    // to the bridge list. Otherwise this is an instrumentation point deeper
    // than the toplevel call, and we need the function itself and its
    // statically reachable set.
    set<Function *> temp;
    if(toplevel_bridge_list){
        // this is a toplevel function call
        for(auto func : *toplevel_bridge_list){
            sinks[sink_id].insert(func_to_id[func]);
            temp.insert(func);
        }
    }else{
        // not a toplevel function call
        sinks[sink_id].insert(func_to_id[parent_func.first]);
        temp.insert(parent_func.first);
        for(auto func : static_reachability[parent_func.first]){
            sinks[sink_id].insert(func_to_id[func]);
            temp.insert(func);
        }
    }
    instrumented_sets.push_back(temp);
    sink_id_to_func_id[sink_id] = func_to_id[parent_func.first]; // for debugging
}


int WholeProgramDebloat::iterative_sink(set<Function *> &toplevel_bridge_list,
                                        set<Function *> &visited_funcs,
                                        pair<Function *, CallBase *> toplevel_func)
{

    stack<pair<Function *, CallBase *> > s;

    s.push(toplevel_func);
    while(!s.empty()){
        vector<pair<Function *, CallBase *> > callees;
        pair<Function *, CallBase *> parent_func;

        parent_func = s.top();
        s.pop();

        visited_funcs.insert(parent_func.first);

        get_callees(parent_func, callees);

        if(sinking_condition_satisfied(callees, visited_funcs)){
            // add parent as a bridge
            toplevel_bridge_list.insert(parent_func.first);

            // descend to callees
            for(auto c : callees){
                s.push(c);
            }
        }else{

            // the callees don't satisfy the sink condition, so we need
            // to sink instrumentation to their parent function
            instrument_sink_point(parent_func, NULL);
        }
    }
}




void WholeProgramDebloat::instrument_loop_sink(int toplevel_func_id,
                                               Loop *toplevel_loop)
{
    errs() << "Attempting to instrument loop sink for toplevel_func_id: " << toplevel_func_id << "\n";
    bool multilevel_sink = false; // for stats

    vector<pair<Function *, CallBase *> > callees;
    set<Function *> visited_funcs;
    set<Function *> toplevel_bridge_list;

    // Grab the callees within this top-level loop
    get_callees(toplevel_loop, callees);

    // Check if the sinking condition is even satisfied within this top-level
    // loop
    if(sinking_condition_satisfied(callees, visited_funcs)){
        // The condition is met, so we'll sink instrumentation into the loop,
        // and possibly into interprocedural points
        for(auto toplevel_callee : callees){
            toplevel_bridge_list.clear();
            visited_funcs.clear();

            // never revisit a toplevel-func
            for(auto toplevel_callee : callees){
                visited_funcs.insert(toplevel_callee.first);
            }

            // for this toplevel-callee, try to sink deeper
            iterative_sink(toplevel_bridge_list, visited_funcs, toplevel_callee);

            // If the sink went deeper, then our bridge list is populated.
            // So we need to instrument the toplevel-callee with the bridges
            if(toplevel_bridge_list.size()){
                instrument_sink_point(toplevel_callee, &toplevel_bridge_list);
                multilevel_sink = true; // for stats
            }
        }
        stats.num_instrumented_sunk_loops++;
        if(multilevel_sink){
            stats.num_instrumented_sunk_multilevel_loops++;
        }
    }else{
        // Top-level callees did not satisfy threshold for sinking, so we
        // just do normal loop instrumentation in this case
        errs() << "Instrument_loop_sink did not satisfy initial sink "
               << "condition. calling instrument_loop\n";
        instrument_loop(toplevel_func_id, toplevel_loop);
    }

}


void WholeProgramDebloat::instrument_loop(int func_id, Loop *loop)
{
    //
    // XXX All this code is intentionally crammed in here. 'loop' is, I think,
    // an object address from getLoopInfo() that poofs. So we don't want to
    // rely on its address as a map key anywhere (like we might for a Fuction
    // or BasicBlock object).
    // 

    int loop_id = loop_id_counter;

    // Find preheader
    BasicBlock *preheader = loop->getLoopPreheader();
    assert(preheader); // must run -loop-simplify for this to be OK.

    // Prime loop_static_reachability with any callees in our loops
    for(auto &B : loop->getBlocks()){
        for(auto &I : (*B)){
            CallBase *cb = dyn_cast<CallBase>(&I);
            if(cb){
                Function *callee = cb->getCalledFunction();
                // Normal callee: just prime this loop's static reachability
                // with it.
                if(func_to_id.count(callee) > 0){
                    loop_static_reachability[loop_id].insert(callee);
                }
                if(ENABLE_BASIC_INDIRECT_CALL_STATIC_ANALYSIS){
                    // Indirect call: We will prime the loop's static reachability
                    // with any function pointers that could have been invoked.
                    // This is based on the adj-list-fps for this function.
                    if(cb->getCalledFunction() == NULL){
                        loop_static_reachability[loop_id].insert(
                          adj_list_fps[func_id_to_func[func_id]].begin(),
                          adj_list_fps[func_id_to_func[func_id]].end());
                    }
                }
            }
        }
    }

    // If there was at least one function call inside the loop, then we
    // will instrument it.
    if(loop_static_reachability.find(loop_id) != loop_static_reachability.end()){
        stats.num_instrumented_basic_loops++;

        // Extend based on reachability of those callees
        for(auto loop_callee : loop_static_reachability[loop_id]){
            for(auto reachable_func : static_reachability[loop_callee]){
                loop_static_reachability[loop_id].insert(reachable_func);
            }
        }

        // Create arguments for the library function
        // errs() << "Make arguments\n";
        vector<Value *> ArgsV;
        errs() << "instrumenting loop id " << loop_id << "\n";
        ArgsV.push_back(ConstantInt::get(int32Ty, loop_id, false));

        // instrument the preheader of the loop
        Instruction *TI = preheader->getTerminator();
        assert(TI);
        assert(debrt_protect_loop_func);
        IRBuilder<> builder(TI);
        builder.CreateCall(debrt_protect_loop_func, ArgsV);

        //Set of functions debloated within loop (Sharjeel)
        instrumented_sets.push_back(loop_static_reachability[loop_id]);
        // errs() << "Inserted library function within preheader(" << preheader->getName().str() << "\n";

        // instrument the exit(s) block(s) of the loop
        SmallVector<BasicBlock *, 8> exit_blocks;
        loop->getUniqueExitBlocks(exit_blocks);

        // dont assert. can refer to https://llvm.org/docs/LoopTerminology.html
        // statically infinite loop is possible. we just won't instrument exits in
        // that case
        //assert(exit_blocks.size() > 0);

        for(auto exit_block : exit_blocks){
            Instruction *ebt = exit_block->getTerminator();
            assert(ebt);
            IRBuilder<> builder_exit(ebt);
            builder_exit.CreateCall(debrt_protect_loop_end_func, ArgsV);
        }

        // Note which function this loop is associated with
        loop_id_to_func_id[loop_id] = func_id;

        // Bump our ID counter
        loop_id_counter++;
    }

}


void WholeProgramDebloat::extend_encompassed_funcs(void)
{
    for(auto F : func_has_addr_taken){
        encompassed_funcs.insert(F);
    }
    for(auto F : encompassed_funcs){
        for(auto reachable_func : static_reachability[F]){
            encompassed_funcs.insert(reachable_func);
        }
    }
}


void WholeProgramDebloat::instrument_after_invoke(InvokeInst *II,
                                                  vector<Value *> &ArgsV,
                                                  Function *debrt_func)
{
    if(II->getCalledFunction()){
        errs() << "function called: " << II->getCalledFunction()->getName() << "\n";
    }else{
        errs() << "getCalledFunction() is returning null so perhaps "
        << "indirect invocations complicate the number of successors.\n";
    }
    // sanity check num-successors. should have
    // two: normal dest and unwind dest
    if(II->getNumSuccessors() != 2){
        errs()
        << "ERROR: unexpected number of successors. "
        << "expected 2, but got " << II->getNumSuccessors() << "\n";
        assert(0);
    }
    BasicBlock *new_bb = SplitEdge(II->getParent(), II->getNormalDest());
    //BasicBlock *pred_bb = new_bb->getUniquePredecessor();
    //assert(pred_bb);
    //if(new_bb == II->getParent()){
    //    errs() << "new_bb is the 'from'\n";
    //}else if(new_bb == II->getNormalDest()){
    //    errs() << "new_bb is the 'to'\n";
    //}else{
    //    errs() << "new_bb is in the middle\n";
    //}
    Instruction *ndi = II->getNormalDest()->getFirstNonPHI();
    //Instruction *ndi = new_bb->getFirstNonPHI();
    //Instruction *ndi = pred_bb->getFirstNonPHI();
    //for(auto &I : *new_bb){
    //    errs() << I << "\n";
    //}
    if(ndi == NULL){
        // unexpected, though the API allows getFirstNonPHI to be null.
        // assert 0 for now and handle only if we encounter it.
        errs() << "ndi is null\n";
        assert(0);
    }
    IRBuilder<> builder_end(ndi);
    if(dyn_cast<LandingPadInst>(ndi)){
        builder_end.SetInsertPoint(ndi->getNextNode());
    }
    builder_end.CreateCall(debrt_func, ArgsV);
}


void WholeProgramDebloat::instrument_indirect(void)
{
    for(auto f : all_funcs){
        errs() << "Instrumenting indirect for " << f->getName().str() << "\n";
        for(auto &b : *f){
            for(auto &I : b){
                CallBase   *CB = dyn_cast<CallBase>(&I);
                CallInst   *CI = dyn_cast<CallInst>(&I);
                InvokeInst *II = dyn_cast<InvokeInst>(&I);
                if(CB){
                    if(CB->getCalledFunction() == NULL){
                        errs() << "seeing indirect function call\n";
                        Value *v = CB->getCalledOperand();
                        if(dyn_cast<InlineAsm>(v)){
                            // ignore inline assembly... don't instrument
                            continue;
                        }
                        if(v->getType()->isPointerTy()){
                            if(ENABLE_INDIRECT_CALL_SINKING
                            || encompassed_funcs.find(f) == encompassed_funcs.end()){
                                // instrument before indirect func call
                                vector<Value *> ArgsV;
                                IRBuilder<> builder(CB);
                                ArgsV.push_back(builder.CreatePtrToInt(v, int64Ty));
                                if(ENABLE_INDIRECT_CALL_SINKING){
                                    builder.CreateCall(ics_map_indirect_call_func, ArgsV);
                                }else{
                                    builder.CreateCall(debrt_protect_indirect_func, ArgsV);
                                }
                                
                                // optimization: only instrument after the
                                // indirect call if we are not inside an
                                // encompassed func. That is, the runtime
                                // will handle this ICS optimization to clear
                                // the pages at the end of the loop.
                                if(encompassed_funcs.find(f) == encompassed_funcs.end()){
                                    // instrument after indirect func call
                                    if(CI){
                                        IRBuilder<> builder_end(CI);
                                        builder_end.SetInsertPoint(CI->getNextNode());
                                        builder_end.CreateCall(debrt_protect_indirect_end_func, ArgsV);
                                    }else if(II){
                                        errs() << "indirect func invoke case\n";
                                        instrument_after_invoke(II, ArgsV, debrt_protect_indirect_end_func);
                                    }else{
                                        assert(0);
                                    }
                                }
                            }else{
                                errs() << "WARNING: Unhandled functionality "
                                       << "- indirect call in encompassed_funcs."
                                       << " Could lead to runtime crash.\n";
                                //assert(0 && "ERROR: Unhandled functionality " \
                                //       "- indirect call in encompassed_funcs");
                            }
                        }else{
                            // Not sure how to handle this if it happens
                            // would need to investigate the specific case.
                            assert(0 && "Unexpected: calledOperand is NOT a " \
                                        "pointer type for an indirect call.\n");
                        }
                    }
                }
            }
        }
    }
}


void WholeProgramDebloat::instrument(void)
{
    for(auto f : toplevel_funcs){
        errs() << "Instrumenting " << f->getName().str() << "\n";

        // Instrument outer loops
        LoopInfo *LI = &getAnalysis<LoopInfoWrapperPass>(*f).getLoopInfo();
        for(auto loop = LI->begin(), e = LI->end(); loop != e; ++loop){
            stats.num_toplevel_loops++;
            if(ENABLE_INSTRUMENTATION_SINKING){
                // TODO
                // TODO If we try to do loop sinking again, then i think we
                // need to agument get_callees_aux() (or somewhere around
                // there) with ENABLE_BASIC_INDIRECT_CALL_STATIC_ANALYSIS
                // support.  (assuming we want to support it for
                // instrumentation-sinking).  Can look at how instrument_loop()
                // does it. Be aware of course that instrument-loop-sink may
                // invoke instrument-loop as a fallback case (not sure if that
                // matters though).
                // TODO
                instrument_loop_sink(func_to_id[f], *loop);
            }else{
                instrument_loop(func_to_id[f], *loop);
            }
        }

        // instrument call sites
        for(auto &b : *f){
            // ignore basic blocks that are part of any loop. already handled.
            if(LI && LI->getLoopFor(&b)){
                continue;
            }
            for(auto &I : b){
                CallBase   *CB = dyn_cast<CallBase>(&I);
                CallInst   *CI = dyn_cast<CallInst>(&I);
                InvokeInst *II = dyn_cast<InvokeInst>(&I);
                if(CB){
                    Function *callee = CB->getCalledFunction();
                    if(func_to_id.count(callee) > 0){
                        set<Function *> temp;
                        temp.insert(callee);
                        if(encompassed_funcs.find(callee) != encompassed_funcs.end()){
                            // Case: callee is no-instrument
                            temp.insert(static_reachability[callee].begin(), static_reachability[callee].end());

                            // instrument before callee
                            vector<Value *> ArgsV;
                            ArgsV.push_back(ConstantInt::get(int32Ty, func_to_id[callee], false));
                            IRBuilder<> builder(CB);
                            builder.CreateCall(debrt_protect_reachable_func, ArgsV);

                            // instrument after callee
                            if(CI){
                                IRBuilder<> builder_end(CI);
                                builder_end.SetInsertPoint(CI->getNextNode());
                                builder_end.CreateCall(debrt_protect_reachable_end_func, ArgsV);
                            }else if(II){
                                errs() << "no-instrument invoke case\n";
                                instrument_after_invoke(II, ArgsV, debrt_protect_reachable_end_func);
                            }else{
                                assert(0);
                            }

                        }else{
                            // Case: callee can be instrumented.

                            // instrument before callee
                            vector<Value *> ArgsV;
                            ArgsV.push_back(ConstantInt::get(int32Ty, func_to_id[callee], false));
                            IRBuilder<> builder(CB);
                            builder.CreateCall(debrt_protect_single_func, ArgsV);

                            // instrument after callee
                            if(CI){
                                IRBuilder<> builder_end(CI);
                                builder_end.SetInsertPoint(CI->getNextNode());
                                builder_end.CreateCall(debrt_protect_single_end_func, ArgsV);
                            }else if(II){
                                errs() << "yes-instrument invoke case\n";
                                instrument_after_invoke(II, ArgsV, debrt_protect_single_end_func);
                            }else{
                                assert(0);
                            }
                        }
                        //An example of set of functions that will be debloated (Sharjeel)
                        instrumented_sets.push_back(temp);
                    }
                }
            }
        }
    }


}


bool WholeProgramDebloat::instrument_main(Module &M)
{
    int found_main = 0;
    for(auto &F : M){
        string func_name = get_demangled_name(F);
        if(func_name == "main"){
            // FIXME: actually instrument main
            vector<Value *> ArgsV;
            Instruction *I = F.getEntryBlock().getFirstNonPHI();
            assert(I);
            IRBuilder<> builder(I);
            ArgsV.push_back(ConstantInt::get(int32Ty, func_to_id[&F], false));
            ArgsV.push_back(ConstantInt::get(int32Ty, ENABLE_INSTRUMENTATION_SINKING, false));
            builder.CreateCall(debrt_init_func, ArgsV);
            found_main = 1;
            break;
        }
    }
    assert(found_main == 1);
}


void WholeProgramDebloat::build_basic_structs(Module &M)
{
    LoopInfo *li;
    CallBase *cb;
    for(auto &F : M){
        if(F.hasName() && !F.isDeclaration()){
            if(ics_func_names.find(F.getName().str()) != ics_func_names.end()){
                //errs() << "ignoring ics func: " << F.getName() << "\n";
                continue;
            }
            // update all_funcs
            all_funcs.insert(&F);
            li = &getAnalysis<LoopInfoWrapperPass>(F).getLoopInfo();
            for(auto &B : F){
                for(auto &I : B){
                    cb = dyn_cast<CallBase>(&I);
                    if(cb){
                        Function *callee = cb->getCalledFunction();
                        if(func_to_id.count(callee) > 0){
                            // update adj_list
                            adj_list[&F].insert(callee);
                            if(li && li->getLoopFor(&B)){
                                // add any functions that are called inside of
                                // a loop to encompassed_funcs
                                encompassed_funcs.insert(callee);
                            }
                        }
                    }
                }
            }
        }
    }
    // build reverse adjacency list
    for(auto caller_callees : adj_list){
        auto caller  = caller_callees.first;
        auto callees = caller_callees.second;
        for(auto callee : callees){
            rev_adj_list[callee].insert(caller);
        }
    }
}

void WholeProgramDebloat::create_disjoint_sets(void)
{
    // Set of functions that have addresses taken so we take their reachability and consider it as a set (Sharjeel)
    for(auto F : func_has_addr_taken)
    {
        set<Function *> temp;
        temp.insert(F);
        temp.insert(static_reachability[F].begin(), static_reachability[F].end());
        instrumented_sets.push_back(temp);
    }

    size_t index = 0;
    set<Function *> intersection;
    set<Function *> difference1;
    set<Function *> difference2;
    // While there are non-disjoint sets
    while(!instrumented_sets.empty())
    {
        // Take a set A
        vector<set<Function *>> temp(instrumented_sets.begin() + 1, instrumented_sets.end());
        set<Function *> current(instrumented_sets[0]);
        instrumented_sets.clear();

        // Take a set B
        for(auto setF : temp)
        {
            if(current.size() != 0)
            {   
                intersection.clear();
                difference1.clear();
                difference2.clear();

                if(setF.size() == 0)
                {
                    continue;
                }

                // Take intersection of set A and set B to make set C
                set_intersection(current.begin(), current.end(), setF.begin(), setF.end(), inserter(intersection, intersection.end()));
                if(intersection.size() == 0)
                {
                    // If intersection is empty, we do not need to do any difference and keep set B for next stage
                    instrumented_sets.push_back(setF);
                }
                else
                {
                    // Take difference between set A and set C to get set A-C
                    set_difference(current.begin(), current.end(), intersection.begin(), intersection.end(), inserter(difference1, difference1.end()));

                    // Take difference between set B and set C to get set B-C
                    set_difference(setF.begin(), setF.end(), intersection.begin(), intersection.end(), inserter(difference2, difference2.end()));

                    // If both set A and set B are the same, we remove set B and continue with set A
                    if(difference1.size() == 0 && difference2.size() == 0)
                    {
                        continue;
                    }

                    // If set B is empty, we do not need to consider it for a future step
                    if(difference2.size() != 0)
                    {
                        instrumented_sets.push_back(difference2);
                    }
                    
                    instrumented_sets.push_back(intersection);

                    current.clear();
                    current.insert(difference1.begin(), difference1.end());
                }
            }
            else 
            {
                instrumented_sets.push_back(setF);
            }
        }

        // If set A is not empty, we consider it as a disjoint set
        if(current.size() != 0)
        {
            disjoint_sets[index].insert(current.begin(), current.end());
        }
        index += 1;
    }
}

///
// XXX Commented out, leaving for posterity. This function is wrong, I think,
// because it doesn't take into account convergence. A better way to do this is
// to just extend adj_list based on func pointers, and then just leverage
// build_static_reachability() with that augmented adj-list.
//
// Extend static reachability based on "simple" function pointer analysis.
// This is not leveraging true pointer analysis. Rather, for any function
// F, we add to its statically reachable set any function pointer that
// could be invoked on some (flow-insensitive) path to F in the callgraph.
// "Could be invoked" is very conservative: It's true if a function has
// its address taken along that path, and false otherwise.
/*void WholeProgramDebloat::extend_static_reachability(void)
{
    for(auto func_parents : func_to_parents){
        auto func    = func_parents.first;
        auto parents = func_parents.second;

        // first take care of the "base" function itself.
        // For any function pointers that it uses, add those function pointers
        // to its statically reachable set.
        auto fps = func_to_fps[func];
        for(auto fp : fps){
            if(fp != func){
                static_reachability[func].insert(
                  static_reachability[fp].begin(),
                  static_reachability[fp].end()
                );
            }
        }

        // now take care of all of its parents. for each parent, grab any
        // function pointers that it uses, and add that to the statically
        // reachable set of our base func.
        for(auto parent : parents){
            auto fps = func_to_fps[parent];
            for(auto fp : fps){
                if(fp != func){
                    static_reachability[func].insert(
                      static_reachability[fp].begin(),
                      static_reachability[fp].end()
                    );
                }
            }

        }
    }
}*/

void WholeProgramDebloat::extend_adj_list(void)
{
    for(auto func_parents : func_to_parents){
        auto func    = func_parents.first;
        auto parents = func_parents.second;

        // First take care of the "base" function itself.
        // For any functions that it takes the address of, add them to
        // its adj-list-fps
        auto fps = func_to_fps[func];
        adj_list_fps[func].insert(fps.begin(), fps.end());

        // Now take care of all of its parents. For each parent, grab any
        // functions that it takes the address of, and add those to the
        // adj-list-fps our base func.
        for(auto parent : parents){
            auto fps = func_to_fps[parent];
            adj_list_fps[func].insert(fps.begin(), fps.end());
        }

        // update the func's adj-list with its adj-list-fps
        adj_list[func].insert(adj_list_fps[func].begin(),
                              adj_list_fps[func].end());
    }
}

void WholeProgramDebloat::build_static_reachability(void)
{
    for(auto F : all_funcs){
        queue<Function *> q;
        for(auto callee : adj_list[F]){
            q.push(callee);
        }
        while(!q.empty()){
            Function *f = q.front();
            q.pop();
            static_reachability[F].insert(f);
            for(auto qcallee : adj_list[f]){
                if(static_reachability[F].find(qcallee) == static_reachability[F].end()){
                    q.push(qcallee);
                }
            }
            // If the function is recursive or part of an SCC, add it to
            // encompassed funcs.
            if(F == f){
                encompassed_funcs.insert(f);
            }
        }
    }
}
void WholeProgramDebloat::build_func_to_parents(void)
{
    for(auto F : all_funcs){
        queue<Function *> q;
        for(auto parent : rev_adj_list[F]){
            q.push(parent);
        }
        while(!q.empty()){
            Function *f = q.front();
            q.pop();
            func_to_parents[F].insert(f);
            for(auto qparent : rev_adj_list[f]){
                if(func_to_parents[F].find(qparent) == func_to_parents[F].end()){
                    q.push(qparent);
                }
            }
        }
    }
}

// Can think of this as building a map that tells us where function pointers
// get created -- so for some function, I can tell you which fps are created
// inside of it.  More specifically, we build a map of function -> set of
// functions that it takes the address of.  We do this by first finding all
// points ('uses') where a function has its address taken. If that point is a
// valid instruction, then we add to our map: the key is the instruction's
// function (i.e. the function where we take another function's address); the
// value is the function whose address we take.
void WholeProgramDebloat::build_func_to_fps(Module &M)
{
    int s;
    int f;
    s = 0;
    f = 0;
    for(auto &F : M){
        if(F.hasName() && !F.isDeclaration()){
            vector<User *> offenders;
            get_address_taken_uses(F, offenders);
            // offenders will be non-empty if F has its address taken
            for(User *user : offenders){
                Instruction *i = dyn_cast<Instruction>(user);
                if(i){
                    Function *f = i->getFunction();
                    //errs() << "function pointer user: " << f->getName() << "\n";
                    func_to_fps[f].insert(&F);
                    s++;
                }else{
                    f++;
                }
            }
        }
    }
    //errs() << "s: " << s << "\n";
    //errs() << "f: " << f << "\n";
}

void WholeProgramDebloat::build_toplevel_funcs(void)
{
    // toplevel_funcs = all_funcs \ encompassed_funcs
    set_difference(all_funcs.begin(),
                   all_funcs.end(),
                   encompassed_funcs.begin(),
                   encompassed_funcs.end(),
                   inserter(toplevel_funcs, toplevel_funcs.end()));
}

void WholeProgramDebloat::wpd_init(Module &M)
{
    // Init loop count (for handing out IDs)
    loop_id_counter = 0;
    sink_id_counter = 0;

    ENABLE_INSTRUMENTATION_SINKING = EnableInstrumentationSinking;
    errs() << "ENABLE_INSTRUMENTATION_SINKING: " << ENABLE_INSTRUMENTATION_SINKING << "\n";
    ENABLE_INDIRECT_CALL_SINKING = EnableIndirectCallSinking;
    errs() << "ENABLE_INDIRECT_CALL_SINKING: " << ENABLE_INDIRECT_CALL_SINKING << "\n";
    ENABLE_BASIC_INDIRECT_CALL_STATIC_ANALYSIS = EnableBasicIndirectCallStaticAnalysis;
    errs() << "ENABLE_BASIC_INDIRECT_CALL_STATIC_ANALYSIS: " << ENABLE_BASIC_INDIRECT_CALL_STATIC_ANALYSIS << "\n";


    memset(&stats, 0, sizeof(stats));

    // FIXME (see fixme within read_readelf_sections)
    if(ENABLE_INSTRUMENTATION_SINKING){
        read_readelf_sections();
        read_readelf();
    }

    ics_func_names.insert("ics_map_indirect_call");
    ics_func_names.insert("ics_unmap_indirect_calls");

    // Give each application function an ID
    int count = 0;
    for(auto &F : M){
        if(F.hasName() && !F.isDeclaration()){
            func_name_to_id[F.getName().str()] = count;
            func_to_id[&F] = count;
            func_id_to_name[count] = F.getName().str();
            func_id_to_func[count] = &F;
            if(F.hasAddressTaken()){
                //errs() << "F.hasAddressTaken() is: " << F.getName() << "\n";
                func_name_has_addr_taken.insert(F.getName().str());
                func_has_addr_taken.insert(&F);
            }
            count++;
        }
    }


    // errs() << "Create library function\n";
    // Create library function
    int32Ty = IntegerType::getInt32Ty(M.getContext());
    int64Ty = IntegerType::getInt64Ty(M.getContext());
    Type *ArgTypes[] = { int32Ty };
    Type *ArgTypes2[] = { int32Ty, int32Ty };
    Type *ArgTypes64[] = { int64Ty };

    debrt_init_func = Function::Create(FunctionType::get(int32Ty, ArgTypes2, false),
            Function::ExternalLinkage,
            "debrt_init",
            M);
    debrt_protect_single_func = Function::Create(FunctionType::get(int32Ty, ArgTypes, false),
            Function::ExternalLinkage,
            "debrt_protect_single",
            M);
    debrt_protect_single_end_func = Function::Create(FunctionType::get(int32Ty, ArgTypes, false),
            Function::ExternalLinkage,
            "debrt_protect_single_end",
            M);
    debrt_protect_reachable_func = Function::Create(FunctionType::get(int32Ty, ArgTypes, false),
            Function::ExternalLinkage,
            "debrt_protect_reachable",
            M);
    debrt_protect_reachable_end_func = Function::Create(FunctionType::get(int32Ty, ArgTypes, false),
            Function::ExternalLinkage,
            "debrt_protect_reachable_end",
            M);
    debrt_protect_loop_func = Function::Create(FunctionType::get(int32Ty, ArgTypes, false),
            Function::ExternalLinkage,
            "debrt_protect_loop",
            M);
    debrt_protect_loop_end_func = Function::Create(FunctionType::get(int32Ty, ArgTypes, false),
            Function::ExternalLinkage,
            "debrt_protect_loop_end",
            M);
    debrt_protect_indirect_func = Function::Create(FunctionType::get(int32Ty, ArgTypes64, false),
            Function::ExternalLinkage,
            "debrt_protect_indirect",
            M);
    debrt_protect_indirect_end_func = Function::Create(FunctionType::get(int32Ty, ArgTypes64, false),
            Function::ExternalLinkage,
            "debrt_protect_indirect_end",
            M);
    debrt_protect_sink_func = Function::Create(FunctionType::get(int32Ty, ArgTypes, false),
            Function::ExternalLinkage,
            "debrt_protect_sink",
            M);
    debrt_protect_sink_end_func = Function::Create(FunctionType::get(int32Ty, ArgTypes, false),
            Function::ExternalLinkage,
            "debrt_protect_sink_end",
            M);

    // FIXME ? not sure if external weak linkage is what i want here
    ics_map_indirect_call_func = Function::Create(FunctionType::get(int32Ty, ArgTypes64, false),
            //Function::ExternalLinkage,
            //Function::ExternalWeakLinkage,
            //Function::CommonLinkage,
            //
            //Function::AvailableExternallyLinkage,
            //Function::LinkOnceAnyLinkage,
            //Function::LinkOnceODRLinkage,
            //Function::WeakAnyLinkage,
            //Function::WeakODRLinkage,
            //Function::AppendingLinkage,
            //Function::InternalLinkage,
            //Function::PrivateLinkage,
            Function::ExternalWeakLinkage,
            //Function::CommonLinkage,
            "ics_map_indirect_call",
            M);
    ics_unmap_indirect_calls_func = Function::Create(FunctionType::get(int32Ty, ArgTypes64, false),
            //Function::ExternalLinkage,
            //Function::ExternalWeakLinkage,
            //Function::CommonLinkage,
            //
            //Function::AvailableExternallyLinkage,
            //Function::LinkOnceAnyLinkage,
            //Function::LinkOnceODRLinkage,
            //Function::WeakAnyLinkage,
            //Function::WeakODRLinkage,
            //Function::AppendingLinkage,
            //Function::InternalLinkage,
            //Function::PrivateLinkage,
            Function::ExternalWeakLinkage,
            //Function::CommonLinkage,
            "ics_unmap_indirect_calls",
            M);


}



bool WholeProgramDebloat::runOnModule_real(Module &M)
{
    // Initialization
    wpd_init(M);

    // Build all_funcs, adj_list, func_to_loop_info
    // Paritlally build encompassed_funcs
    build_basic_structs(M);

    if(ENABLE_BASIC_INDIRECT_CALL_STATIC_ANALYSIS){
        // Build a map of func -> set of parents that can reach it.
        build_func_to_parents();

        // Build a map of func -> functions that it takes the address of
        build_func_to_fps(M);

        // Add statically reachable functions based on _simple_ function pointer
        // analysis (not true pointer analysis)
        //extend_static_reachability();

        // Extend adj-list based on the func pointers. This augmented adj-list
        // will be picked up (correctly) during build_static_reachability().
        extend_adj_list();
    }

    // Build a map of func -> set of statically reachable funcs
    // (also add funcs that are recursive or part of SCCs to encompassed-funcs)
    build_static_reachability();

    // Extend encompassed_funcs to any functions that are reachable from
    // its members
    extend_encompassed_funcs();

    // Build the set of functions that are "top-level", i.e. not reachable
    // from within any loop
    build_toplevel_funcs();

    // Instrument main with a debrt-init call
    instrument_main(M);

    // Instrument all other functions
    instrument();

    // instrument indirect function calls
    instrument_indirect();

    // create disjoint sets
    create_disjoint_sets();
}

bool WholeProgramDebloat::runOnModule(Module &M)
{
    runOnModule_real(M);
}

/*
void check_postdominance(BasicBlock *B1, BasicBlock *B2)
{
    // Stack of Basicblock
    std::stack<BasicBlock *> stacktemp;

    // Basicblocks already seen
    std::map<BasicBlock *, uint8_t> seen;

    // Add the initial successors nodes to the stack
    Instruction *TI = B1->getTerminator();
    for(uint64_t i = 0; TI && i < TI->getNumSuccessors(); ++i){
        stacktemp.push(TI->getSuccessor(i));
    }

    // While stack is not empty, keep on checking postdominance of all nodes
    while(!stacktemp.empty()){
        BasicBlock *Btemp = stacktemp.top();
        stacktemp.pop();

        // If the last node is B2, it is control dependent on B1
        if(Btemp == B2){
            dart(B2->getName().str() + " is control dependent on " + B1->getName().str());
            break;
        }
        // Else, we check if B2 postdominates this basicblock so we can
        // add the successors
        else if(!seen[Btemp] && PDT->dominates(B2, Btemp)){
            Instruction *TI = Btemp->getTerminator();
            for(uint64_t i = 0; TI && i < TI->getNumSuccessors(); ++i){
                stacktemp.push(TI->getSuccessor(i));
            }
        }
        seen[Btemp] = 1; 
    }
}
*/
/*bool is_reachable(BasicBlock *B1, BasicBlock *B2)
{
    queue<BasicBlock*> bbqueue;
    set<BasicBlock*> bbseen;
    bbqueue.push(B1);
    while(!bbqueue.empty()){
        BasicBlock *B = bbqueue.front();
        bbqueue.pop();

        if(bbseen.count(B) != 0){
            continue;
        }
        bbseen.insert(B);

        if(B == B2){
            return true;
        }

        Instruction *TI = B->getTerminator();
        for(uint64_t i = 0; TI && i < TI->getNumSuccessors(); i++){
            bbqueue.push(TI->getSuccessor(i));
        }
    }
    return false;
}*/

void WholeProgramDebloat::dump_static_reachability(void)
{
    FILE *fp_reachability = fopen("wpd_static_reachability.txt", "w");
    //errs() << "Dumping static reachability\n";
    for(auto p : static_reachability){
        Function *f = p.first;
        set<Function *> &reachable_funcs = p.second;
        //errs() << f->getName() << ": ";
        //fprintf(fp_reachability, "%s ", f->getName().str().c_str());
        fprintf(fp_reachability, "%d ", func_to_id[f]);
        for(auto rf : reachable_funcs){
            //errs() << rf->getName() << " ";
            //fprintf(fp_reachability, "%s,", rf->getName().str().c_str());
            fprintf(fp_reachability, "%d,", func_to_id[rf]);
        }
        //errs() << "\n";
        fprintf(fp_reachability, "\n");
    }
    fclose(fp_reachability);
}
void WholeProgramDebloat::dump_loop_static_reachability(void)
{
    FILE *fp_loop_reachability;
    if(ENABLE_INSTRUMENTATION_SINKING){
        fp_loop_reachability = fopen("wpd_loop_static_reachability_sinkenabled.txt", "w");
    }else{
        fp_loop_reachability = fopen("wpd_loop_static_reachability.txt", "w");
    }
    for(auto p : loop_static_reachability){
        int loop_id = p.first;
        set<Function *> &reachable_funcs = p.second;
        fprintf(fp_loop_reachability, "%d ", loop_id);
        for(auto rf : reachable_funcs){
            fprintf(fp_loop_reachability, "%d,", func_to_id[rf]);
        }
        fprintf(fp_loop_reachability, "\n");
    }
    fclose(fp_loop_reachability);
}
void WholeProgramDebloat::dump_encompassed_funcs(void)
{
    FILE *fp_encompassed = fopen("wpd_encompassed_funcs.txt", "w");
    for(auto ef : encompassed_funcs){
        int func_id = func_to_id[ef];
        fprintf(fp_encompassed, "%d (%s)\n", func_id, func_id_to_name[func_id].c_str());
    }
    fclose(fp_encompassed);
}
void WholeProgramDebloat::dump_loop_id_to_func_id(void)
{
    FILE *fp_loop_to_func = fopen("wpd_loop_to_func.txt", "w");
    for(auto p : loop_id_to_func_id){
        int loop_id = p.first;
        int func_id = p.second;
        //errs() << l->getName() << ": ";
        //fprintf(fp_loop_to_func, "%s ", l->getName().str().c_str());
        fprintf(fp_loop_to_func, "%d: %d (%s)\n", loop_id, func_id, func_id_to_name[func_id].c_str());
    }
    fclose(fp_loop_to_func);
}
void WholeProgramDebloat::dump_sink_id_to_func_id(void)
{
    FILE *fp_sink_to_func = fopen("wpd_sink_to_func.txt", "w");
    for(auto p : sink_id_to_func_id){
        int sink_id = p.first;
        int func_id = p.second;
        //errs() << l->getName() << ": ";
        //fprintf(fp_loop_to_func, "%s ", l->getName().str().c_str());
        fprintf(fp_sink_to_func, "%d: %d (%s)\n", sink_id, func_id, func_id_to_name[func_id].c_str());
    }
    fclose(fp_sink_to_func);
}
void WholeProgramDebloat::dump_sinks(void)
{
    FILE *fp_sinks = fopen("wpd_sinks.txt", "w");
    for(auto p : sinks){
        int sink_id = p.first;
        set<int> &funcs = p.second;
        fprintf(fp_sinks, "%d ", sink_id);
        for(auto f : funcs){
            fprintf(fp_sinks, "%d,", f);
        }
        fprintf(fp_sinks, "\n");
    }
    fclose(fp_sinks);
}
void WholeProgramDebloat::dump_func_ptrs(void)
{
    FILE *fp_funcptrs = fopen("wpd_func_name_has_addr_taken.txt", "w");
    for(auto func_name : func_name_has_addr_taken){
        fprintf(fp_funcptrs, "%s\n", func_name.c_str());
    }
    fclose(fp_funcptrs);
}
void WholeProgramDebloat::dump_func_name_to_id(void)
{
    FILE *fp = fopen("wpd_func_name_to_id.txt", "w");
    for(auto fn2id : func_name_to_id){
        fprintf(fp, "%s %u\n", fn2id.first.c_str(), fn2id.second);
    }
    fclose(fp);
}
void WholeProgramDebloat::dump_disjoint_sets(void)
{
    FILE *fp = fopen("wpd_disjoint_sets.txt", "w");
    for(auto set : disjoint_sets){
        fprintf(fp, "%u: ", set.first);
        for(auto f : set.second)
        {
            fprintf(fp, "%u ", func_to_id[f]);
        }
        fprintf(fp, "\n");
    }
    fclose(fp);
}
void WholeProgramDebloat::dump_stats(void)
{
    FILE *fp = fopen("wpd_stats.txt", "w");
    fprintf(fp, "Number of toplevel loops: %d\n", stats.num_toplevel_loops);
    fprintf(fp, "Number of instrumented toplevel loops: %d\n",
                stats.num_instrumented_basic_loops + stats.num_instrumented_sunk_loops);
    fprintf(fp, "Number of instrumented toplevel loops without sinking: %d\n",
                stats.num_instrumented_basic_loops);
    fprintf(fp, "Number of instrumented toplevel loops with sinking: %d\n",
                stats.num_instrumented_sunk_loops);
    fprintf(fp, "Number of instrumented toplevel loops with multilevel sinking: %d\n",
                stats.num_instrumented_sunk_multilevel_loops);
    fprintf(fp, "Number of sinking attempts (not necessarily toplevel) that " \
                "failed because:\n");
    fprintf(fp, "  there were no callees: %d\n", stats.sink_fail_no_calles);
    fprintf(fp, "  we revisited a function: %d\n", stats.sink_fail_due_to_visited);
    fprintf(fp, "  the union and intersection threshold check failed: %d\n",
                  stats.sink_fail_thresh_check);
    fclose(fp);
}
string WholeProgramDebloat::get_demangled_name(const Function &F)
{
    ItaniumPartialDemangler IPD;
    string name = F.getName().str();
    if(IPD.partialDemangle(name.c_str())){
        return name;
    }
    if(IPD.isFunction()){
        return IPD.getFunctionBaseName(nullptr, nullptr);
    }
    return IPD.finishDemangle(nullptr, nullptr);
}
// don't insert elements that are empty (so for example split(' ') on
// "a     b" will do the expected thing and return on ['a', 'b'])
template<typename Out>
void split_nonempty(const string &s, char delim, Out result)
{
    stringstream ss(s);
    string item;
    while(getline(ss, item, delim)){
        if(!item.empty()){
            *(result++) = item;
        }
    }
}
vector<string> split_nonempty(const string &s, char delim)
{
    vector<string> elems;
    split_nonempty(s, delim, back_inserter(elems));
    return elems;
}
void WholeProgramDebloat::read_readelf_sections(void)
{
    // FIXME This is a hack to get instrumentation-sinking off the ground.
    // The problem with this function and approach is that it ties this entire
    // pass to the readelf output, which means a successful build has to happen
    // before this pass can even run. But the catch-22 is that the readelf
    // output is from this pass itself.
    // The fix for this, if we're going to keep this approach for calculating
    // thresholds, is to output a separate, uniquely named readelf file after
    // building the baseline, and to enforce users of this pass to build a
    // baseline first. And by using a different name for the baseline's
    // readelf output, we won't collide with the readelf output from this pass,
    // which is used by the runtime for specific offsets and sizes for mapping
    // pages.
    ifstream ifs;
    string line;
    vector<string> elems;
    ifs.open("readelf-sections.out");
    if(!ifs.is_open()){
        perror("Error openening readelf-sections file");
        exit(EXIT_FAILURE);
    }
    while(getline(ifs, line)){
        elems = split_nonempty(line, ' ');
        int text_offset_idx = 0;
        if(elems.size() >= 2 && elems[1].compare(".text") == 0){
            text_offset_idx = 3;
        }else if(elems.size() >= 3 && elems[2].compare(".text") == 0){
            text_offset_idx = 4;
        }
        if(text_offset_idx){
            //text_offset = stoll(elems[text_offset_idx], 0, 16);
            getline(ifs, line);
            elems = split_nonempty(line, ' ');
            text_size = stoll(elems[0], 0, 16);
            //DEBRT_PRINTF("text_offset is: 0x%llx\n", text_offset);
            errs() << "text_size is: " << text_size << "\n";
            break;
        }
    }
    ifs.close();
    //if(text_size == 0 || text_offset == 0){
    if(text_size == 0){
        //fprintf(stderr, "ERROR: text size and offset should be non-zero\n");
        fprintf(stderr, "ERROR: text size should be non-zero\n");
        exit(1);
    }
}
void WholeProgramDebloat::read_readelf(void)
{
    string line;
    ifstream ifs;
    int token_start;
    int token_end;
    int token_count;
    string token;

    enum READELF_COLS {
        RELF_NUM = 0,
        RELF_VALUE,
        RELF_SIZE,
        RELF_TYPE,
        RELF_BIND,
        RELF_VIS,
        RELF_NDX,
        RELF_NAME
    };
    int idx;
    int which_token;
    string func_name;
    long long func_addr;
    long func_size;

    ifs.open("readelf.out");
    if(!ifs.is_open()){
        perror("Error opening readelf file");
        exit(EXIT_FAILURE);
    }

    while(getline(ifs, line)){

        token_count = 0;
        idx = 0;
        while(idx < line.size() && line.at(idx) != '\n'){
            //DEBRT_PRINTF("%c", line.at(idx));
            //idx++;
            while(idx < line.size() && line.at(idx) == ' '){
                idx++;
            }
            token_start = idx;
            while(idx < line.size() && line.at(idx) != ' ' && line[idx] != '\n'){
                idx++;
            }
            token_end = idx;
            token = line.substr(token_start, token_end - token_start);

            which_token = token_count;

            // func addr
            if(which_token == RELF_VALUE){
                func_addr = strtoll(token.c_str(), NULL, 16);

            }else if(which_token == RELF_SIZE){
                // infer base by passing "0". almost always 10 but ive seen 16
                // in at least one perlbench function
                func_size = strtol(token.c_str(), NULL, 0);

            // func name
            }else if(which_token == RELF_NAME){
                func_name = token;
                readelf_func_name_to_size[func_name] = func_size;
            }
            token_count++;
        }
        //cout << endl;
    }
    ifs.close();
}

bool WholeProgramDebloat::doFinalization(Module &M)
{
    dump_encompassed_funcs();
    dump_static_reachability();
    dump_loop_static_reachability();
    dump_func_name_to_id();
    dump_func_ptrs();
    dump_loop_id_to_func_id();
    dump_sink_id_to_func_id();
    dump_sinks();
    dump_disjoint_sets();
    dump_stats();
    return false;
}
bool WholeProgramDebloat::doInitialization(Module &M)
{
    // XXX don't use this to initialize shit unless you want it to wig out
    return false;
}

char WholeProgramDebloat::ID = 0;
static RegisterPass<WholeProgramDebloat> Y("WholeProgramDebloat", "Whole program debloat pass");
