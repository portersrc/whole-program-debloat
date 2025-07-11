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
#include "llvm/Transforms/Utils/Cloning.h"

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


#define INDIRECT_CALL_SINKING true
#define ENABLE_RELEASE_TRACE_INSTRUMENTATION false

#define MAX_VARARGS_SUPPORTED 5


static inline
long timestamp_ns(void)
{
    struct timespec tv = {0};
    if(clock_gettime(CLOCK_MONOTONIC, &tv) != 0){
        fprintf(stderr, "ERROR timestamp_ns(): clock_gettime returned non-0\n");
        exit(1); // FIXME
        return -1;
    }
    return tv.tv_sec * 1000000000 + tv.tv_nsec;

    //struct timeval tv;
    //gettimeofday(&tv, NULL);
    //return (tv.tv_sec * 1000000000) + (tv.tv_usec * 1000);
}


typedef struct{
    long id;
    set<Function *> *s;
}disjoint_set_t;

typedef enum{
    ARTD_BUILD_STATIC_E = 0,
    ARTD_BUILD_PROFILE_E,
    ARTD_BUILD_TEST_PREDICT_E,
    ARTD_BUILD_RELEASE_E,
    ARTD_BUILD_DATALOG_E,
    ARTD_BUILD_MAYMUST_E,
}artd_build_e;


bool ENABLE_INSTRUMENTATION_SINKING = false; // can set via command line option below
cl::opt<bool> EnableInstrumentationSinking(
    "enable-instrumentation-sinking", cl::init(false), cl::Hidden,
    cl::desc("Attempts to sink instrumentation into loops."));
bool ENABLE_BASIC_INDIRECT_CALL_STATIC_ANALYSIS = false; // can set via command line option below
cl::opt<bool> EnableBasicIndirectCallStaticAnalysis(
    "enable-basic-indirect-call-static-analysis", cl::init(false), cl::Hidden,
    cl::desc("Attempts to apply basic static analysis to indirect calls for mapping them at loop headers."));
artd_build_e ARTD_BUILD = ARTD_BUILD_STATIC_E; // can set via command line option below
cl::opt<string> ARTDBuild(
    "artd-build", cl::init("static"), cl::Hidden,
    cl::desc("The kind of build for this artd compilation: " \
             "static, profile, test_predict, or release"));




namespace {
    struct AdvancedRuntimeDebloat : public ModulePass {
        static char ID;

        AdvancedRuntimeDebloat() : ModulePass(ID) {}

        Function *debrt_init_func;
        Function *debrt_destroy_func;
        Function *debrt_protect_single_func;
        Function *debrt_protect_single_end_func;
        Function *debrt_protect_reachable_func;
        Function *debrt_protect_reachable_end_func;
        Function *debrt_protect_loop_func;
        //Function *debrt_protect_loop_end_func;
        Function *debrt_protect_indirect_func;
        Function *debrt_protect_indirect_end_func;
        Function *debrt_protect_sink_func;
        Function *debrt_protect_sink_end_func;
        Function *debrt_profile_trace_func;
        Function *debrt_profile_print_args_funcs[MAX_VARARGS_SUPPORTED+1];
        Function *debrt_profile_print_args_0_func;
        Function *debrt_profile_print_args_1_func;
        Function *debrt_profile_print_args_2_func;
        Function *debrt_profile_print_args_3_func;
        Function *debrt_profile_print_args_4_func;
        Function *debrt_profile_print_args_5_func;
        Function *debrt_profile_indirect_print_args_funcs[MAX_VARARGS_SUPPORTED+1];
        Function *debrt_profile_indirect_print_args_0_func;
        Function *debrt_profile_indirect_print_args_1_func;
        Function *debrt_profile_indirect_print_args_2_func;
        Function *debrt_profile_indirect_print_args_3_func;
        Function *debrt_profile_indirect_print_args_4_func;
        Function *debrt_profile_indirect_print_args_5_func;
        Function *debrt_profile_update_recorded_funcs_func;
        Function *debrt_test_predict_trace_func;
        Function *debrt_test_predict_predict_funcs[MAX_VARARGS_SUPPORTED+1];
        Function *debrt_test_predict_predict_0_func;
        Function *debrt_test_predict_predict_1_func;
        Function *debrt_test_predict_predict_2_func;
        Function *debrt_test_predict_predict_3_func;
        Function *debrt_test_predict_predict_4_func;
        Function *debrt_test_predict_predict_5_func;
        Function *debrt_test_predict_indirect_predict_funcs[MAX_VARARGS_SUPPORTED+1];
        Function *debrt_test_predict_indirect_predict_0_func;
        Function *debrt_test_predict_indirect_predict_1_func;
        Function *debrt_test_predict_indirect_predict_2_func;
        Function *debrt_test_predict_indirect_predict_3_func;
        Function *debrt_test_predict_indirect_predict_4_func;
        Function *debrt_test_predict_indirect_predict_5_func;
        Function *debrt_release_predict_funcs[MAX_VARARGS_SUPPORTED+1];
        Function *debrt_release_predict_0_func;
        Function *debrt_release_predict_1_func;
        Function *debrt_release_predict_2_func;
        Function *debrt_release_predict_3_func;
        Function *debrt_release_predict_4_func;
        Function *debrt_release_predict_5_func;
        Function *debrt_release_indirect_predict_funcs[MAX_VARARGS_SUPPORTED+1];
        Function *debrt_release_indirect_predict_0_func;
        Function *debrt_release_indirect_predict_1_func;
        Function *debrt_release_indirect_predict_2_func;
        Function *debrt_release_indirect_predict_3_func;
        Function *debrt_release_indirect_predict_4_func;
        Function *debrt_release_indirect_predict_5_func;
        Function *ics_static_map_indirect_call_func;
        Function *ics_static_wrapper_debrt_protect_loop_end_func;
        Function *ics_profile_map_indirect_call_funcs[MAX_VARARGS_SUPPORTED+1];
        Function *ics_profile_map_indirect_call_0_func;
        Function *ics_profile_map_indirect_call_1_func;
        Function *ics_profile_map_indirect_call_2_func;
        Function *ics_profile_map_indirect_call_3_func;
        Function *ics_profile_map_indirect_call_4_func;
        Function *ics_profile_map_indirect_call_5_func;
        Function *ics_profile_end_indirect_call_func;
        Function *ics_profile_wrapper_debrt_protect_loop_end_func;
        Function *ics_test_predict_map_indirect_call_funcs[MAX_VARARGS_SUPPORTED+1];
        Function *ics_test_predict_map_indirect_call_0_func;
        Function *ics_test_predict_map_indirect_call_1_func;
        Function *ics_test_predict_map_indirect_call_2_func;
        Function *ics_test_predict_map_indirect_call_3_func;
        Function *ics_test_predict_map_indirect_call_4_func;
        Function *ics_test_predict_map_indirect_call_5_func;
        Function *ics_test_predict_wrapper_debrt_protect_loop_end_func;
        Function *ics_release_map_indirect_call_funcs[MAX_VARARGS_SUPPORTED+1];
        Function *ics_release_map_indirect_call_0_func;
        Function *ics_release_map_indirect_call_1_func;
        Function *ics_release_map_indirect_call_2_func;
        Function *ics_release_map_indirect_call_3_func;
        Function *ics_release_map_indirect_call_4_func;
        Function *ics_release_map_indirect_call_5_func;
        Function *ics_release_wrapper_debrt_protect_loop_end_func;
        Function *ics_release_wrapper_debrt_protect_reachable_end_func;
        Function *ics_release_wrapper_debrt_protect_indirect_end_func;
        Function *ics_release_rectify_func;
        Function *ics_release_trace_func;
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
        map<long, set<Function *> *> disjoint_sets;
        map<Function *, disjoint_set_t> func_to_disjoint_set;
        map<int, int> loop_id_to_func_id;
        set<string> func_name_has_addr_taken;
        set<Function *> func_has_addr_taken;
        map<Function *, set<Function *> > func_to_fps;
        map<Function *, set<Function *> > func_to_parents;
        map<int, set<int> > sinks; // sink id to its function IDs
        map<int, int> sink_id_to_func_id; // the function ID that holds the sink, for debugging
        map<string, long> readelf_func_name_to_size;
        int deck_id_counter;
        int loop_id_counter;
        int sink_id_counter;
        long long text_size;
        set<string> ics_func_names;
        set<string> libc_nonstatic_func_names;
        map<int, pair<Function *, Function *> > deck_id_to_caller_callee;
        map<int, set<int> > RPs; // caller -> set of callees that need RP

        // Not a map. Index by func set id.
        vector<set<int> > func_set_id_to_funcs;

        // Vector of maps. Vector is indexed by func-set-id. Map is indexed by
        // deck-id. The resulting set holds the complements to
        // func_set_id_to_funcs for that same func-set-id (and corresponding
        // to that particular deck ID).
        vector<map<int, set<Function *> > > func_set_id_to_complements;

        // A vector of func set IDs and deck root pairs that occurred together
        // during profiling.
        vector<pair<int, int> > func_set_id_deck_root_pairs;

        // Support for datalog relations
        map<CallBase *, int> callsite_to_id; // unique IDs for each callsite
        map<int, set<int> > head; // a map from func ID to a set of callsite IDs
        map<int, set<int> > tail; // a map from func ID to a set of callsite IDs
        map<int, set<pair<int, int> > > next; // a map from func ID to a set of callsite ID pairs
        set<int> leaf; // a set of func IDs
        map<int, int> belong; // a map from callsite ID to func ID
        map<BasicBlock *, vector<CallBase *> > block_to_callsites;
        map<Function *, int> func_to_num_calls;
        int total_num_calls;
        int total_antic_calls;

        void getAnalysisUsage(AnalysisUsage &AU) const
        {
            AU.addRequired<LoopInfoWrapperPass>();
        }

        bool runOnModule(Module &M) override;
        bool runOnModule_real(Module &M);
        bool doInitialization(Module &) override;
        bool doFinalization(Module &) override;

        void artd_init(Module &M);
        artd_build_e parseARTDBuildOpt(void);
        void build_basic_structs(Module &M);
        void extend_adj_list(void);
        void build_static_reachability(void);
        //void extend_static_reachability(void);
        void build_func_to_parents(void);
        void extend_encompassed_funcs(void);
        void build_toplevel_funcs(void);
        void create_disjoint_sets(void);
        void finalize_disjoint_sets(void);

        bool instrument_main_start(Module &M);
        bool instrument_main_end(Module &M);
        void instrument_debrt_destroy(Instruction *I);
        void instrument(void);
        void instrument_loop(int func_id, Loop *loop);
        void instrument_loop_sink(int toplevel_func_id, Loop *toplevel_loop);

        int recurse_sink(Function *toplevel_func,
                         set<Function *> &toplevel_bridge_list,
                         set<Function *> &visited_funcs,
                         pair<Function *, CallBase *> parent_func);
        void instrument_after_invoke(InvokeInst *II,
                                     vector<Value *> &ArgsV,
                                     Function *debrt_func,
                                     bool insert_neg1_to_release_trace);
        void instrument_toplevel_func(Function *f, LoopInfo *LI);
        void instrument_indirect_and_external(Function *f, LoopInfo *LI);
        void instrument_external_call(Instruction &I,
                                      bool call_is_outside_loop);
        bool instrument_external_with_callback(Instruction &I,
                                               bool call_is_outside_loop);


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
        void update_disjoint_sets(set<Function *> &new_set);
        void build_RPs(void);
        void instrument_RPs(void);
        void read_func_set_id_deck_root_pairs(void);
        void read_func_set_id_to_funcs(void);


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
        void print_disjoint_sets(void);
        void dump_stats(void);
        void dump_deck_id_to_caller_callee(void);
        void print_func_set_id_deck_root_pairs(void);
        void print_func_set_id_to_funcs(void);
        void dump_RPs(void);
        void dump_func_set_id_to_complements(void);
        void dump_callsite_to_id(void);
        void dump_datalog_relations(void);
        void dump_head(FILE *fp);
        void dump_tail(FILE *fp);
        void dump_next(FILE *fp);
        void dump_leaf(FILE *fp);
        void dump_belong(FILE *fp);
        void dump_last(FILE *fp);
        void dump_ensue(FILE *fp);

        void instrument_feature_pass_deprecated(CallBase *callsite,
                                     Function *parent_func,
                                     Instruction *inst_to_follow,
                                     Function *func_to_instrument,
                                     int func_or_loop_id,
                                     bool insert_neg1_to_release_trace);
        void instrument_feature_pass(CallBase *callsite,
                                     Function *parent_func,
                                     Instruction *inst_to_follow,
                                     Function **funcs_to_instrument,
                                     int func_or_loop_id,
                                     bool insert_neg1_to_release_trace);
        int push_arg(Value *argV, vector<Value *> &ArgsV, IRBuilder<> &builder, bool is_64);
        void fix_up_argsv_for_indirect_deprecated(CallBase *CB,
                                       vector<Value *> &ArgsV,
                                       IRBuilder<> &builder);
        int fix_up_argsv_for_indirect(CallBase *CB,
                                          vector<Value *> &ArgsV,
                                          IRBuilder<> &builder);
        void update_deck_id_to_caller_callee(int deck_id, CallBase *CB, Function *parent);


        void capture_ensue(Module &M);
        void capture_ensue_aux(Function &F);

        void capture_maymust(Module &M);
        void capture_maymust_aux_callbase_notright(Function &F);
        void capture_maymust_aux(Function &F);


    };
}

struct artd_stats{
    int num_toplevel_loops;
    int num_instrumented_basic_loops;
    int num_instrumented_sunk_loops;
    int num_instrumented_sunk_multilevel_loops;
    int sink_fail_no_calles;
    int sink_fail_due_to_visited;
    int sink_fail_thresh_check;
    int num_RPs;
}stats;


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


// This function is responsible for building the RPs map.
// Its only goal is to create a map where the key is a function ID,
// and the value is the set of that function's callees that need to be
// protected by RP instrumentation.
// Intuitively, the map captures all points where execution can flow
// from a function in a predicted set to a function in the complement set
// (complement set = full deck \ prediction set).
//
// This function, and the RPs map that it builds, do not need to know about
// debrt_rectification_flags or anything like this. This is a very important
// point when reviewing or rethinking what's happening here! The RPs map does
// NOT need to capture any "context" like this, because for the purposes of
// _instrumenting RPs_ in this compiler pass, the context is irrelevant. We
// just care that all of the prediction sets that can happen (i.e. which we saw
// in training) have their complement sets protected by RPs. Runtime techniques
// will handle the problem of figuring out which RPs to enable and disable,
// based on context.
//
// Note, by context I mean something like the following: During execution, the
// program may issue two predictions at two completely different callsites,
// e.g. just before calling foo, and just before calling bar. But that
// prediction may turn out to be the same function set ID, i.e. it corresponds
// to the same set of functions, say, A, B, C. But the decks for foo and bar
// may be very different, so despite having two identical predictions --
// meaning we need to enable the same functions -- their complement sets could
// be very different, and hence the RPs that need to be enabled must be
// different. All of that is related to context. All of that context is
// NOT relevant to this function and the RPs map. It will be handled
// elsewhere with runtime techniques.
void AdvancedRuntimeDebloat::build_RPs(void)
{
    read_func_set_id_to_funcs();
    read_func_set_id_deck_root_pairs();

    // May have a func set ID that occurs at multiple deck roots, hence its
    // size is >= func-set-id-to-funcs
    // --update: no longer a safe assumption/assertion. See the parser for the
    // profile log for details, but if pred sets have to be reduced to fit
    // within a deck, "stale" entries can live in the func-set-ids-to-funcs
    // at the moment.
    //assert(func_set_id_deck_root_pairs.size() >= func_set_id_to_funcs.size());
    //print_func_set_id_to_funcs();
    //print_func_set_id_deck_root_pairs();

    func_set_id_to_complements = std::vector<map<int, set<Function *> > >(func_set_id_to_funcs.size());

    for(pair<int, int> func_set_id_deck_root : func_set_id_deck_root_pairs) {

        set<Function *> full_deck;
        set<int> *pred_set_ids;
        set<Function *> pred_set;
        set<Function *> complement_set;
        set<Function *> intersect_set;
        int func_set_id;
        int deck_root_id;
        int deck_root_id_maybe_negative;
        int is_loop_deck;

        // Grab the full deck. It's based off the deck's root
        func_set_id  = func_set_id_deck_root.first;
        deck_root_id = func_set_id_deck_root.second;
        deck_root_id_maybe_negative = deck_root_id;

        is_loop_deck = 0;
        if(deck_root_id < 0){
            is_loop_deck = 1;
        }

        if(!is_loop_deck){
            Function *deck_root_func = func_id_to_func[deck_root_id];
            full_deck = static_reachability[deck_root_func]; // copy
            full_deck.insert(deck_root_func); // necessary only for sanity check below
        }else{
            // loop IDs are encoded as the negative minus 1 of the original.
            // recover the loop ID and grab the loop's deck
            deck_root_id = (deck_root_id * -1) - 1;
            full_deck = loop_static_reachability[deck_root_id];
        }

        // Grab the predicted set.
        // It's just based off the prediction, which is the func-set-id
        // Need to get all the Function *s, though, not just the IDs.
        pred_set_ids = &func_set_id_to_funcs[func_set_id];
        for(int pred_set_id : (*pred_set_ids)){
            pred_set.insert(func_id_to_func[pred_set_id]);
        }

        // Calculate the complement set.
        //   complement_set = full_deck \ pred_set
        set_difference(full_deck.begin(),
                       full_deck.end(),
                       pred_set.begin(),
                       pred_set.end(),
                       inserter(complement_set, complement_set.end()));

        // Calculate the intersection as a sanity check
        set_intersection(full_deck.begin(),
                         full_deck.end(),
                         pred_set.begin(),
                         pred_set.end(),
                         inserter(intersect_set, intersect_set.end()));
        //errs() << "func_set_id: " << func_set_id << "\n";
        //errs() << "full_deck size: " << full_deck.size() << "\n";
        //errs() << "pred_set size: " << pred_set.size() << "\n";
        //errs() << "intersect_set size: " << intersect_set.size() << "\n";
        //errs() << "\n";

        assert(intersect_set == pred_set);

        // If this is a loop, we want the negative value of the deck-root-id
        // so its key doesn't collide with the one for functions. Runtime will
        // also be using this negative value at prediction time, which is
        // what we want.
        func_set_id_to_complements[func_set_id][deck_root_id_maybe_negative] = complement_set;

        //if(func_set_id == 120){
        //    errs() << "Seeing func_set_id 120\n";
        //    errs() << "  deck root id: " << deck_root_id << "\n";
        //    errs() << "  is loop deck? " << is_loop_deck << "\n";
        //    errs() << "  full_deck:\n    ";
        //    for(auto it = full_deck.begin(); it != full_deck.end(); it++){
        //        errs() << func_to_id[*it] << ",";
        //    }
        //    errs() << "  pred_set:\n    ";
        //    for(auto it = pred_set.begin(); it != pred_set.end(); it++){
        //        errs() << func_to_id[*it] << ",";
        //    }
        //    errs() << "  complements:\n    ";
        //    for(auto it = complement_set.begin(); it != complement_set.end(); it++){
        //        errs() << func_to_id[*it] << ",";
        //    }
        //    errs() << "\n";
        //}

        if(is_loop_deck){
            // XXX Edge case (and a bit of a hack): This is to ensure we insert
            // RPs in the loop's host function. When deciding whether to insert
            // into the RPs map further down below, we just look at the callees
            // of the pred-set functions. But because of that, the callees from
            // the loop's /host/ function might get missed. To correct for
            // that, this pred_set.insert() call will insert the function ID of
            // the function where the loop lives.  This forces us to examine
            // its adj-list further down below, which catches any calles not in
            // the pred set. This doesn't matter for non-loop decks, because
            // the pred set includes the root of the deck. (Runtime's
            // _release_predict() will hard fail if we mess this up, too.) The
            // adj list of the loop's host function could include function
            // calls outside of our loop, or in other loops; the same callees
            // could be in multiple toplevel loops of our host function.
            // When we instrument_RPs(), we'll at least make sure that when
            // we instrument a non-encompassed function that the callee
            // is within a loop. In any case, I think this is a non-issue --
            // perhaps accuracy mistake but not a correctness mistake. (Would
            // need a deeper think for considering how this could all shake
            // out, e.g. callees in the host function that aren't in the loop
            // but are encompassed (i.e. within another loop) vs. callees that
            // just live outside of any loops but are still called by the host,
            // etc. Should be safe to ignore for now.)
            pred_set.insert(func_id_to_func[loop_id_to_func_id[deck_root_id]]);
        }else{
            // Do it anyway for the deck root, too. It should already be in the
            // pred set, but just in case...
            pred_set.insert(func_id_to_func[deck_root_id]);
        }

        for(Function *caller : pred_set){
            int caller_id = func_to_id[caller];
            // assert that one of the following is true:
            // 1. this caller_id is in the pred-set-ids, or
            // 2. that it's a loop case and the caller id is actually
            //    the id of the loop's host function, or
            // 3. that it's a func case and the caller id is actually
            //    the id of the deck root function.
            assert(pred_set_ids->find(caller_id) != pred_set_ids->end()
                || caller_id == loop_id_to_func_id[deck_root_id]
                || caller_id == deck_root_id);
            for(Function *callee : adj_list[caller]){
                int callee_id = func_to_id[callee];
                if(complement_set.find(callee) != complement_set.end()){
                    RPs[caller_id].insert(callee_id);
                }
            }
        }
    }
}


void AdvancedRuntimeDebloat::instrument_RPs(void)
{
    errs() << "Instrumenting RPs\n";
    for(auto it = RPs.begin(); it != RPs.end(); it++){

        int caller_func_id = it->first;
        set<int> &callees_to_rectify = it->second;
        Function *caller = func_id_to_func[caller_func_id];

        // We shouldn't have RPs at any prediction points -- just shouldn't
        // happen. There are more precise ways to check it, but one good sanity
        // check is to make sure the caller in every RP is encompassed.
        // Predictions should only happen at outermost loops and at reachable
        // decking sites. (There are also indirect calls inside of loops, but
        // those won't show up here because of a lack of callee func ID.) Thus,
        // we can at least assert that encompassed funcs contains the caller's
        // func ID.
        // UPDATE: backing this assertion out, because build_RPs also has
        // the toplevel funcs that have loops right now. So we'd have to
        // track those loop cases and ignore those here. Also, this gets
        // into cases where the loop's host function has a callee that is
        // both in a loop (and needs an RP) and the same callee at a different
        // callsite further down that's not in the loop. Or the same callee
        // may be in two different outermost loops and called by that same
        // toplevel loop host function. But in all of these cases, it should
        // be fine for now. Extra RPs is imprecise but not a correctness issue.
        //assert(encompassed_funcs.find(func_id_to_func[caller_func_id]) != encompassed_funcs.end());

        LoopInfo *LI = &getAnalysis<LoopInfoWrapperPass>(*caller).getLoopInfo();

        bool caller_is_encompassed = true;
        if(encompassed_funcs.find(caller) == encompassed_funcs.end()){
            caller_is_encompassed = false;
        }

        for(auto &b : *caller){
            bool block_is_inside_loop = false;
            if(LI && LI->getLoopFor(&b)){
                block_is_inside_loop = true;
            }
            for(auto &I : b){
                CallBase *CB = dyn_cast<CallBase>(&I);
                if(CB){
                    Function *callee = CB->getCalledFunction();
                    int callee_func_id = func_to_id[callee];

                    // We only instrument a rectification point if, for this
                    // caller, we marked this edge/callee as needing it.
                    if(callees_to_rectify.find(callee_func_id) != callees_to_rectify.end()){
                        // More subtle check: all rectification points ought
                        // to be either
                        // 1. inside encompassed functions, or
                        // 2. inside of toplevel loops of non-encompassed funcs
                        if(caller_is_encompassed || block_is_inside_loop){
                            // instrument RP before callee
                            vector<Value *> ArgsV;
                            ArgsV.push_back(ConstantInt::get(int32Ty, callee_func_id, false));
                            IRBuilder<> builder(CB);
                            CallInst *ci = builder.CreateCall(ics_release_rectify_func, ArgsV);
                            stats.num_RPs++;
                        }
                    }
                }
            }
        }
    }
}


// Read the all the unique pairs of func set IDs and their corresponding deck
// root IDs into an array, func_set_id_deck_root_pairs.
// Each element is a unique pair of a func set ID and the ID (function
// or loop ID) that can be the deck root of that set. The "deck root"
// is just the first function that executes in the deck (which establishes
// reachability), or, in the case of a loop, it's the loop itself, which
// also establishes reachability.
//
// Example file (which is created by parse_artd_profile_log.py):
//   func_set_id,deck_root
//   0,-1
//   1,-6
//   2,-3
//   2,98
//   3,67
//   4,59
void AdvancedRuntimeDebloat::read_func_set_id_deck_root_pairs(void)
{
    string line;
    ifstream ifs;
    vector<string> elems;
    int func_set_id;
    int deck_root_id;

    ifs.open("func-set-id-deck-root-pairs.out");
    if(!ifs.is_open()) {
        fprintf(stderr, "ERROR: Failed to open func-set-id-deck-root-pairs.out.\n");
        exit(EXIT_FAILURE);
    }

    getline(ifs, line); // parse out the header

    while(getline(ifs, line)){
        vector<int> func_ids;
        elems = split_nonempty(line, ',');
        func_set_id  = atoi(elems[0].c_str());
        deck_root_id = atoi(elems[1].c_str());
        func_set_id_deck_root_pairs.push_back(make_pair(func_set_id, deck_root_id));
    }

    ifs.close();
}


//
// TODO This is a copy-paste of code from the debloat_rt.cpp (see
// _read_func_sets()).
// 2023.06.01 UPDATE: not quite the same anymore. This version has to
// call update_disjoint_sets().
//
// Read the all func set IDs and their corresponding func IDs into an array
// of sets called "func_sets". func_sets is indexed by the func set ID. Each
// element is a set of integers, which are the function IDs of that func set.
//
// Example file (which is created by parse_artd_profile_log.py):
//   predicted_func_set_id,called_func_id1,called_func_id2,...
//   0,114
//   1,92
//   2,98
//   3,16,22,67
void AdvancedRuntimeDebloat::read_func_set_id_to_funcs(void)
{
    int i;
    int k;
    string line;
    ifstream ifs;
    vector<string> elems;
    int func_set_id;

    ifs.open("func-set-id-to-funcs.out");
    if(!ifs.is_open()) {
        fprintf(stderr, "ERROR: Failed to open func-set-id-to-funcs.out.\n");
        exit(EXIT_FAILURE);
    }

    // Construct "func_set_id_to_funcs". It's not a map. It's a vector.
    // It's indexed by func set ID.  Each element is a a set of function IDs
    // that is part of that prediction set.
    i = 0;
    getline(ifs, line); // parse out the header

    while(getline(ifs, line)){
        vector<int> func_ids;
        set<Function *> temp;
        elems = split_nonempty(line, ',');
        func_set_id = atoi(elems[0].c_str());
        assert(func_set_id == i);
        for(k = 1; k < elems.size(); k++){
            int func_id = atoi(elems[k].c_str());
            func_ids.push_back(func_id);
            temp.insert(func_id_to_func[func_id]);
        }
        set<int> func_id_set(func_ids.begin(), func_ids.end());
        func_set_id_to_funcs.push_back(func_id_set);
        update_disjoint_sets(temp);
        i++;
    }

    ifs.close();
}




void AdvancedRuntimeDebloat::update_deck_id_to_caller_callee(int deck_id,
                                                             CallBase *CB,
                                                             Function *parent)
{
    // If CB is non-NULL, then ignore parent.
    // (And if CB is NULL, then parent is a valid arg.)
    Function *caller;
    Function *callee;
    if(CB){
        caller = CB->getCaller();
        callee = CB->getCalledFunction();
    }else{
        caller = parent;
        callee = NULL;
    }
    deck_id_to_caller_callee[deck_id] = make_pair(caller, callee);
}


void AdvancedRuntimeDebloat::get_callees_aux(vector<pair<Function *, CallBase *> > &callees,
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
void AdvancedRuntimeDebloat::get_callees(pair<Function *, CallBase *> parent_func,
                                      vector<pair<Function *, CallBase *> > &callees)
{
    for(auto &B : *(parent_func.first)){
        for(auto &I : B){
            get_callees_aux(callees, I);
        }
    }
}
void AdvancedRuntimeDebloat::get_callees(Loop *loop,
                                      vector<pair<Function *, CallBase *> > &callees)
{
    for(auto B : loop->getBlocks()){
        for(auto &I : (*B)){
            get_callees_aux(callees, I);
        }
    }
}

int AdvancedRuntimeDebloat::get_set_byte_size(set<Function *> &functions)
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
void AdvancedRuntimeDebloat::get_address_taken_uses(Function &F, vector<User *> &offenders)
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


bool AdvancedRuntimeDebloat::sinking_condition_satisfied(vector<pair<Function *, CallBase *> > &callees,
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

void AdvancedRuntimeDebloat::instrument_sink_point(pair<Function *, CallBase *> parent_func,
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
        instrument_after_invoke(II, ArgsV, debrt_protect_sink_end_func, false);
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
    update_disjoint_sets(temp);
    sink_id_to_func_id[sink_id] = func_to_id[parent_func.first]; // for debugging
}


int AdvancedRuntimeDebloat::iterative_sink(set<Function *> &toplevel_bridge_list,
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




void AdvancedRuntimeDebloat::instrument_loop_sink(int toplevel_func_id,
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


void AdvancedRuntimeDebloat::instrument_loop(int func_id, Loop *loop)
{
    //
    // XXX All this code is intentionally crammed in here. 'loop' is, I think,
    // an object address from getLoopInfo() that poofs. So we don't want to
    // rely on its address as a map key anywhere (like we might for a Fuction
    // or BasicBlock object).
    // 

    int loop_id = loop_id_counter;
    //if(loop_id == 27){
    //    errs() << "Seeing loop id 27\n";
    //}
    bool has_toplevel_indirect_call = false;

    // Find preheader
    BasicBlock *preheader = loop->getLoopPreheader();
    assert(preheader); // must run -loop-simplify for this to be OK.

    //if(loop_id == 27){
    //    errs() << "Starting to prime loop-static-reachability\n";
    //}
    // Prime loop_static_reachability with any callees in our loops
    for(auto &B : loop->getBlocks()){
        for(auto &I : (*B)){
            CallBase *cb = dyn_cast<CallBase>(&I);
            if(cb){
                Function *callee = cb->getCalledFunction();
                //if(loop_id == 27){
                //    errs() << "Seeing a function call\n";
                //}
                // Normal callee: just prime this loop's static reachability
                // with it.
                if(func_to_id.count(callee) > 0){
                    //if(loop_id == 27){
                    //    errs() << "inserting callee into loop static reachability\n";
                    //}
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
                if(INDIRECT_CALL_SINKING){
                    if(cb->getCalledFunction() == NULL){
                        //if(loop_id == 27){
                        //    errs() << "has toplevel indirect call case\n";
                        //}
                        has_toplevel_indirect_call = true;
                    }
                }
            }
        }
    }
    //if(loop_id == 27){
    //    errs() << "Done priming\n";
    //}

    // If there was at least one function call inside the loop, then we
    // will instrument it.
    // Note: If the only call/calls was/were indirect, then we could end up
    // with a loop-id that has no reachable functions. That's ok. The runtime
    // library can handle it.
    if(loop_static_reachability.find(loop_id) != loop_static_reachability.end()
    || has_toplevel_indirect_call){
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
        //errs() << "instrumenting loop id " << loop_id << "\n";
        ArgsV.push_back(ConstantInt::get(int32Ty, loop_id, false));

        // instrument the preheader of the loop
        Instruction *TI = preheader->getTerminator();
        assert(TI);
        assert(debrt_protect_loop_func);
        if(ARTD_BUILD != ARTD_BUILD_RELEASE_E){
            IRBuilder<> builder(TI);
            CallInst *ci = builder.CreateCall(debrt_protect_loop_func, ArgsV);
            if(ARTD_BUILD == ARTD_BUILD_PROFILE_E){
                instrument_feature_pass(NULL, func_id_to_func[func_id], ci, debrt_profile_print_args_funcs, loop_id, false);
            }else if(ARTD_BUILD == ARTD_BUILD_TEST_PREDICT_E){
                instrument_feature_pass(NULL, func_id_to_func[func_id], ci, debrt_test_predict_predict_funcs, loop_id, false);
            }
        }else{
            instrument_feature_pass(NULL, func_id_to_func[func_id], TI, debrt_release_predict_funcs, loop_id, false); // false because this is a loop
        }

        //Set of functions debloated within loop (Sharjeel)
        // cporter update: added check in case 0-element case matters
        if(loop_static_reachability[loop_id].size() > 0){
            update_disjoint_sets(loop_static_reachability[loop_id]);
        }
        // errs() << "Inserted library function within preheader(" << preheader->getName().str() << "\n";

        // instrument the exit(s) block(s) of the loop
        SmallVector<BasicBlock *, 8> exit_blocks;
        loop->getUniqueExitBlocks(exit_blocks);

        // dont assert. can refer to https://llvm.org/docs/LoopTerminology.html
        // statically infinite loop is possible. we just won't instrument exits in
        // that case
        //assert(exit_blocks.size() > 0);

        for(auto exit_block : exit_blocks){
            // cporter 2022.11.16 change: Seems we want firstinsertionpt here,
            // no? Previously:
            //   Instruction *ebt = exit_block->getTerminator();
            // LLVM can put more function calls (which need decking) inside
            // an exit block, and we want to close out the loop stuff before
            // that happens. Also, getFirstNonPhi() doesn't seem to work
            // because if a landing pad is required in that exit block,
            // the landing pad apparently needs to be the first non-phi instr
            // (otherwise compilation breaks).
            auto ebt_it = exit_block->getFirstInsertionPt();
            Instruction *ebt = &(*ebt_it);
            assert(ebt);
            IRBuilder<> builder_exit(ebt);
            //builder_exit.CreateCall(debrt_protect_loop_end_func, ArgsV);
            if(ARTD_BUILD == ARTD_BUILD_STATIC_E){
                builder_exit.CreateCall(ics_static_wrapper_debrt_protect_loop_end_func, ArgsV);
            }else if(ARTD_BUILD == ARTD_BUILD_PROFILE_E){
                builder_exit.CreateCall(ics_profile_wrapper_debrt_protect_loop_end_func, ArgsV);
            }else if(ARTD_BUILD == ARTD_BUILD_TEST_PREDICT_E){
                builder_exit.CreateCall(ics_test_predict_wrapper_debrt_protect_loop_end_func, ArgsV);
            }else if(ARTD_BUILD == ARTD_BUILD_RELEASE_E){
                builder_exit.CreateCall(ics_release_wrapper_debrt_protect_loop_end_func, ArgsV);
            }else{
                assert(0 && "TODO: Implement missing artd-build and remove this");
            }
        }

        // Note which function this loop is associated with
        loop_id_to_func_id[loop_id] = func_id;

        // Bump our ID counter
        loop_id_counter++;
    }

}


void AdvancedRuntimeDebloat::extend_encompassed_funcs(void)
{
    errs() << "Extending encompassed funcs\n";
    for(auto F : func_has_addr_taken){
        encompassed_funcs.insert(F);
    }
    for(auto F : encompassed_funcs){
        for(auto reachable_func : static_reachability[F]){
            encompassed_funcs.insert(reachable_func);
        }
    }
}


void AdvancedRuntimeDebloat::instrument_after_invoke(InvokeInst *II,
                                                  vector<Value *> &ArgsV,
                                                  Function *debrt_func,
                                                  bool insert_neg1_to_release_trace)
{
    if(II->getCalledFunction()){
        //errs() << "function called: " << II->getCalledFunction()->getName() << "\n";
    }else{
        //errs() << "getCalledFunction() is returning null so perhaps "
        //<< "indirect invocations complicate the number of successors.\n";
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
        // FIXME ? updated note on this: seems like dead code, b/c there
        // should not be landing pad for the normal-destination case. It's
        // only for the unwind case. Leaving b/c of uncertainy and it's how
        // it used to work. Can fix when we do the TODO below
        builder_end.SetInsertPoint(ndi->getNextNode());
    }
    CallInst *ci = builder_end.CreateCall(debrt_func, ArgsV);
    if(ENABLE_RELEASE_TRACE_INSTRUMENTATION && insert_neg1_to_release_trace){
        vector<Value *> ArgsV2;
        IRBuilder<> builder2(ci);
        ArgsV2.push_back(ConstantInt::get(int32Ty, -1, false));
        builder2.CreateCall(ics_release_trace_func, ArgsV2);
    }


    //
    //
    // TODO: Support for instrumentation on the unwind case.
    // Right now I have a bunch of garbage trial-and-error code below. I was
    // last working with that cloned_bb idea below. I think it could work,
    // but I needed a way to change the successors and predecessors of
    // the basic blocks. The API doesn't seem to have much support for
    // the BBs, but it does allow things like changing the successor
    // of a terminating instruction. See Instruction's getNumSuccessors,
    // getSuccesor, and setSuccessor().
    // I'm leaving this as unimplemented for now b/c we don't have to worry
    // about benchmarks that are constantly throwing and catching exceptions.
    // Without completing this, however, we could run into a benchmark where
    // exceptions are commonly thrown and caught, and because we don't
    // instrument the unwind case here, our security gradually gets worse.
    //
    //
    //BasicBlock *orig_normal_dest = II->getNormalDest();
    //BasicBlock *new_bb_normal = SplitEdge(II->getParent(), II->getNormalDest());

    //BasicBlock *pred_bb = new_bb_normal->getUniquePredecessor();
    //assert(pred_bb);
    //if(new_bb_normal == II->getParent()){
    //    errs() << "new_bb_normal is the 'from'\n";
    //}else if(new_bb_normal == II->getNormalDest()){
    //    errs() << "new_bb_normal is the 'to'\n";
    //}else{
    //    errs() << "new_bb_normal is in the middle\n";
    //}
    //BasicBlock *post_normal_dest = II->getNormalDest();

    ////if(orig_normal_dest == post_normal_dest){
    ////    assert(0 && "orig and post are the same");
    ////}else{
    ////    assert(0 && "orig and post are different");
    ////}


    //Instruction *ndi = II->getNormalDest()->getFirstNonPHI();
    ////Instruction *ndi = new_bb->getFirstNonPHI();
    ////Instruction *ndi = pred_bb->getFirstNonPHI();
    ////for(auto &I : *new_bb){
    ////    errs() << I << "\n";
    ////}
    //if(ndi == NULL){
    //    // unexpected, though the API allows getFirstNonPHI to be null.
    //    // assert 0 for now and handle only if we encounter it.
    //    errs() << "ndi is null\n";
    //    assert(0);
    //}
    //IRBuilder<> builder_end(ndi);
    //// TODO: What does this SetInsertPoint do, again?
    //// Seems not to affect the instrumentation.
    //if(dyn_cast<LandingPadInst>(ndi)){
    //    errs() << "setting ndi insert point" << "\n";
    //    builder_end.SetInsertPoint(ndi->getNextNode());
    //}else{
    //    errs() << "dyn_cast to LandingPadInst failed. Did not set ndi insert point\n";
    //}
    //builder_end.CreateCall(debrt_func, ArgsV);

    //errs() << "before\n";
    //II->getUnwindDest()->dump();
    //errs() << "after\n";

    //ValueToValueMapTy VMap;
    //BasicBlock *cloned_bb = CloneBasicBlock(II->getUnwindDest(), VMap);
    //cloned_bb->insertInto(II->getUnwindDest()->getParent(), II->getUnwindDest());

    //errs() << "before\n";
    //cloned_bb->dump();
    //errs() << "after\n";

    //if(II->getUnwindDest() == II->getNormalDest()){
    //    assert(0 && "Weird. unwind and normal match");
    //}else{
    //    assert(0 && "unwind and normal are different");
    //}

    //// Handle the unwind case.
    //// TODO: remove boilerplate. matches the getNormalDest() code just above.
    //BasicBlock *new_bb_unwind = SplitEdge(II->getParent(), II->getUnwindDest());
    //Instruction *udi = II->getUnwindDest()->getFirstNonPHI();
    //if(udi == NULL){
    //    // unexpected, though the API allows getFirstNonPHI to be null.
    //    // assert 0 for now and handle only if we encounter it.
    //    errs() << "udi is null\n";
    //    assert(0);
    //}
    //IRBuilder<> builder_end_unwind(udi);
    //if(dyn_cast<LandingPadInst>(udi)){
    //    errs() << "setting udi insert point" << "\n";
    //    builder_end_unwind.SetInsertPoint(udi->getNextNode());
    //}else{
    //    errs() << "dyn_cast to LandingPadInst failed. Did not set udi insert point\n";
    //}
    //builder_end_unwind.CreateCall(debrt_func, ArgsV);

}


void AdvancedRuntimeDebloat::fix_up_argsv_for_indirect_deprecated(CallBase *CB,
                                                       vector<Value *> &ArgsV,
                                                       IRBuilder<> &builder)
{
    // ArgsV currently just has the target address of the function pointer,
    // which resides at element 0.
    assert(ArgsV.size() == 1);

    // We want ArgsV to have:
    // element 0: argc
    // element 1: fp-addr
    // element 2: deck-id
    // element 3: deck arg0 (optional)
    // element 4: deck arg1 (optional)
    // element m: deck argn (optional)
    //
    // In this case the deck args are arguments to the function pointer.

    // element 1 gets the fp-addr (which is at element 0 for now).
    ArgsV.push_back(ArgsV[0]);

    // element 2 gets the deck ID
    ArgsV.push_back(llvm::ConstantInt::get(int64Ty, deck_id_counter, false));
    update_deck_id_to_caller_callee(deck_id_counter, CB, NULL);
    deck_id_counter++;

    // remaining elements are arguments to the function pointer call
    for(auto it_arg = CB->arg_begin(); it_arg != CB->arg_end(); it_arg++){
        push_arg((Value *) *it_arg, ArgsV, builder, true);
    }

    // element 0 is number of elements that follow
    // Notice that it should always be >=2 (b/c of fp-addr and deck id).
    assert((ArgsV.size() - 1) >= 2);
    ArgsV[0] = llvm::ConstantInt::get(int64Ty, ArgsV.size() - 1, false);
}
int AdvancedRuntimeDebloat::fix_up_argsv_for_indirect(CallBase *CB,
                                                           vector<Value *> &ArgsV,
                                                           IRBuilder<> &builder)
{
    // ArgsV currently just has the target address of the function pointer,
    // which resides at element 0.
    assert(ArgsV.size() == 1);

    // We want ArgsV to have:
    // element 0: fp-addr
    // element 1: deck-id
    // element 3: deck arg1 (optional)
    // element 4: deck arg2 (optional)
    // element 5: deck arg3 (optional)
    // element 6: deck arg4 (optional)
    // element 7: deck arg5 (optional)
    //
    // In this case the deck args are arguments to the function pointer.

    // element 1 gets the deck ID
    ArgsV.push_back(llvm::ConstantInt::get(int64Ty, deck_id_counter, false));
    update_deck_id_to_caller_callee(deck_id_counter, CB, NULL);
    deck_id_counter++;

    int num_args_pushed = 0;

    // remaining elements are arguments to the function pointer call
    for(auto it_arg = CB->arg_begin(); it_arg != CB->arg_end(); it_arg++){
        num_args_pushed += push_arg((Value *) *it_arg, ArgsV, builder, true);
        if(num_args_pushed == MAX_VARARGS_SUPPORTED){
            break;
        }
    }
    return num_args_pushed;
}


void AdvancedRuntimeDebloat::instrument_indirect_and_external(Function *f, LoopInfo *LI)
{
    //errs() << "Instrumenting indirect and external for " << f->getName().str() << "\n";
    for(auto &b : *f){
        bool f_is_not_encompassed
          = encompassed_funcs.find(f) == encompassed_funcs.end();
        bool block_is_outside_loop = true;
        if(LI && LI->getLoopFor(&b)){
            block_is_outside_loop = false;
        }
        for(auto &I : b){
            CallBase   *CB = dyn_cast<CallBase>(&I);
            CallInst   *CI = dyn_cast<CallInst>(&I);
            InvokeInst *II = dyn_cast<InvokeInst>(&I);
            if(CB){
                Function *cf = CB->getCalledFunction();
                // INDIRECT_CALL_SINKING ensures that 
                // we instrument indirect calls now. This is
                // probably as it should have been from the start, because old
                // artd approaches just turned on the transitive closure of all
                // func pointers.
                if(cf == NULL && INDIRECT_CALL_SINKING){
                    //errs() << "seeing indirect function call\n";
                    Value *v = CB->getCalledOperand();
                    if(dyn_cast<InlineAsm>(v)){
                        // ignore inline assembly... don't instrument
                        continue;
                    }
                    if(v->getType()->isPointerTy()){
                        // instrument before indirect func call
                        if(f_is_not_encompassed && block_is_outside_loop){
                            vector<Value *> ArgsV;
                            IRBuilder<> builder(CB);
                            ArgsV.push_back(builder.CreatePtrToInt(v, int64Ty));
                            if(ARTD_BUILD != ARTD_BUILD_RELEASE_E){
                                CallInst *ci = builder.CreateCall(debrt_protect_indirect_func, ArgsV);
                                if(ARTD_BUILD == ARTD_BUILD_PROFILE_E){
                                    vector<Value *> VarArgsV;
                                    IRBuilder<> builder2(ci);
                                    VarArgsV.push_back(builder2.CreatePtrToInt(v, int64Ty));
                                    int num_args_pushed = fix_up_argsv_for_indirect(CB, VarArgsV, builder2);
                                    builder2.CreateCall(debrt_profile_indirect_print_args_funcs[num_args_pushed], VarArgsV);
                                }else if(ARTD_BUILD == ARTD_BUILD_TEST_PREDICT_E){
                                    vector<Value *> VarArgsV;
                                    IRBuilder<> builder2(ci);
                                    VarArgsV.push_back(builder2.CreatePtrToInt(v, int64Ty));
                                    int num_args_pushed = fix_up_argsv_for_indirect(CB, VarArgsV, builder2);
                                    builder2.CreateCall(debrt_test_predict_indirect_predict_funcs[num_args_pushed], VarArgsV);
                                }else{
                                    assert(ARTD_BUILD == ARTD_BUILD_STATIC_E);
                                }
                            }else{
                                assert(ARTD_BUILD == ARTD_BUILD_RELEASE_E);
                                vector<Value *> VarArgsV;
                                VarArgsV.push_back(builder.CreatePtrToInt(v, int64Ty));
                                int num_args_pushed = fix_up_argsv_for_indirect(CB, VarArgsV, builder);
                                CallInst *ci = builder.CreateCall(debrt_release_indirect_predict_funcs[num_args_pushed], VarArgsV);
                                if(ENABLE_RELEASE_TRACE_INSTRUMENTATION){
                                    vector<Value *> ArgsV2;
                                    IRBuilder<> builder2(ci);
                                    ArgsV2.push_back(ConstantInt::get(int32Ty, -1, false));
                                    builder2.CreateCall(ics_release_trace_func, ArgsV2);
                                }
                            }

                            // instrument after indirect func call
                            if(CI){
                                IRBuilder<> builder_end(CI);
                                builder_end.SetInsertPoint(CI->getNextNode());
                                if(ARTD_BUILD == ARTD_BUILD_RELEASE_E){
                                    CallInst *ci = builder_end.CreateCall(ics_release_wrapper_debrt_protect_indirect_end_func, ArgsV);
                                    if(ENABLE_RELEASE_TRACE_INSTRUMENTATION){
                                        vector<Value *> ArgsV2;
                                        IRBuilder<> builder2(ci);
                                        ArgsV2.push_back(ConstantInt::get(int32Ty, -1, false));
                                        builder2.CreateCall(ics_release_trace_func, ArgsV2);
                                    }
                                }else{
                                    builder_end.CreateCall(debrt_protect_indirect_end_func, ArgsV);
                                }
                            }else if(II){
                                //errs() << "indirect func invoke case\n";
                                if(ARTD_BUILD == ARTD_BUILD_RELEASE_E){
                                    instrument_after_invoke(II, ArgsV, ics_release_wrapper_debrt_protect_indirect_end_func, true);
                                }else{
                                    instrument_after_invoke(II, ArgsV, debrt_protect_indirect_end_func, false);
                                }
                            }else{
                                assert(0);
                            }

                        }else{
                            vector<Value *> ArgsV;
                            IRBuilder<> builder(CB);
                            ArgsV.push_back(builder.CreatePtrToInt(v, int64Ty));
                            if(ARTD_BUILD == ARTD_BUILD_STATIC_E){
                                builder.CreateCall(ics_static_map_indirect_call_func, ArgsV);
                            }else if(ARTD_BUILD == ARTD_BUILD_PROFILE_E){
                                // use vararg approach (need to fix-up-argsv)
                                vector<Value *> VarArgsV;
                                VarArgsV.push_back(builder.CreatePtrToInt(v, int64Ty));
                                int num_args_pushed = fix_up_argsv_for_indirect(CB, VarArgsV, builder);
                                builder.CreateCall(ics_profile_map_indirect_call_funcs[num_args_pushed], VarArgsV);
                            }else if(ARTD_BUILD == ARTD_BUILD_TEST_PREDICT_E){
                                // use vararg approach (need to fix-up-argsv)
                                vector<Value *> VarArgsV;
                                VarArgsV.push_back(builder.CreatePtrToInt(v, int64Ty));
                                int num_args_pushed = fix_up_argsv_for_indirect(CB, VarArgsV, builder);
                                builder.CreateCall(ics_test_predict_map_indirect_call_funcs[num_args_pushed], VarArgsV);
                            }else{
                                assert(ARTD_BUILD == ARTD_BUILD_RELEASE_E);
                                // use vararg approach (need to fix-up-argsv)
                                vector<Value *> VarArgsV;
                                VarArgsV.push_back(builder.CreatePtrToInt(v, int64Ty));
                                int num_args_pushed = fix_up_argsv_for_indirect(CB, VarArgsV, builder);
                                CallInst *ci = builder.CreateCall(ics_release_map_indirect_call_funcs[num_args_pushed], VarArgsV);
                                if(ENABLE_RELEASE_TRACE_INSTRUMENTATION){
                                    vector<Value *> ArgsV2;
                                    IRBuilder<> builder2(ci);
                                    ArgsV2.push_back(ConstantInt::get(int32Ty, -1, false));
                                    builder2.CreateCall(ics_release_trace_func, ArgsV2);
                                }
                            }

                            // Note: We instrument after the indirect call if
                            // we are not inside an encompassed func or a loop
                            // block. If we are (as in this case), the runtime
                            // will handle this ICS optimization to clear the
                            // pages at the end of the loop, but for profiling,
                            // we still need a proper record of which functions
                            // were hit by this indirect call. For that, we'll
                            // need to invoke ics_end_indirect_call on
                            // profiling runs.
                            if(ARTD_BUILD == ARTD_BUILD_PROFILE_E){
                                // instrument after ics call
                                if(CI){
                                    IRBuilder<> builder_end(CI);
                                    builder_end.SetInsertPoint(CI->getNextNode());
                                    builder_end.CreateCall(ics_profile_end_indirect_call_func, ArgsV);
                                }else if(II){
                                    //errs() << "indirect func invoke case\n";
                                    instrument_after_invoke(II, ArgsV, ics_profile_end_indirect_call_func, false);
                                }else{
                                    assert(0);
                                }
                            // UPDATE: not just for profiling. also need to
                            // trace for release now.
                            }else if(ENABLE_RELEASE_TRACE_INSTRUMENTATION && ARTD_BUILD == ARTD_BUILD_RELEASE_E){
                                vector<Value *> ArgsV2;
                                ArgsV2.push_back(ConstantInt::get(int32Ty, -1, false));
                                // instrument after ics call
                                if(CI){
                                    IRBuilder<> builder_end(CI);
                                    builder_end.SetInsertPoint(CI->getNextNode());
                                    builder_end.CreateCall(ics_release_trace_func, ArgsV2);
                                }else if(II){
                                    //errs() << "indirect func invoke case\n";
                                    instrument_after_invoke(II, ArgsV2, ics_release_trace_func, false); // false because here we just need ics-release-trace-func to get instrumented, which we're already providing
                                }else{
                                    assert(0);
                                }
                            }
                        }

                    }else{
                        // Not sure how to handle this if it happens
                        // would need to investigate the specific case.
                        assert(0 && "Unexpected: calledOperand is NOT a " \
                                    "pointer type for an indirect call.\n");
                    }
                }else{
                    if(cf->hasName() && cf->isDeclaration()){
                        instrument_external_call(I,
                                                 f_is_not_encompassed
                                                   && block_is_outside_loop
                                                );
                    }
                }
            }
        }
    }
}

void AdvancedRuntimeDebloat::instrument(void)
{
    errs() << "Instrumenting all other funcs\n";
    int i = 0;
    for(auto f : all_funcs){
        if(i % 100 == 0){
            errs() << "  processing function " << i << " / " << all_funcs.size() << "\n";
        }
        if(libc_nonstatic_func_names.count(func_id_to_name[func_to_id[f]]) == 0){
            LoopInfo *LI = &getAnalysis<LoopInfoWrapperPass>(*f).getLoopInfo();
            if(toplevel_funcs.find(f) != toplevel_funcs.end()){
                instrument_toplevel_func(f, LI);
            }
            instrument_indirect_and_external(f, LI);
        }
        i++;
    }
}

// TODO support more arg types? should catch boolean at least, right?
int AdvancedRuntimeDebloat::push_arg(Value *argV, vector<Value *> &ArgsV, IRBuilder<> &builder, bool is_64)
{
    if((argV->getType()->isIntegerTy()
     || argV->getType()->isFloatTy()
     || argV->getType()->isDoubleTy()
     || argV->getType()->isPointerTy())){
        //errs() << "valid type argument\n";
        Value *funcArg = argV;

        //errs() << "checking funcArg\n";
        Value *castedArg = nullptr;
        if(funcArg != NULL){ // FIXME do we want this check???
            if (funcArg->getType()->isFloatTy() || funcArg->getType()->isDoubleTy()){
                //errs() << "float or double\n";
                if(is_64){
                    castedArg = builder.CreateFPToSI(funcArg, int64Ty);
                }else{
                    castedArg = builder.CreateFPToSI(funcArg, int32Ty);
                }
            }else if(funcArg->getType()->isIntegerTy()){
                //errs() << "integer\n";
                if(is_64){
                    castedArg = builder.CreateIntCast(funcArg, int64Ty, true);
                }else{
                    castedArg = builder.CreateIntCast(funcArg, int32Ty, true);
                }
            }else if(funcArg->getType()->isPointerTy()){
                //errs() << "pointer\n";
                //if(is_64){
                //    castedArg = builder.CreatePtrToInt(funcArg, int64Ty);
                //}else{
                //    castedArg = builder.CreatePtrToInt(funcArg, int32Ty);
                //}
                // Don't train on pointer values
                return 0;
            }

            if(castedArg == nullptr){
                return 0;
            }
            ArgsV.push_back(castedArg);
            return 1; // arg was pushed, so return 1
            //errs() << "pushing: " << *castedArg << "\n";
        }
    }
    return 0;
}

void AdvancedRuntimeDebloat::instrument_feature_pass_deprecated(CallBase *callsite,
                                                     Function *parent_func,
                                                     Instruction *inst_to_follow,
                                                     Function *func_to_instrument,
                                                     int func_or_loop_id,
                                                     bool insert_neg1_to_release_trace)
{
    ////errs() << "inst to follow: " << inst_to_follow << "\n";
    //if(callsite){
    //    //errs() << "callsite num args: " << callsite->arg_size() << "\n";
    //    if(callsite->getCalledFunction()){
    //        //errs() << "Name of the called function: " << callsite->getCalledFunction()->getName() << "\n";
    //    }else{
    //        //errs() << "Called func unknown (func pointer)\n";
    //    }
    //}else{
    //    //errs() << "parent_func num args: " << parent_func->arg_size() << "\n";
    //    //errs() << "Name of the parent function: " << parent_func->getName() << "\n";
    //}
    IRBuilder<> builder(inst_to_follow);
    vector<Value *> ArgsV;
    ArgsV.push_back(llvm::ConstantInt::get(int32Ty, 0, false));

    if(callsite == NULL){
        // Case: we're passing features for a loop (not for a function call)
        // hacky protocol: set func_or_loop_id to negative to indicate it's a loop ID.
        // Subtract 1 b/c IDs will collide on the value 0.
        // (So, to recover, you multiply by -1 and then subtract 1 again).
        assert(parent_func);
        func_or_loop_id = (func_or_loop_id * -1) - 1;
    }else{
        // sanity check assert... maybe catch a future bug/assumption if code changes, too
        assert(parent_func == NULL);
    }
    ArgsV.push_back(llvm::ConstantInt::get(int32Ty, func_or_loop_id, false));

    ArgsV.push_back(llvm::ConstantInt::get(int32Ty, deck_id_counter, false));
    update_deck_id_to_caller_callee(deck_id_counter, callsite, parent_func);
    deck_id_counter++;

    // FIXME no better way to do this? function and callbase live in different
    // parts of the inheritance tree i think.
    if(callsite){
        assert(func_or_loop_id >= 0);
        for(auto it_arg = callsite->arg_begin(); it_arg != callsite->arg_end(); it_arg++){
            push_arg((Value *) *it_arg, ArgsV, builder, false);
        }
    }else{
        assert(func_or_loop_id < 0);
        for(Function::arg_iterator it_arg = parent_func->arg_begin(); it_arg != parent_func->arg_end(); it_arg++){
            // XXX I've tested this cast and it works. Reason, I think, is that
            // it_arg iterates over Argument types (no pointer). And Argument
            // is derived from Value. Hence, it_arg is a Value *.
            push_arg((Value *) it_arg, ArgsV, builder, false);
        }
    }

    ArgsV[0] = llvm::ConstantInt::get(int32Ty, ArgsV.size() - 1, false);

    CallInst *ci = builder.CreateCall(func_to_instrument, ArgsV);
    if(ENABLE_RELEASE_TRACE_INSTRUMENTATION && insert_neg1_to_release_trace){
        vector<Value *> ArgsV2;
        IRBuilder<> builder2(ci);
        ArgsV2.push_back(ConstantInt::get(int32Ty, -1, false));
        builder2.CreateCall(ics_release_trace_func, ArgsV2);
    }
}
void AdvancedRuntimeDebloat::instrument_feature_pass(CallBase *callsite,
                                                     Function *parent_func,
                                                     Instruction *inst_to_follow,
                                                     Function **funcs_to_instrument,
                                                     int func_or_loop_id,
                                                     bool insert_neg1_to_release_trace)
{
    IRBuilder<> builder(inst_to_follow);
    vector<Value *> ArgsV;

    if(callsite == NULL){
        // Case: we're passing features for a loop (not for a function call)
        // hacky protocol: set func_or_loop_id to negative to indicate it's a loop ID.
        // Subtract 1 b/c IDs will collide on the value 0.
        // (So, to recover, you multiply by -1 and then subtract 1 again).
        assert(parent_func);
        func_or_loop_id = (func_or_loop_id * -1) - 1;
    }else{
        // sanity check assert... maybe catch a future bug/assumption if code changes, too
        assert(parent_func == NULL);
    }
    ArgsV.push_back(llvm::ConstantInt::get(int32Ty, func_or_loop_id, false));

    ArgsV.push_back(llvm::ConstantInt::get(int32Ty, deck_id_counter, false));
    update_deck_id_to_caller_callee(deck_id_counter, callsite, parent_func);
    deck_id_counter++;

    int num_args_pushed = 0;

    // FIXME no better way to do this? function and callbase live in different
    // parts of the inheritance tree i think.
    if(callsite){
        assert(func_or_loop_id >= 0);
        for(auto it_arg = callsite->arg_begin(); it_arg != callsite->arg_end(); it_arg++){
            num_args_pushed += push_arg((Value *) *it_arg, ArgsV, builder, false);
            if(num_args_pushed == MAX_VARARGS_SUPPORTED){
                break;
            }
        }
    }else{
        assert(func_or_loop_id < 0);
        for(Function::arg_iterator it_arg = parent_func->arg_begin(); it_arg != parent_func->arg_end(); it_arg++){
            // XXX I've tested this cast and it works. Reason, I think, is that
            // it_arg iterates over Argument types (no pointer). And Argument
            // is derived from Value. Hence, it_arg is a Value *.
            num_args_pushed += push_arg((Value *) it_arg, ArgsV, builder, false);
            if(num_args_pushed == MAX_VARARGS_SUPPORTED){
                break;
            }
        }
    }

    Function *func_to_instrument = funcs_to_instrument[num_args_pushed];
    CallInst *ci = builder.CreateCall(func_to_instrument, ArgsV);
    if(ENABLE_RELEASE_TRACE_INSTRUMENTATION && insert_neg1_to_release_trace){
        vector<Value *> ArgsV2;
        IRBuilder<> builder2(ci);
        ArgsV2.push_back(ConstantInt::get(int32Ty, -1, false));
        builder2.CreateCall(ics_release_trace_func, ArgsV2);
    }
}

void AdvancedRuntimeDebloat::instrument_toplevel_func(Function *f, LoopInfo *LI)
{
    //for(auto f : toplevel_funcs){
        errs() << "Instrumenting " << f->getName().str() << "\n";

        // Instrument outer loops
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
                            if(ARTD_BUILD != ARTD_BUILD_RELEASE_E){
                                IRBuilder<> builder(CB);
                                CallInst *ci = builder.CreateCall(debrt_protect_reachable_func, ArgsV);
                                if(ARTD_BUILD == ARTD_BUILD_PROFILE_E){
                                    instrument_feature_pass(CB, NULL, ci, debrt_profile_print_args_funcs, func_to_id[callee], false);
                                }else if(ARTD_BUILD == ARTD_BUILD_TEST_PREDICT_E){
                                    instrument_feature_pass(CB, NULL, ci, debrt_test_predict_predict_funcs, func_to_id[callee], false);
                                }else{
                                    assert(ARTD_BUILD == ARTD_BUILD_STATIC_E);
                                }
                            }else{
                                assert(ARTD_BUILD == ARTD_BUILD_RELEASE_E);
                                instrument_feature_pass(CB, NULL, CB, debrt_release_predict_funcs, func_to_id[callee], false); // false because this is a direct call. not adding -1 tracing for this.
                            }

                            if(CI){
                                IRBuilder<> builder_end(CI);
                                builder_end.SetInsertPoint(CI->getNextNode());
                                if(ARTD_BUILD == ARTD_BUILD_RELEASE_E){
                                    builder_end.CreateCall(ics_release_wrapper_debrt_protect_reachable_end_func, ArgsV);
                                }else{
                                    builder_end.CreateCall(debrt_protect_reachable_end_func, ArgsV);
                                }
                            }else if(II){
                                //errs() << "no-instrument invoke case\n";
                                if(ARTD_BUILD == ARTD_BUILD_RELEASE_E){
                                    instrument_after_invoke(II, ArgsV, ics_release_wrapper_debrt_protect_reachable_end_func, false); // false because this is a direct call... dont want -1 value in the trace after a direct call.
                                }else{
                                    instrument_after_invoke(II, ArgsV, debrt_protect_reachable_end_func, false);
                                }
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
                                //errs() << "yes-instrument invoke case\n";
                                instrument_after_invoke(II, ArgsV, debrt_protect_single_end_func, false);
                            }else{
                                assert(0);
                            }
                        }
                        update_disjoint_sets(temp);
                    }
                }
            }
        }
    //}


}

void AdvancedRuntimeDebloat::instrument_external_call(Instruction &I,
                                                   bool call_is_outside_loop)
{
    CallBase *CB = dyn_cast<CallBase>(&I);
    assert(CB);
    Function *external_func = CB->getCalledFunction();
    assert(external_func);

    // Weird edge case. atexit won't actually invoke the function pointer
    // (because it happens at teardown).
    // Plus, atexit is actually part of libc_nonstatic_func_names and is
    // therefore instrumented elsewhere by this pass as if it were application
    // code. So there's no need for it to have extra instrumentation here.
    if(external_func->getName() == "atexit"){
        // XXX An alternative to all the libc_nonstatic_func_names stuff
        // could be to create a new like isntrument_atexit(), which
        // just instruments atexit() with a debrt-protect-single/end call.
        // One of the only reasons I didn't do it this way was because
        // it's not obvious what func-id to pass. func_to_id[] doesn't have
        // atexit unless we change other places. But to do that we might as
        // well have something like libc_nonstatic_func_names and just
        // use all the other instrumentation stuff that's already there;
        // and thus we don't need some special instrument_atexit() call here.
        //instrument_atexit(&I);
        return;
    }

    bool instrumented = instrument_external_with_callback(I, call_is_outside_loop);
    if(!instrumented){
        if(external_func->getName() == "exit"){
            instrument_debrt_destroy(&I);
        }
    }
}


bool AdvancedRuntimeDebloat::instrument_external_with_callback(Instruction &I,
                                                            bool call_is_outside_loop)
{
    CallBase   *CB_external_call = dyn_cast<CallBase>(&I);
    CallInst   *CI_external_call = dyn_cast<CallInst>(&I);
    InvokeInst *II_external_call = dyn_cast<InvokeInst>(&I);

    //errs() << "Seeing an external call: "
    //  << CB_external_call->getCalledFunction()->getName() << "\n";

    Function *callback = NULL;
    int num_callbacks = 0;
    int arg_idx = 0;
    for(auto it_arg = CB_external_call->arg_begin();
      it_arg != CB_external_call->arg_end();
      it_arg++){
        //errs() << "arg " << arg_idx <<  "\n";
        Value *s = (*it_arg)->stripPointerCasts();
        if(s == NULL){
            assert(0 && "Unexpected: stripPointerCasts() returned NULL.");
        }
        Function *tmp = dyn_cast<Function>(s);
        if(tmp != NULL){
            if(func_to_id.find(tmp) != func_to_id.end()){
                //errs() << "callback arg found at param " << arg_idx << "\n";
                callback = tmp;
                num_callbacks++;
            }else{
                //errs() << "callback arg found at param " << arg_idx << ", "
                //  << "but it is not in func_to_id\n";
            }
        }
        arg_idx++;
    }

    // nothing to instrument if num_callbacks is 0
    if(num_callbacks == 0){
        return false;
    }

    // Currently there is only support for external calls where 1 application
    // function is passed to the library.
    // See 2021.08.30 notes for details on how this could be supported.
    // It's a weird edge case that should be safe to ignore for now, though.
    assert(num_callbacks == 1 && "Only 1 application function callback " \
                                 "is supported when calling an external library");

    //errs() << "callback name: " << callback->getName() << "\n";
    //errs() << "callback func id: " << func_to_id[callback] << "\n";

    // instrument around the external call()
    if(call_is_outside_loop){
        // Case: the external call is called from a non-encompassed func, and
        // from a block that's not in any loop. So we can just instrument
        // around it, using either single or reachable protection based on the
        // callback.

        vector<Value *> ArgsV;
        IRBuilder<> builder(CB_external_call);
        ArgsV.push_back(ConstantInt::get(int32Ty, func_to_id[callback], false));

        bool callback_is_encompassed
          = encompassed_funcs.find(callback) != encompassed_funcs.end();

        // Instrument before the external call
        Function *end_call;
        if(callback_is_encompassed){
            // reachable
            if(ARTD_BUILD != ARTD_BUILD_RELEASE_E){
                CallInst *ci = builder.CreateCall(debrt_protect_reachable_func, ArgsV);
                if(ARTD_BUILD == ARTD_BUILD_PROFILE_E){
                    instrument_feature_pass(CB_external_call, NULL, ci, debrt_profile_print_args_funcs, func_to_id[callback], false);
                }else if(ARTD_BUILD == ARTD_BUILD_TEST_PREDICT_E){
                    instrument_feature_pass(CB_external_call, NULL, ci, debrt_test_predict_predict_funcs, func_to_id[callback], false);
                }else{
                    assert(ARTD_BUILD == ARTD_BUILD_STATIC_E);
                }
                end_call = debrt_protect_reachable_end_func;
            }else{
                assert(ARTD_BUILD == ARTD_BUILD_RELEASE_E);
                instrument_feature_pass(CB_external_call, NULL, CB_external_call, debrt_release_predict_funcs, func_to_id[callback], true); // true because this is an external call, so we need -1 tracing
                end_call = ics_release_wrapper_debrt_protect_reachable_end_func;
            }
        }else{
            // single
            builder.CreateCall(debrt_protect_single_func, ArgsV);
            end_call = debrt_protect_single_end_func;
        }

        // Instrument after the external call
        if(CI_external_call){
            //errs() << "call the external function\n";
            IRBuilder<> builder_end(CI_external_call);
            builder_end.SetInsertPoint(CI_external_call->getNextNode());
            CallInst *ci = builder_end.CreateCall(end_call, ArgsV);
            if(ENABLE_RELEASE_TRACE_INSTRUMENTATION && ARTD_BUILD == ARTD_BUILD_RELEASE_E){
                vector<Value *> ArgsV2;
                IRBuilder<> builder2(ci);
                ArgsV2.push_back(ConstantInt::get(int32Ty, -1, false));
                builder2.CreateCall(ics_release_trace_func, ArgsV2);
            }
        }else if(II_external_call){
            //errs() << "invoke the external function\n";
            if(ARTD_BUILD == ARTD_BUILD_RELEASE_E){
                instrument_after_invoke(II_external_call, ArgsV, end_call, true);
            }else{
                instrument_after_invoke(II_external_call, ArgsV, end_call, false);
            }
        }else{
            assert(0);
        }

    }else{




        // Case: The external function is called from an encompassed func or
        // from inside a block that's in a loop. Rather than handle the
        // protection at the loop header, we cheat and use the indirect-call
        // inlining support. It could be slower, but external calls with
        // callbacks should be rare, and security could be better by mapping
        // on-the-fly. See also note in build_basic_structs.
        vector<Value *> ArgsV;
        IRBuilder<> builder(CB_external_call);

        if(ARTD_BUILD == ARTD_BUILD_STATIC_E){
            ArgsV.push_back(builder.CreatePtrToInt(callback, int64Ty));
            builder.CreateCall(ics_static_map_indirect_call_func, ArgsV);
        }else if(ARTD_BUILD == ARTD_BUILD_PROFILE_E){
            // Use the new vararg approach to ics-map-indirect-call.
            // First argument is number of args to follow -- 2 in this case.
            // Second is the function pointer target address.
            // Third is a decker ID counter.
            // TODO We could pass arguments -- perhaps to the external call itself,
            // but we'll ignore that for now. It could potentially help
            // predict which functions to enable after the callback hits.
            // UPDATE: use fixed arguments now.
            ArgsV.push_back(builder.CreatePtrToInt(callback, int64Ty));
            ArgsV.push_back(llvm::ConstantInt::get(int64Ty, deck_id_counter, false));
            update_deck_id_to_caller_callee(deck_id_counter, CB_external_call, NULL);
            deck_id_counter++;

            builder.CreateCall(ics_profile_map_indirect_call_0_func, ArgsV);
        }else if(ARTD_BUILD == ARTD_BUILD_TEST_PREDICT_E){
            // Use the new vararg approach to ics-map-indirect-call.
            // First argument is number of args to follow -- 2 in this case.
            // Second is the function pointer target address.
            // Third is a decker ID counter.
            // TODO We could pass arguments -- perhaps to the external call itself,
            // but we'll ignore that for now. It could potentially help
            // predict which functions to enable after the callback hits.
            // UPDATE: use fixed arguments now.
            ArgsV.push_back(builder.CreatePtrToInt(callback, int64Ty));
            ArgsV.push_back(llvm::ConstantInt::get(int64Ty, deck_id_counter, false));
            update_deck_id_to_caller_callee(deck_id_counter, CB_external_call, NULL);
            deck_id_counter++;

            builder.CreateCall(ics_test_predict_map_indirect_call_0_func, ArgsV);
        }else{
            assert(ARTD_BUILD == ARTD_BUILD_RELEASE_E);
            // Use the new vararg approach to ics-map-indirect-call.
            // First argument is number of args to follow -- 2 in this case.
            // Second is the function pointer target address.
            // Third is a decker ID counter.
            // TODO We could pass arguments -- perhaps to the external call itself,
            // but we'll ignore that for now. It could potentially help
            // predict which functions to enable after the callback hits.
            // UPDATE: use fixed arguments now.
            ArgsV.push_back(builder.CreatePtrToInt(callback, int64Ty));
            ArgsV.push_back(llvm::ConstantInt::get(int64Ty, deck_id_counter, false));
            update_deck_id_to_caller_callee(deck_id_counter, CB_external_call, NULL);
            deck_id_counter++;

            builder.CreateCall(ics_release_map_indirect_call_0_func, ArgsV);
        }


        // Note: As with other inlined indirect call instrumentation that is
        // inside some interprocedural loop, we now instrument after the
        // external call when profiling.  This gives us a proper record of
        // which functions were hit by this external call (which invoked our
        // callback).  For this, we need to invoke ics_end_indirect_call on
        // profiling runs. The runtime still handles the ICS optimization to
        // clear the pages at the end of the loop.
        if(ARTD_BUILD == ARTD_BUILD_PROFILE_E){
            // instrument after external call
            // crude but works: fix the args so argsV just holds the fp-addr
            // UPDATE: Handle this for the fixed arguments now
            ArgsV.pop_back();
            if(CI_external_call){
                //errs() << "call the external function\n";
                IRBuilder<> builder_end(CI_external_call);
                builder_end.SetInsertPoint(CI_external_call->getNextNode());
                builder_end.CreateCall(ics_profile_end_indirect_call_func, ArgsV);
            }else if(II_external_call){
                //errs() << "invoke the external function\n";
                instrument_after_invoke(II_external_call, ArgsV, ics_profile_end_indirect_call_func, false);
            }else{
                assert(0);
            }
        }
        // UPDATE: need to trace for release
        if(ARTD_BUILD == ARTD_BUILD_RELEASE_E){
            vector<Value *> ArgsV2;
            ArgsV2.push_back(ConstantInt::get(int32Ty, -1, false));
            // instrument after external call
            if(CI_external_call){
                //errs() << "call the external function\n";
                IRBuilder<> builder_end(CI_external_call);
                builder_end.SetInsertPoint(CI_external_call->getNextNode());
                builder_end.CreateCall(ics_release_trace_func, ArgsV2);
            }else if(II_external_call){
                //errs() << "invoke the external function\n";
                instrument_after_invoke(II_external_call, ArgsV2, ics_release_trace_func, false); // false because we're passing ics-release-trace-func already here
            }else{
                assert(0);
            }
        }
    }

    return true;
}




bool AdvancedRuntimeDebloat::instrument_main_start(Module &M)
{
    errs() << "Instrumenting main start\n";
    int found_main = 0;
    for(auto &F : M){
        string func_name = get_demangled_name(F);
        if(func_name == "main"){

            // instrument start of main with debrt-init
            vector<Value *> ArgsV;
            Instruction *I = F.getEntryBlock().getFirstNonPHI();
            assert(I);
            IRBuilder<> builder(I);
            ArgsV.push_back(ConstantInt::get(int32Ty, func_to_id[&F], false));
            ArgsV.push_back(ConstantInt::get(int32Ty, ENABLE_INSTRUMENTATION_SINKING, false));
            builder.CreateCall(debrt_init_func, ArgsV);

            found_main = 1;
            if( (ARTD_BUILD != ARTD_BUILD_PROFILE_E) && (ARTD_BUILD != ARTD_BUILD_TEST_PREDICT_E) ){
                break;
            }
        }else{
            if( (ARTD_BUILD == ARTD_BUILD_PROFILE_E) || (ARTD_BUILD == ARTD_BUILD_TEST_PREDICT_E) ){
                if(F.hasName() && !F.isDeclaration()){
                    if(ics_func_names.find(F.getName().str()) != ics_func_names.end()){
                        continue;
                    }
                    // instrument start of function with debrt-profile-trace
                    vector<Value *> ArgsV;
                    Instruction *I = F.getEntryBlock().getFirstNonPHI();
                    assert(I);
                    IRBuilder<> builder(I);
                    ArgsV.push_back(ConstantInt::get(int32Ty, func_to_id[&F], false));
                    if(ARTD_BUILD == ARTD_BUILD_PROFILE_E){
                        builder.CreateCall(debrt_profile_trace_func, ArgsV);
                    }else{
                        assert(ARTD_BUILD == ARTD_BUILD_TEST_PREDICT_E);
                        builder.CreateCall(debrt_test_predict_trace_func, ArgsV);
                    }
                }
            }
        }
    }
    assert(found_main == 1);
}

bool AdvancedRuntimeDebloat::instrument_main_end(Module &M)
{
    errs() << "Instrumenting main end\n";
    int found_main = 0;
    for(auto &F : M){
        string func_name = get_demangled_name(F);
        if(func_name == "main"){

            // instrument any returns with debrt-destroy
            for(auto &B : F){
                if(isa<ReturnInst>(B.getTerminator())){
                    instrument_debrt_destroy(B.getTerminator());
                }
            }

            found_main = 1;
            break;
        }
    }
    assert(found_main == 1);
}


void AdvancedRuntimeDebloat::instrument_debrt_destroy(Instruction *I)
{
    assert(I);
    vector<Value *> ArgsV_return;
    IRBuilder<> builder(I);
    ArgsV_return.push_back(ConstantInt::get(int32Ty, 0, false));
    builder.CreateCall(debrt_destroy_func, ArgsV_return);
}


void AdvancedRuntimeDebloat::build_basic_structs(Module &M)
{
    int callsite_counter = 0;
    LoopInfo *li;
    CallBase *cb;
    for(auto &F : M){
        //if(F.hasName()){
        //    errs() << "build-basic-structs: " << F.getName().str() << "\n";
        //    errs() << "  getLinkage(): " << F.getLinkage() << "\n";
        //}
        if(F.hasName() && !F.isDeclaration()){
            if(ics_func_names.find(F.getName().str()) != ics_func_names.end()){
                //errs() << "ignoring ics func: " << F.getName() << "\n";
                continue;
            }
            // update all_funcs
            all_funcs.insert(&F);
            li = &getAnalysis<LoopInfoWrapperPass>(F).getLoopInfo();
            bool has_no_callsites = true;
            for(auto &B : F){
                for(auto &I : B){
                    cb = dyn_cast<CallBase>(&I);
                    if(cb){
                        Function *callee = cb->getCalledFunction();
                        if(func_to_id.count(callee) > 0){
                            has_no_callsites = false;
                            // FIXME ? I haven't paid close attention to details
                            // but this looks right. I don't think this assigns
                            // an ID to indirect calls. I don't think it assigns
                            // and ID to external calls either. This seems
                            // to be what I want, though.
                            if(ENABLE_RELEASE_TRACE_INSTRUMENTATION && ARTD_BUILD == ARTD_BUILD_RELEASE_E){
                                // XXX this is a hack.. shouldn't be doing this
                                // here but it's saving me work. Basically we
                                // are instrumenting release builds at all
                                // direct callsites for tracing. going
                                // to handle the indirect and external later in
                                // this pass.
                                vector<Value *> ArgsV;
                                IRBuilder<> builder(cb);
                                ArgsV.push_back(ConstantInt::get(int32Ty, callsite_counter, false));
                                builder.CreateCall(ics_release_trace_func, ArgsV);
                            }
                            callsite_to_id[cb] = callsite_counter;
                            belong[callsite_counter] = func_to_id[callee];
                            block_to_callsites[&B].push_back(cb);
                            callsite_counter++;
                            func_to_num_calls[&F]++;

                            // update adj_list
                            adj_list[&F].insert(callee);
                            if(li && li->getLoopFor(&B)){
                                // add any functions that are called inside of
                                // a loop to encompassed_funcs
                                encompassed_funcs.insert(callee);
                            }
                        }
                        // Note: if we wanted to handle external calls without
                        // using the indirect inlining support, then this
                        // would be a place to start, I think. Right here
                        // we could check if the callee is a declaration
                        // and takes a callback, and then we could update the
                        // adj-list to include the callback that gets passed
                        // to the external call. I believe other things should
                        // then fall into place, including how the loop
                        // preheader would get instrumented whenever any
                        // external call instances are interprocedurally
                        // reached by a loop. Not 100% sure about all this,
                        // but again, probably the right way to start going
                        // about it.
                    }
                }
            }
            if(has_no_callsites){
                leaf.insert(func_to_id[&F]);
            }
        }else if(F.hasName() && (libc_nonstatic_func_names.count(F.getName().str()) > 0)){
            // XXX This is sufficient for atexit(), which is currently the only
            // member of libc_nonstatic_func_names. If we have to handle more
            // libc_nonstatic cases, or if that set gets slightly repurposed,
            // this code may need reconsideration. Notice that we cannot include
            // functions like atexit() in the above analysis (with LoopInfoWrapperPass),
            // because it's an external call with no info. But we don't
            // instrument any callees or anything beyond atexit, so this
            // all_funcs insertion is sufficient for atexit().
            all_funcs.insert(&F);
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


void AdvancedRuntimeDebloat::update_disjoint_sets(set<Function *> &new_set)
{
    // sharjeel's approach is to do this in places:
    //   instrumented_sets.push_back(new_set)
    // then call this at the end of the pass:
    //   create_disjoint_sets()

    //
    // New approach (bottom-up)
    //
    // General idea: Each time we have a new set of functions that form a
    // deck, we update our disjoint sets. Any completely new functions that
    // we see will go into their own disjoint set. Any functions that intersect
    // with an existing disjoint set will get factored out into new disjoint
    // sets.

    // unique IDs for the all disjoint sets
    static long disjoint_set_id = 0;
    #define DISJOINT_SET_ID_PARENTLESS    (-1)
    #define DISJOINT_SET_ID_UNINITIALIZED (-2)

    // a map from a new disjoint set's parent id to that new, factored-out
    // disjoint set
    map<long, disjoint_set_t> factored_disjoint_sets;

    // a new disjoint set with just elements from new_set, if needed
    disjoint_set_t parentless_disjoint_set;
    parentless_disjoint_set.id = DISJOINT_SET_ID_UNINITIALIZED;
    parentless_disjoint_set.s = NULL;

    // For each function in the new deck set
    for(Function *func : new_set){
        // Check if the function already exists in a disjoint set.
        if(func_to_disjoint_set.find(func) == func_to_disjoint_set.end()){
            // ... it does not
            // It goes into a new parentless disjoint set
            if(parentless_disjoint_set.s == NULL){
                parentless_disjoint_set.s = new set<Function *>;
                parentless_disjoint_set.id = disjoint_set_id;
                disjoint_set_id++;
            }
            parentless_disjoint_set.s->insert(func);
            func_to_disjoint_set[func] = parentless_disjoint_set;
        } else {
            // ... it does
            // Grab the disjoint set where it resides. (this is now the 'parent')
            disjoint_set_t disjoint_set = func_to_disjoint_set[func];
            // Check if we already have a factored-out disjoint set for this parent
            if(factored_disjoint_sets.find(disjoint_set.id) == factored_disjoint_sets.end()){
                // ... we don't
                disjoint_set_t ds; // a new, factored-out disjoint set
                ds.id = disjoint_set_id;
                ds.s = new set<Function *>;
                ds.s->insert(func);
                disjoint_set_id++;
                factored_disjoint_sets[disjoint_set.id] = ds;
                // Update the mapping of function to the disjoint set where it resides
                func_to_disjoint_set[func] = ds;
            } else {
                // ... we do
                // So add to that factored-out disjoint set
                factored_disjoint_sets[disjoint_set.id].s->insert(func);
                // Update the mapping of function to the disjoint set where it resides
                func_to_disjoint_set[func] = factored_disjoint_sets[disjoint_set.id];
            }
            // Irrespective of whether we already had a factored-out set, we
            // still need to remove the function from the parent.
            assert(disjoint_set.s->find(func) != disjoint_set.s->end());
            disjoint_set.s->erase(func);
        }
    }

    // If we actually made a new parentless disjoint set
    if(parentless_disjoint_set.s != NULL){
        factored_disjoint_sets[DISJOINT_SET_ID_PARENTLESS] = parentless_disjoint_set;
    }

    // Last step: Update our global disjoint sets with any new factored-out
    // sets we created. Note that we don't need to do any erasing here, because
    // it's already been handled when we factored out functions.
    // We don't clear out any empty sets in disjoint_sets. We just ignore them
    // when dumping.
    for(auto &it : factored_disjoint_sets){
        int parent_id = it.first;
        disjoint_set_t &ds = it.second;
        disjoint_sets[ds.id] = ds.s;
    }
    // TODO should actually free the memory for the disjoint sets.
    // could do that after dump_disjoint_sets

    //print_disjoint_sets(); // debug
}


void AdvancedRuntimeDebloat::finalize_disjoint_sets(void)
{
    // Set of functions that have addresses taken so we take their reachability
    // and consider it as a set (Sharjeel)
    errs() << "Finalizing disjoint sets\n";
    for(auto F : func_has_addr_taken)
    {
        set<Function *> temp;
        temp.insert(F);
        temp.insert(static_reachability[F].begin(), static_reachability[F].end());
        update_disjoint_sets(temp);
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
/*void AdvancedRuntimeDebloat::extend_static_reachability(void)
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

void AdvancedRuntimeDebloat::extend_adj_list(void)
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

void AdvancedRuntimeDebloat::build_static_reachability(void)
{
    errs() << "Building static reachability\n";
    int i = 0;
    //errs() << "Size of all_funcs: " << all_funcs.size() << "\n";
    for(auto F : all_funcs){
        if(i % 500 == 0){
            errs() << "  processing function " << i << " / " << all_funcs.size() << "\n";
        }
        //errs() << i << " " << F->getName() << "\n";
        queue<Function *> q;
        //errs() << "  pushing callees\n";
        for(auto callee : adj_list[F]){
            q.push(callee);
        }
        //errs() << "  updating static reachability\n";
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
        i++;
    }
}
void AdvancedRuntimeDebloat::build_func_to_parents(void)
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
void AdvancedRuntimeDebloat::build_func_to_fps(Module &M)
{
    int s;
    int f;
    s = 0;
    f = 0;
    for(auto &F : M){
        if( (F.hasName() && !F.isDeclaration())
        ||  (F.hasName() && (libc_nonstatic_func_names.count(F.getName().str()) > 0)) ){
        //if(F.hasName() && !F.isDeclaration()){
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

void AdvancedRuntimeDebloat::build_toplevel_funcs(void)
{
    errs() << "Building toplevel funcs\n";
    // toplevel_funcs = all_funcs \ encompassed_funcs
    set_difference(all_funcs.begin(),
                   all_funcs.end(),
                   encompassed_funcs.begin(),
                   encompassed_funcs.end(),
                   inserter(toplevel_funcs, toplevel_funcs.end()));
}

void AdvancedRuntimeDebloat::artd_init(Module &M)
{
    // Init loop count (for handing out IDs)
    deck_id_counter = 0;
    loop_id_counter = 0;
    sink_id_counter = 0;

    ENABLE_INSTRUMENTATION_SINKING = EnableInstrumentationSinking;
    errs() << "ENABLE_INSTRUMENTATION_SINKING: " << ENABLE_INSTRUMENTATION_SINKING << "\n";
    ENABLE_BASIC_INDIRECT_CALL_STATIC_ANALYSIS = EnableBasicIndirectCallStaticAnalysis;
    errs() << "ENABLE_BASIC_INDIRECT_CALL_STATIC_ANALYSIS: " << ENABLE_BASIC_INDIRECT_CALL_STATIC_ANALYSIS << "\n";
    ARTD_BUILD = parseARTDBuildOpt();

    memset(&stats, 0, sizeof(stats));

    // FIXME (see fixme within read_readelf_sections)
    if(ENABLE_INSTRUMENTATION_SINKING){
        read_readelf_sections();
        read_readelf();
    }


    libc_nonstatic_func_names.insert("atexit");

    // Give each application function an ID
    int count = 0;
    for(auto &F : M){
        if( (F.hasName() && !F.isDeclaration())
        ||  (F.hasName() && (libc_nonstatic_func_names.count(F.getName().str()) > 0)) ){
        //if(F.hasName() && !F.isDeclaration()){
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
    Type *ArgTypes2_orig[] = { int32Ty, int32Ty };
    Type *ArgTypes64[] = { int64Ty };

    Type *ArgTypes0[] = { int32Ty, int32Ty }; // func_or_loop_id and deck_id
    Type *ArgTypes1[] = { int32Ty, int32Ty, int32Ty }; // func_or_loop_id, deck_id, and arg1
    Type *ArgTypes2[] = { int32Ty, int32Ty, int32Ty, int32Ty };
    Type *ArgTypes3[] = { int32Ty, int32Ty, int32Ty, int32Ty, int32Ty };
    Type *ArgTypes4[] = { int32Ty, int32Ty, int32Ty, int32Ty, int32Ty, int32Ty };
    Type *ArgTypes5[] = { int32Ty, int32Ty, int32Ty, int32Ty, int32Ty, int32Ty, int32Ty };

    Type *ArgTypes0_64[] = { int64Ty, int64Ty }; // fp_addr and deck_id
    Type *ArgTypes1_64[] = { int64Ty, int64Ty, int64Ty }; // fp_addr, deck_id, and arg1
    Type *ArgTypes2_64[] = { int64Ty, int64Ty, int64Ty, int64Ty };
    Type *ArgTypes3_64[] = { int64Ty, int64Ty, int64Ty, int64Ty, int64Ty };
    Type *ArgTypes4_64[] = { int64Ty, int64Ty, int64Ty, int64Ty, int64Ty, int64Ty };
    Type *ArgTypes5_64[] = { int64Ty, int64Ty, int64Ty, int64Ty, int64Ty, int64Ty, int64Ty };

    debrt_init_func = Function::Create(FunctionType::get(int32Ty, ArgTypes2_orig, false),
            Function::ExternalLinkage,
            "debrt_init",
            M);
    debrt_destroy_func = Function::Create(FunctionType::get(int32Ty, ArgTypes, false),
            Function::ExternalLinkage,
            "debrt_destroy",
            M);
    debrt_protect_single_func = Function::Create(FunctionType::get(int32Ty, ArgTypes, false),
            Function::ExternalLinkage,
            "debrt_protect_single",
            M);
    debrt_protect_single_end_func = Function::Create(FunctionType::get(int32Ty, ArgTypes, false),
            Function::ExternalLinkage,
            "debrt_protect_single_end",
            M);
    debrt_protect_reachable_func = (Function *) (M.getOrInsertFunction(
        "debrt_protect_reachable",
        FunctionType::get(int32Ty, ArgTypes, false)).getCallee());
    debrt_protect_reachable_end_func = (Function *) (M.getOrInsertFunction(
        "debrt_protect_reachable_end",
        FunctionType::get(int32Ty, ArgTypes, false)).getCallee());
    debrt_protect_loop_func = Function::Create(FunctionType::get(int32Ty, ArgTypes, false),
            Function::ExternalLinkage,
            "debrt_protect_loop",
            M);
    debrt_protect_indirect_func = (Function *) (M.getOrInsertFunction(
        "debrt_protect_indirect",
        FunctionType::get(int32Ty, ArgTypes64, false)).getCallee());
    debrt_protect_indirect_end_func = (Function *) (M.getOrInsertFunction(
        "debrt_protect_indirect_end",
        FunctionType::get(int32Ty, ArgTypes64, false)).getCallee());
    debrt_protect_sink_func = Function::Create(FunctionType::get(int32Ty, ArgTypes, false),
            Function::ExternalLinkage,
            "debrt_protect_sink",
            M);
    debrt_protect_sink_end_func = Function::Create(FunctionType::get(int32Ty, ArgTypes, false),
            Function::ExternalLinkage,
            "debrt_protect_sink_end",
            M);
    debrt_profile_trace_func = Function::Create(FunctionType::get(int32Ty, ArgTypes, false),
            Function::ExternalLinkage,
            "debrt_profile_trace",
            M);
    debrt_profile_print_args_0_func = Function::Create(FunctionType::get(int32Ty, ArgTypes0, false),
            Function::ExternalLinkage,
            "debrt_profile_print_args_0",
            M);
    debrt_profile_print_args_1_func = Function::Create(FunctionType::get(int32Ty, ArgTypes1, false),
            Function::ExternalLinkage,
            "debrt_profile_print_args_1",
            M);
    debrt_profile_print_args_2_func = Function::Create(FunctionType::get(int32Ty, ArgTypes2, false),
            Function::ExternalLinkage,
            "debrt_profile_print_args_2",
            M);
    debrt_profile_print_args_3_func = Function::Create(FunctionType::get(int32Ty, ArgTypes3, false),
            Function::ExternalLinkage,
            "debrt_profile_print_args_3",
            M);
    debrt_profile_print_args_4_func = Function::Create(FunctionType::get(int32Ty, ArgTypes4, false),
            Function::ExternalLinkage,
            "debrt_profile_print_args_4",
            M);
    debrt_profile_print_args_5_func = Function::Create(FunctionType::get(int32Ty, ArgTypes5, false),
            Function::ExternalLinkage,
            "debrt_profile_print_args_5",
            M);
    debrt_profile_indirect_print_args_0_func
      = Function::Create(FunctionType::get(int32Ty, ArgTypes0_64, false),
            Function::ExternalLinkage,
            "debrt_profile_indirect_print_args_0",
            M);
    debrt_profile_indirect_print_args_1_func
      = Function::Create(FunctionType::get(int32Ty, ArgTypes1_64, false),
            Function::ExternalLinkage,
            "debrt_profile_indirect_print_args_1",
            M);
    debrt_profile_indirect_print_args_2_func
      = Function::Create(FunctionType::get(int32Ty, ArgTypes2_64, false),
            Function::ExternalLinkage,
            "debrt_profile_indirect_print_args_2",
            M);
    debrt_profile_indirect_print_args_3_func
      = Function::Create(FunctionType::get(int32Ty, ArgTypes3_64, false),
            Function::ExternalLinkage,
            "debrt_profile_indirect_print_args_3",
            M);
    debrt_profile_indirect_print_args_4_func
      = Function::Create(FunctionType::get(int32Ty, ArgTypes4_64, false),
            Function::ExternalLinkage,
            "debrt_profile_indirect_print_args_4",
            M);
    debrt_profile_indirect_print_args_5_func
      = Function::Create(FunctionType::get(int32Ty, ArgTypes5_64, false),
            Function::ExternalLinkage,
            "debrt_profile_indirect_print_args_5",
            M);
    debrt_profile_update_recorded_funcs_func
      = Function::Create(FunctionType::get(int32Ty, ArgTypes, false),
            Function::ExternalWeakLinkage,
            "debrt_profile_update_recorded_funcs",
            M);
    debrt_test_predict_trace_func
      = Function::Create(FunctionType::get(int32Ty, ArgTypes, false),
            Function::ExternalLinkage,
            "debrt_test_predict_trace",
            M);
    debrt_test_predict_predict_0_func
      = Function::Create(FunctionType::get(int32Ty, ArgTypes0, false),
            Function::ExternalLinkage,
            "debrt_test_predict_predict_0",
            M);
    debrt_test_predict_predict_1_func
      = Function::Create(FunctionType::get(int32Ty, ArgTypes1, false),
            Function::ExternalLinkage,
            "debrt_test_predict_predict_1",
            M);
    debrt_test_predict_predict_2_func
      = Function::Create(FunctionType::get(int32Ty, ArgTypes2, false),
            Function::ExternalLinkage,
            "debrt_test_predict_predict_2",
            M);
    debrt_test_predict_predict_3_func
      = Function::Create(FunctionType::get(int32Ty, ArgTypes3, false),
            Function::ExternalLinkage,
            "debrt_test_predict_predict_3",
            M);
    debrt_test_predict_predict_4_func
      = Function::Create(FunctionType::get(int32Ty, ArgTypes4, false),
            Function::ExternalLinkage,
            "debrt_test_predict_predict_4",
            M);
    debrt_test_predict_predict_5_func
      = Function::Create(FunctionType::get(int32Ty, ArgTypes5, false),
            Function::ExternalLinkage,
            "debrt_test_predict_predict_5",
            M);
    debrt_test_predict_indirect_predict_0_func
      = Function::Create(FunctionType::get(int32Ty, ArgTypes0_64, false),
            Function::ExternalLinkage,
            "debrt_test_predict_indirect_predict_0",
            M);
    debrt_test_predict_indirect_predict_1_func
      = Function::Create(FunctionType::get(int32Ty, ArgTypes1_64, false),
            Function::ExternalLinkage,
            "debrt_test_predict_indirect_predict_1",
            M);
    debrt_test_predict_indirect_predict_2_func
      = Function::Create(FunctionType::get(int32Ty, ArgTypes2_64, false),
            Function::ExternalLinkage,
            "debrt_test_predict_indirect_predict_2",
            M);
    debrt_test_predict_indirect_predict_3_func
      = Function::Create(FunctionType::get(int32Ty, ArgTypes3_64, false),
            Function::ExternalLinkage,
            "debrt_test_predict_indirect_predict_3",
            M);
    debrt_test_predict_indirect_predict_4_func
      = Function::Create(FunctionType::get(int32Ty, ArgTypes4_64, false),
            Function::ExternalLinkage,
            "debrt_test_predict_indirect_predict_4",
            M);
    debrt_test_predict_indirect_predict_5_func
      = Function::Create(FunctionType::get(int32Ty, ArgTypes5_64, false),
            Function::ExternalLinkage,
            "debrt_test_predict_indirect_predict_5",
            M);
    debrt_release_predict_0_func
      = Function::Create(FunctionType::get(int32Ty, ArgTypes0, false),
            Function::ExternalLinkage,
            "debrt_release_predict_0",
            M);
    debrt_release_predict_1_func
      = Function::Create(FunctionType::get(int32Ty, ArgTypes1, false),
            Function::ExternalLinkage,
            "debrt_release_predict_1",
            M);
    debrt_release_predict_2_func
      = Function::Create(FunctionType::get(int32Ty, ArgTypes2, false),
            Function::ExternalLinkage,
            "debrt_release_predict_2",
            M);
    debrt_release_predict_3_func
      = Function::Create(FunctionType::get(int32Ty, ArgTypes3, false),
            Function::ExternalLinkage,
            "debrt_release_predict_3",
            M);
    debrt_release_predict_4_func
      = Function::Create(FunctionType::get(int32Ty, ArgTypes4, false),
            Function::ExternalLinkage,
            "debrt_release_predict_4",
            M);
    debrt_release_predict_5_func
      = Function::Create(FunctionType::get(int32Ty, ArgTypes5, false),
            Function::ExternalLinkage,
            "debrt_release_predict_5",
            M);
    debrt_release_indirect_predict_0_func
      = Function::Create(FunctionType::get(int32Ty, ArgTypes0_64, false),
            Function::ExternalLinkage,
            "debrt_release_indirect_predict_0",
            M);
    debrt_release_indirect_predict_1_func
      = Function::Create(FunctionType::get(int32Ty, ArgTypes1_64, false),
            Function::ExternalLinkage,
            "debrt_release_indirect_predict_1",
            M);
    debrt_release_indirect_predict_2_func
      = Function::Create(FunctionType::get(int32Ty, ArgTypes2_64, false),
            Function::ExternalLinkage,
            "debrt_release_indirect_predict_2",
            M);
    debrt_release_indirect_predict_3_func
      = Function::Create(FunctionType::get(int32Ty, ArgTypes3_64, false),
            Function::ExternalLinkage,
            "debrt_release_indirect_predict_3",
            M);
    debrt_release_indirect_predict_4_func
      = Function::Create(FunctionType::get(int32Ty, ArgTypes4_64, false),
            Function::ExternalLinkage,
            "debrt_release_indirect_predict_4",
            M);
    debrt_release_indirect_predict_5_func
      = Function::Create(FunctionType::get(int32Ty, ArgTypes5_64, false),
            Function::ExternalLinkage,
            "debrt_release_indirect_predict_5",
            M);


    ics_static_map_indirect_call_func
      = M.getFunction("ics_static_map_indirect_call");
    ics_static_wrapper_debrt_protect_loop_end_func
      = M.getFunction("ics_static_wrapper_debrt_protect_loop_end");
    ics_profile_map_indirect_call_0_func
      = M.getFunction("ics_profile_map_indirect_call_0");
    ics_profile_map_indirect_call_1_func
      = M.getFunction("ics_profile_map_indirect_call_1");
    ics_profile_map_indirect_call_2_func
      = M.getFunction("ics_profile_map_indirect_call_2");
    ics_profile_map_indirect_call_3_func
      = M.getFunction("ics_profile_map_indirect_call_3");
    ics_profile_map_indirect_call_4_func
      = M.getFunction("ics_profile_map_indirect_call_4");
    ics_profile_map_indirect_call_5_func
      = M.getFunction("ics_profile_map_indirect_call_5");
    ics_profile_end_indirect_call_func
      = M.getFunction("ics_profile_end_indirect_call");
    ics_profile_wrapper_debrt_protect_loop_end_func
      = M.getFunction("ics_profile_wrapper_debrt_protect_loop_end");
    ics_test_predict_map_indirect_call_0_func
      = M.getFunction("ics_test_predict_map_indirect_call_0");
    ics_test_predict_map_indirect_call_1_func
      = M.getFunction("ics_test_predict_map_indirect_call_1");
    ics_test_predict_map_indirect_call_2_func
      = M.getFunction("ics_test_predict_map_indirect_call_2");
    ics_test_predict_map_indirect_call_3_func
      = M.getFunction("ics_test_predict_map_indirect_call_3");
    ics_test_predict_map_indirect_call_4_func
      = M.getFunction("ics_test_predict_map_indirect_call_4");
    ics_test_predict_map_indirect_call_5_func
      = M.getFunction("ics_test_predict_map_indirect_call_5");
    ics_test_predict_wrapper_debrt_protect_loop_end_func
      = M.getFunction("ics_test_predict_wrapper_debrt_protect_loop_end");
    ics_release_map_indirect_call_0_func
      = M.getFunction("ics_release_map_indirect_call_0");
    ics_release_map_indirect_call_1_func
      = M.getFunction("ics_release_map_indirect_call_1");
    ics_release_map_indirect_call_2_func
      = M.getFunction("ics_release_map_indirect_call_2");
    ics_release_map_indirect_call_3_func
      = M.getFunction("ics_release_map_indirect_call_3");
    ics_release_map_indirect_call_4_func
      = M.getFunction("ics_release_map_indirect_call_4");
    ics_release_map_indirect_call_5_func
      = M.getFunction("ics_release_map_indirect_call_5");
    ics_release_wrapper_debrt_protect_loop_end_func
      = M.getFunction("ics_release_wrapper_debrt_protect_loop_end");
    ics_release_wrapper_debrt_protect_reachable_end_func
      = M.getFunction("ics_release_wrapper_debrt_protect_reachable_end");
    ics_release_wrapper_debrt_protect_indirect_end_func
      = M.getFunction("ics_release_wrapper_debrt_protect_indirect_end");
    ics_release_rectify_func
      = M.getFunction("ics_release_rectify");
    ics_release_trace_func
      = M.getFunction("ics_release_trace");


    debrt_profile_print_args_funcs[0] = debrt_profile_print_args_0_func;
    debrt_profile_print_args_funcs[1] = debrt_profile_print_args_1_func;
    debrt_profile_print_args_funcs[2] = debrt_profile_print_args_2_func;
    debrt_profile_print_args_funcs[3] = debrt_profile_print_args_3_func;
    debrt_profile_print_args_funcs[4] = debrt_profile_print_args_4_func;
    debrt_profile_print_args_funcs[5] = debrt_profile_print_args_5_func;
    debrt_profile_indirect_print_args_funcs[0] = debrt_profile_indirect_print_args_0_func;
    debrt_profile_indirect_print_args_funcs[1] = debrt_profile_indirect_print_args_1_func;
    debrt_profile_indirect_print_args_funcs[2] = debrt_profile_indirect_print_args_2_func;
    debrt_profile_indirect_print_args_funcs[3] = debrt_profile_indirect_print_args_3_func;
    debrt_profile_indirect_print_args_funcs[4] = debrt_profile_indirect_print_args_4_func;
    debrt_profile_indirect_print_args_funcs[5] = debrt_profile_indirect_print_args_5_func;
    debrt_test_predict_predict_funcs[0] = debrt_test_predict_predict_0_func;
    debrt_test_predict_predict_funcs[1] = debrt_test_predict_predict_1_func;
    debrt_test_predict_predict_funcs[2] = debrt_test_predict_predict_2_func;
    debrt_test_predict_predict_funcs[3] = debrt_test_predict_predict_3_func;
    debrt_test_predict_predict_funcs[4] = debrt_test_predict_predict_4_func;
    debrt_test_predict_predict_funcs[5] = debrt_test_predict_predict_5_func;
    debrt_release_predict_funcs[0] = debrt_release_predict_0_func;
    debrt_release_predict_funcs[1] = debrt_release_predict_1_func;
    debrt_release_predict_funcs[2] = debrt_release_predict_2_func;
    debrt_release_predict_funcs[3] = debrt_release_predict_3_func;
    debrt_release_predict_funcs[4] = debrt_release_predict_4_func;
    debrt_release_predict_funcs[5] = debrt_release_predict_5_func;
    debrt_release_indirect_predict_funcs[0] = debrt_release_indirect_predict_0_func;
    debrt_release_indirect_predict_funcs[1] = debrt_release_indirect_predict_1_func;
    debrt_release_indirect_predict_funcs[2] = debrt_release_indirect_predict_2_func;
    debrt_release_indirect_predict_funcs[3] = debrt_release_indirect_predict_3_func;
    debrt_release_indirect_predict_funcs[4] = debrt_release_indirect_predict_4_func;
    debrt_release_indirect_predict_funcs[5] = debrt_release_indirect_predict_5_func;
    ics_profile_map_indirect_call_funcs[0] = ics_profile_map_indirect_call_0_func;
    ics_profile_map_indirect_call_funcs[1] = ics_profile_map_indirect_call_1_func;
    ics_profile_map_indirect_call_funcs[2] = ics_profile_map_indirect_call_2_func;
    ics_profile_map_indirect_call_funcs[3] = ics_profile_map_indirect_call_3_func;
    ics_profile_map_indirect_call_funcs[4] = ics_profile_map_indirect_call_4_func;
    ics_profile_map_indirect_call_funcs[5] = ics_profile_map_indirect_call_5_func;
    ics_test_predict_map_indirect_call_funcs[0] = ics_test_predict_map_indirect_call_0_func;
    ics_test_predict_map_indirect_call_funcs[1] = ics_test_predict_map_indirect_call_1_func;
    ics_test_predict_map_indirect_call_funcs[2] = ics_test_predict_map_indirect_call_2_func;
    ics_test_predict_map_indirect_call_funcs[3] = ics_test_predict_map_indirect_call_3_func;
    ics_test_predict_map_indirect_call_funcs[4] = ics_test_predict_map_indirect_call_4_func;
    ics_test_predict_map_indirect_call_funcs[5] = ics_test_predict_map_indirect_call_5_func;
    ics_release_map_indirect_call_funcs[0] = ics_release_map_indirect_call_0_func;
    ics_release_map_indirect_call_funcs[1] = ics_release_map_indirect_call_1_func;
    ics_release_map_indirect_call_funcs[2] = ics_release_map_indirect_call_2_func;
    ics_release_map_indirect_call_funcs[3] = ics_release_map_indirect_call_3_func;
    ics_release_map_indirect_call_funcs[4] = ics_release_map_indirect_call_4_func;
    ics_release_map_indirect_call_funcs[5] = ics_release_map_indirect_call_5_func;


    ics_func_names.insert("ics_static_map_indirect_call");
    ics_func_names.insert("ics_static_wrapper_debrt_protect_loop_end");
    ics_func_names.insert("ics_profile_map_indirect_call_0");
    ics_func_names.insert("ics_profile_map_indirect_call_1");
    ics_func_names.insert("ics_profile_map_indirect_call_2");
    ics_func_names.insert("ics_profile_map_indirect_call_3");
    ics_func_names.insert("ics_profile_map_indirect_call_4");
    ics_func_names.insert("ics_profile_map_indirect_call_5");
    ics_func_names.insert("ics_profile_end_indirect_call");
    ics_func_names.insert("ics_profile_wrapper_debrt_protect_loop_end");
    ics_func_names.insert("ics_test_predict_map_indirect_call_0");
    ics_func_names.insert("ics_test_predict_map_indirect_call_1");
    ics_func_names.insert("ics_test_predict_map_indirect_call_2");
    ics_func_names.insert("ics_test_predict_map_indirect_call_3");
    ics_func_names.insert("ics_test_predict_map_indirect_call_4");
    ics_func_names.insert("ics_test_predict_map_indirect_call_5");
    ics_func_names.insert("ics_test_predict_wrapper_debrt_protect_loop_end");
    ics_func_names.insert("ics_release_map_indirect_call_0");
    ics_func_names.insert("ics_release_map_indirect_call_1");
    ics_func_names.insert("ics_release_map_indirect_call_2");
    ics_func_names.insert("ics_release_map_indirect_call_3");
    ics_func_names.insert("ics_release_map_indirect_call_4");
    ics_func_names.insert("ics_release_map_indirect_call_5");
    ics_func_names.insert("ics_release_wrapper_debrt_protect_loop_end");
    ics_func_names.insert("ics_release_wrapper_debrt_protect_reachable_end");
    ics_func_names.insert("ics_release_wrapper_debrt_protect_indirect_end");
    ics_func_names.insert("ics_release_rectify");
    ics_func_names.insert("ics_release_trace");


}



bool AdvancedRuntimeDebloat::runOnModule_real(Module &M)
{
    // Initialization
    artd_init(M);

    // Build all_funcs, adj_list, func_to_loop_info
    // Paritlally build encompassed_funcs
    build_basic_structs(M);


    if(ARTD_BUILD == ARTD_BUILD_DATALOG_E){
        capture_ensue(M);
        dump_callsite_to_id();
        dump_datalog_relations();
        return false;
    }
    if(ARTD_BUILD == ARTD_BUILD_MAYMUST_E){
        total_num_calls = 0;
        total_antic_calls = 0;
        capture_maymust(M);
        errs() << "total-number-of-calls: " << total_num_calls << "\n";
        errs() << "total-number-of-anticipated-calls: " << total_antic_calls << "\n";
        return false;
    }

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
    // XXX Will instrument the top of other functions if ARTD_BUILD is ARTD_BUILD_PROFILE_E
    instrument_main_start(M);

    // Instrument all other functions
    instrument();

    // Instrument main with a debrt-destroy call.
    // Doing this AFTER all other instrumentation to to ensure every exit block
    // calls destroy after any other instrumentation. (That is, it's probably a
    // bad idea to relocate this code into instrument_main_start() and
    // before instrument().)
    instrument_main_end(M);

    // finalize disjoint sets
    // XXX 2023.06.01 not "final" anymore. build_RPs will read
    // func-set-id-to-funcs which will end up whittling down the disjoint
    // sets further.
    finalize_disjoint_sets();

    if(ARTD_BUILD == ARTD_BUILD_RELEASE_E){
        build_RPs();
        instrument_RPs();
    }
}


void AdvancedRuntimeDebloat::capture_maymust_aux(Function &F)
{
    errs() << "Processing " << F.getName() << "\n";

    map<BasicBlock *, set<Function *> > in_antic;
    map<BasicBlock *, set<Function *> > out_antic;

    int func_id = func_to_id[&F];

    // anticipated  (backward):
    // OUT_ANTIC[B] = INTERSECT_{S succ of B} IN_ANTIC[S]
    // IN_ANTIC[B]  = OUT_ANTIC[B] U called_in[B]

    bool changed = true;
    while(changed){
        changed = false;
        for(BasicBlock &B : F){

            set<Function *> old_in_antic = in_antic[&B];

            //BasicBlock *single = B.getSingleSuccessor();

            succ_iterator SI = succ_begin(&B);
            succ_iterator SE = succ_end(&B);
            if(SI == SE){
                // no successors
                // nothing to do
            }else{
                if((SI+1) == SE){
                    // single successor at SI
                    for(Function *f : in_antic[(*SI)]){
                        out_antic[&B].insert(f);
                    }
                }else{
                    // multiple successors
                    succ_iterator SI = succ_begin(&B);
                    while((SI+1) != SE){
                        set_intersection(in_antic[(*SI)].begin(),
                                         in_antic[(*SI)].end(),
                                         in_antic[(*(SI+1))].begin(),
                                         in_antic[(*(SI+1))].end(),
                                         inserter(out_antic[&B], out_antic[&B].end()));
                        SI++;
                    }
                }
            }

            for(CallBase *CB : block_to_callsites[&B]){
                Function *callee = CB->getCalledFunction();
                in_antic[&B].insert(callee);
            }

            if(in_antic[&B] != old_in_antic){
                changed = true;
            }
        }
    }

    //errs() << "  number of calls:             " << func_to_num_calls[&F] << "\n";
    //errs() << "  number of anticipated calls: " << in_antic[&(F.getEntryBlock())].size() << "\n";
    //total_num_calls   += func_to_num_calls[&F];
    //total_antic_calls += in_antic[&(F.getEntryBlock())].size();

    total_num_calls   += adj_list[&F].size();
    total_antic_calls += in_antic[&(F.getEntryBlock())].size();

}


// XXX this function can probably be deleted, but I'm leaving now for
// posterity. I believe it was done incorrectly. It calculates the
// anticipated function calls based on the CallBase, which is basically
// just the callsite. And that's not what we want, I don't think. I think
// the result for this was like 91% MAY cases. But if you're using callsites
// like this, I think this just devolves into a postdom question. That's
// not what we want. We want to know about which /functions/ are getting
// called, not which callsites are getting hit. For example, if foo invokes
// bar in two different places, we care if bar MAY or MUST get called, not
// if callsite-1-bar MAY or MUST get called and callsite-2-bar MAY or MUST
// get called.
void AdvancedRuntimeDebloat::capture_maymust_aux_callbase_notright(Function &F)
{
    errs() << "Processing " << F.getName() << "\n";

    map<BasicBlock *, set<CallBase *> > in_antic;
    map<BasicBlock *, set<CallBase *> > out_antic;

    int func_id = func_to_id[&F];

    // anticipated  (backward):
    // OUT_ANTIC[B] = INTERSECT_{S succ of B} IN_ANTIC[S]
    // IN_ANTIC[B]  = OUT_ANTIC[B] U called_in[B]

    bool changed = true;
    while(changed){
        changed = false;
        for(BasicBlock &B : F){

            set<CallBase *> old_in_antic = in_antic[&B];

            //BasicBlock *single = B.getSingleSuccessor();

            succ_iterator SI = succ_begin(&B);
            succ_iterator SE = succ_end(&B);
            if(SI == SE){
                // no successors
                // nothing to do
            }else{
                if((SI+1) == SE){
                    // single successor at SI
                    for(CallBase *n : in_antic[(*SI)]){
                        out_antic[&B].insert(n);
                    }
                }else{
                    // multiple successors
                    succ_iterator SI = succ_begin(&B);
                    while((SI+1) != SE){
                        set_intersection(in_antic[(*SI)].begin(),
                                         in_antic[(*SI)].end(),
                                         in_antic[(*(SI+1))].begin(),
                                         in_antic[(*(SI+1))].end(),
                                         inserter(out_antic[&B], out_antic[&B].end()));
                        SI++;
                    }
                }
            }

            for(CallBase *CB : block_to_callsites[&B]){
                in_antic[&B].insert(CB);
            }

            if(in_antic[&B] != old_in_antic){
                changed = true;
            }
        }
    }

    //errs() << "  number of calls:             " << func_to_num_calls[&F] << "\n";
    //errs() << "  number of anticipated calls: " << in_antic[&(F.getEntryBlock())].size() << "\n";
    total_num_calls   += func_to_num_calls[&F];
    total_antic_calls += in_antic[&(F.getEntryBlock())].size();

}


void AdvancedRuntimeDebloat::capture_ensue_aux(Function &F)
{
    //errs() << "Processing " << F.getName() << "\n";

    map<BasicBlock *, set<CallBase *> > in_prev;
    map<BasicBlock *, set<CallBase *> > in_next;
    map<BasicBlock *, set<CallBase *> > out_prev;
    map<BasicBlock *, set<CallBase *> > out_next;

    int func_id = func_to_id[&F];

    // next (backward):
    // OUT_NEXT[B] = U_{S succ of B} IN_NEXT[S]
    // IN_NEXT[B]  = Callsites_B.first() || OUT_NEXT[B]
    //
    // prev (forward):
    // IN_PREV[B]  = U_{P pred of B} OUT_PREV[P]
    // OUT_PREV[B] = Callsites_B.last() || IN_PREV[B]

    bool changed = true;
    while(changed){
        changed = false;
        for(BasicBlock &B : F){

            set<CallBase *> old_out_prev = out_prev[&B];
            set<CallBase *> old_in_next = in_next[&B];

            for(BasicBlock *pred : predecessors(&B)){
                for(CallBase *h : out_prev[pred]){
                    in_prev[&B].insert(h);
                }
            }
            for(BasicBlock *succ : successors(&B)){
                for(CallBase *n : in_next[succ]){
                    out_next[&B].insert(n);
                }
            }

            if(block_to_callsites[&B].size() > 0){
                out_prev[&B].insert(block_to_callsites[&B].back());
                in_next[&B].insert(block_to_callsites[&B].front());
            }else{
                out_prev[&B] = in_prev[&B];
                in_next[&B] = out_next[&B];
            }

            if(out_prev[&B] != old_out_prev || in_next[&B] != old_in_next){
                changed = true;
            }

        }
    }

    BasicBlock &entry_block = F.getEntryBlock();

    // update head
    assert(head.find(func_id) == head.end());
    for(CallBase *n : in_next[&entry_block]){
        int callsite_id = callsite_to_id[n];
        head[func_id].insert(callsite_id);
    }

    // update tail and next
    assert(tail.find(func_id) == tail.end());
    vector<BasicBlock *> s;
    set<BasicBlock *> visited;
    s.push_back(&entry_block);
    while(!s.empty()){
        BasicBlock *B = s.back();
        s.pop_back();
        if(visited.find(B) == visited.end()){

            // visit tail
            auto succs = successors(B);
            int num_succs = distance(succs.begin(), succs.end());
            if(num_succs == 0){
                for(CallBase *t : out_prev[B]){
                    int callsite_id = callsite_to_id[t];
                    tail[func_id].insert(callsite_id);
                }
            }else{
                for(BasicBlock *succ : succs){
                    s.push_back(succ);
                }
            }

            // visit next
            if(block_to_callsites[B].size() > 0){
                int back_callsite_id = callsite_to_id[block_to_callsites[B].back()];
                for(CallBase *n : out_next[B]){
                    int next_callsite_id = callsite_to_id[n];
                    next[func_id].insert(make_pair(back_callsite_id, next_callsite_id));
                }
            }
            if(block_to_callsites[B].size() > 1){
                for(int i = 0; i < (block_to_callsites[B].size() - 1); i++){
                    int callsite_id_a = callsite_to_id[block_to_callsites[B][i]];
                    int callsite_id_b = callsite_to_id[block_to_callsites[B][i+1]];
                    next[func_id].insert(make_pair(callsite_id_a, callsite_id_b));
                }
            }

            visited.insert(B);
        }
    }

}


void AdvancedRuntimeDebloat::capture_ensue(Module &M)
{
    long start_time_ns;
    long capture_ensue_time_ns;
    start_time_ns = timestamp_ns();
    for(Function &F : M){
        if(F.hasName() && !F.isDeclaration()){
            capture_ensue_aux(F);
        }
    }
    capture_ensue_time_ns = timestamp_ns() - start_time_ns;
    errs() << "capture-ensue-time-ns: " << capture_ensue_time_ns << "\n";
}


void AdvancedRuntimeDebloat::capture_maymust(Module &M)
{
    errs() << "Capturing maymust\n";
    for(Function &F : M){
        if(F.hasName() && !F.isDeclaration()){
            capture_maymust_aux(F);
        }
    }
}


bool AdvancedRuntimeDebloat::runOnModule(Module &M)
{
    runOnModule_real(M);
    return true;
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

void AdvancedRuntimeDebloat::dump_static_reachability(void)
{
    FILE *fp_reachability = fopen("artd_static_reachability.txt", "w");
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
void AdvancedRuntimeDebloat::dump_loop_static_reachability(void)
{
    FILE *fp_loop_reachability;
    if(ENABLE_INSTRUMENTATION_SINKING){
        fp_loop_reachability = fopen("artd_loop_static_reachability_sinkenabled.txt", "w");
    }else{
        fp_loop_reachability = fopen("artd_loop_static_reachability.txt", "w");
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
void AdvancedRuntimeDebloat::dump_encompassed_funcs(void)
{
    FILE *fp_encompassed = fopen("artd_encompassed_funcs.txt", "w");
    for(auto ef : encompassed_funcs){
        int func_id = func_to_id[ef];
        fprintf(fp_encompassed, "%d (%s)\n", func_id, func_id_to_name[func_id].c_str());
    }
    fclose(fp_encompassed);
}
void AdvancedRuntimeDebloat::dump_loop_id_to_func_id(void)
{
    FILE *fp_loop_to_func = fopen("artd_loop_to_func.txt", "w");
    for(auto p : loop_id_to_func_id){
        int loop_id = p.first;
        int func_id = p.second;
        //errs() << l->getName() << ": ";
        //fprintf(fp_loop_to_func, "%s ", l->getName().str().c_str());
        fprintf(fp_loop_to_func, "%d: %d (%s)\n", loop_id, func_id, func_id_to_name[func_id].c_str());
    }
    fclose(fp_loop_to_func);
}
void AdvancedRuntimeDebloat::dump_sink_id_to_func_id(void)
{
    FILE *fp_sink_to_func = fopen("artd_sink_to_func.txt", "w");
    for(auto p : sink_id_to_func_id){
        int sink_id = p.first;
        int func_id = p.second;
        //errs() << l->getName() << ": ";
        //fprintf(fp_loop_to_func, "%s ", l->getName().str().c_str());
        fprintf(fp_sink_to_func, "%d: %d (%s)\n", sink_id, func_id, func_id_to_name[func_id].c_str());
    }
    fclose(fp_sink_to_func);
}
void AdvancedRuntimeDebloat::dump_sinks(void)
{
    FILE *fp_sinks = fopen("artd_sinks.txt", "w");
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
void AdvancedRuntimeDebloat::dump_func_ptrs(void)
{
    FILE *fp_funcptrs = fopen("artd_func_name_has_addr_taken.txt", "w");
    for(auto func_name : func_name_has_addr_taken){
        fprintf(fp_funcptrs, "%s\n", func_name.c_str());
    }
    fclose(fp_funcptrs);
}
void AdvancedRuntimeDebloat::dump_func_name_to_id(void)
{
    FILE *fp = fopen("artd_func_name_to_id.txt", "w");
    for(auto fn2id : func_name_to_id){
        fprintf(fp, "%s %u\n", fn2id.first.c_str(), fn2id.second);
    }
    fclose(fp);
}
void AdvancedRuntimeDebloat::print_disjoint_sets(void)
{
    for(auto set : disjoint_sets){
        if(set.second->size() > 0)
        {
            errs() << set.first << ": ";
            for(auto f : *(set.second))
            {
                errs() << func_to_id[f] << " ";
            }
            errs() << "\n";
        }
    }
}
void AdvancedRuntimeDebloat::dump_disjoint_sets(void)
{
    FILE *fp = fopen("artd_disjoint_sets.txt", "w");
    for(auto set : disjoint_sets){
        if(set.second->size() > 0)
        {
            fprintf(fp, "%ld: ", set.first);
            for(auto f : *(set.second))
            {
                fprintf(fp, "%u ", func_to_id[f]);
            }
            fprintf(fp, "\n");
        }
    }
    fclose(fp);
}
void AdvancedRuntimeDebloat::dump_stats(void)
{
    FILE *fp = fopen("artd_stats.txt", "w");
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
    fprintf(fp, "Number of rectification points inserted: %d\n", stats.num_RPs);
    fclose(fp);
}
void AdvancedRuntimeDebloat::dump_deck_id_to_caller_callee(void)
{
    FILE *fp = fopen("artd_deck_id_to_caller_callee.txt", "w");
    fprintf(fp, "deck_id,caller,callee\n");
    for(auto it = deck_id_to_caller_callee.begin(); it != deck_id_to_caller_callee.end(); it++){
        int deck_id = it->first;
        if(it->second.second == NULL){
            assert(it->second.first != NULL);
            // XXX The callee can be set to NULL when the callsite
            // is an indirect call. In that case, we still capture the parent
            // (i.e. the caller) but cannot get the callee.
            fprintf(fp, "%d,%s,NULL-indirect\n",
              it->first,
              it->second.first->getName().str().c_str());
        }else{
            fprintf(fp, "%d,%s,%s\n",
              it->first,
              it->second.first->getName().str().c_str(),
              it->second.second->getName().str().c_str());
        }
    }
    fclose(fp);
}
void AdvancedRuntimeDebloat::print_func_set_id_deck_root_pairs(void)
{
    for(auto it = func_set_id_deck_root_pairs.begin(); it != func_set_id_deck_root_pairs.end(); it++){
        errs() << it->first << " " << it->second << "\n";
    }
}
void AdvancedRuntimeDebloat::print_func_set_id_to_funcs(void)
{
    for(int func_set_id = 0; func_set_id < func_set_id_to_funcs.size(); func_set_id++){
        set<int> &pred_set_ids = func_set_id_to_funcs[func_set_id];
        errs() << func_set_id << ":";
        for(auto it = pred_set_ids.begin(); it != pred_set_ids.end(); it++){
            int func_id = *it;
            errs() << " " << func_id;
        }
        errs() << "\n";
    }
}
void AdvancedRuntimeDebloat::dump_RPs(void)
{
    FILE *fp = fopen("artd_RPs.txt", "w");
    fprintf(fp, "caller,callee1,callee2,...\n");
    for(auto it = RPs.begin(); it != RPs.end(); it++){
        int caller_id = it->first;
        set<int> &callee_ids = it->second;
        fprintf(fp, "%d", caller_id);
        for(auto itt = callee_ids.begin(); itt != callee_ids.end(); itt++){
            fprintf(fp, ",%d", (*itt));
        }
        fprintf(fp, "\n");
    }
    fclose(fp);
}
void AdvancedRuntimeDebloat::dump_func_set_id_to_complements(void)
{
    FILE *fp = fopen("func-set-id-to-complements.out", "w");
    fprintf(fp, "predicted_func_set_id,deck_root_id,complement_func_id1,complement_func_id2,...\n");

    for(int func_set_id = 0; func_set_id < func_set_id_to_complements.size(); func_set_id++){
        map<int, set<Function *> > &deck_ids_to_complements = func_set_id_to_complements[func_set_id];
        for(auto deck_id_to_complements : deck_ids_to_complements){
            int deck_id = deck_id_to_complements.first;
            set <Function *> &complements = deck_id_to_complements.second;

            // write the func set ID
            fprintf(fp, "%d", func_set_id);

            // write the deck ID
            fprintf(fp, ",%d", deck_id);

            // write the pred set's complements for the given func set ID
            // and deck ID
            for(auto it = complements.begin(); it != complements.end(); it++){
                fprintf(fp, ",%d", func_to_id[*it]);
            }
            fprintf(fp, "\n");
        }
    }

    fclose(fp);
}
void AdvancedRuntimeDebloat::dump_callsite_to_id(void)
{
    FILE *fp = fopen("artd-callsite-to-id.out", "w");
    //errs() << "Dumping callsite_to_id\n";
    //errs() << "callsite-id,caller-func-id,callee-func-id,callerName->calleeName\n";
    fprintf(fp, "callsite-id,caller-func-id,callee-func-id,callerName->calleeName\n");
    for(auto it = callsite_to_id.begin(); it != callsite_to_id.end(); it++){
        CallBase *CB     = it->first;
        int callsite_id  = it->second;
        Function *caller = CB->getCaller();
        Function *callee = CB->getCalledFunction();
        int caller_id    = func_to_id[caller];
        int callee_id    = func_to_id[callee];
        //errs() << callsite_id << ","
        //       << caller_id << ","
        //       << callee_id << ","
        //       << caller->getName() << "->" << callee->getName() << "\n";
        fprintf(fp, "%d,%d,%d,%s->%s\n", callsite_id, caller_id, callee_id,
                caller->getName().str().c_str(), callee->getName().str().c_str());
    }
    fclose(fp);
}
void AdvancedRuntimeDebloat::dump_datalog_relations(void)
{
    //errs() << "Dumping datalog relations\n";
    long start_time_ns;
    long dump_datalog_relations_time_ns;
    start_time_ns = timestamp_ns();
    FILE *fp = fopen("artd-datalog.out", "w");
    dump_head(fp);
    dump_tail(fp);
    dump_next(fp);
    dump_leaf(fp);
    dump_belong(fp);
    dump_last(fp);
    dump_ensue(fp);
    fclose(fp);
    dump_datalog_relations_time_ns = timestamp_ns() - start_time_ns;
    errs() << "dump-datalog-relations-time-ns: " << dump_datalog_relations_time_ns << "\n";
}
void AdvancedRuntimeDebloat::dump_head(FILE *fp)
{
    //errs() << "Dumping head\n";
    //for(auto it = head.begin(); it != head.end(); it++){
    //    int func_id = it->first;
    //    errs() << "  " << func_id_to_name[func_id] << " (func-id " << func_id << "):\n    ";
    //    set<int> &callsite_ids = it->second;
    //    for(int callsite_id : callsite_ids){
    //        errs() << callsite_id << ",";
    //    }
    //    errs() << "\n";
    //}
    for(auto it = head.begin(); it != head.end(); it++){
        int func_id = it->first;
        set<int> &callsite_ids = it->second;
        for(int callsite_id : callsite_ids){
            fprintf(fp, "head(%d,%d).\n", func_id, callsite_id);
        }
    }
}
void AdvancedRuntimeDebloat::dump_tail(FILE *fp)
{
    //errs() << "Dumping tail\n";
    //for(auto it = tail.begin(); it != tail.end(); it++){
    //    int func_id = it->first;
    //    errs() << "  " << func_id_to_name[func_id] << " (func-id " << func_id << "):\n    ";
    //    set<int> &callsite_ids = it->second;
    //    for(int callsite_id : callsite_ids){
    //        errs() << callsite_id << ",";
    //    }
    //    errs() << "\n";
    //}
    for(auto it = tail.begin(); it != tail.end(); it++){
        int func_id = it->first;
        set<int> &callsite_ids = it->second;
        for(int callsite_id : callsite_ids){
            fprintf(fp, "tail(%d,%d).\n", func_id, callsite_id);
        }
    }
}
void AdvancedRuntimeDebloat::dump_next(FILE *fp)
{
    //errs() << "Dumping next\n";
    //for(auto it = next.begin(); it != next.end(); it++){
    //    int func_id = it->first;
    //    errs() << "  " << func_id_to_name[func_id] << " (func-id " << func_id << "):\n    ";
    //    set<pair<int, int> > &callsite_id_pairs = it->second;
    //    for(auto callsite_id_pair : callsite_id_pairs){
    //        int callsite_id_a = callsite_id_pair.first;
    //        int callsite_id_b = callsite_id_pair.second;
    //        errs() << callsite_id_a << "-" << callsite_id_b << ",";
    //    }
    //    errs() << "\n";
    //}
    for(auto it = next.begin(); it != next.end(); it++){
        int func_id = it->first;
        set<pair<int, int> > &callsite_id_pairs = it->second;
        for(auto callsite_id_pair : callsite_id_pairs){
            int callsite_id_a = callsite_id_pair.first;
            int callsite_id_b = callsite_id_pair.second;
            fprintf(fp, "next(%d,%d,%d).\n", func_id, callsite_id_a, callsite_id_b);
        }
    }
}
void AdvancedRuntimeDebloat::dump_leaf(FILE *fp)
{
    //errs() << "Dumping leaf\n  ";
    //for(auto it = leaf.begin(); it != leaf.end(); it++){
    //    int func_id = *it;
    //    errs() << func_id_to_name[func_id] << "(" << func_id << "),";
    //}
    //errs() << "\n";
    for(auto it = leaf.begin(); it != leaf.end(); it++){
        int func_id = *it;
        fprintf(fp, "leaf(%d).\n", func_id);
    }
}
void AdvancedRuntimeDebloat::dump_belong(FILE *fp)
{
    //errs() << "Dumping belong\n";
    //for(auto it = belong.begin(); it != belong.end(); it++){
    //    int callsite_id = it->first;
    //    int func_id     = it->second;
    //    errs() << callsite_id << "@" << func_id << "(" << func_id_to_name[func_id] << "),";
    //}
    //errs() << "\n";
    for(auto it = belong.begin(); it != belong.end(); it++){
        int callsite_id = it->first;
        int func_id     = it->second;
        fprintf(fp, "belong(%d,%d).\n", callsite_id, func_id);
    }
}
void AdvancedRuntimeDebloat::dump_last(FILE *fp)
{
    fprintf(fp, "last(F, I) :- tail(F, I), belong(I, G), leaf(G).\n");
    fprintf(fp, "last(F, I) :- tail(F, J), belong(J, G), last(G, I).\n");
}
void AdvancedRuntimeDebloat::dump_ensue(FILE *fp)
{
    fprintf(fp, "ensue(I, J) :- head(F, J), belong(I, F).\n");
    fprintf(fp, "ensue(I, J) :- next(G, I, J), belong(I, F), leaf(F).\n");
    fprintf(fp, "ensue(I, J) :- next(G, K, J), belong(K, F), last(F, I).\n");
    fprintf(fp, "ensue(A, B)?\n");
}


string AdvancedRuntimeDebloat::get_demangled_name(const Function &F)
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
void AdvancedRuntimeDebloat::read_readelf_sections(void)
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
void AdvancedRuntimeDebloat::read_readelf(void)
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

bool AdvancedRuntimeDebloat::doFinalization(Module &M)
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
    dump_deck_id_to_caller_callee();
    dump_RPs();
    dump_func_set_id_to_complements();
    //errs() << "deck id counter: " << deck_id_counter << "\n";
    return false;
}
bool AdvancedRuntimeDebloat::doInitialization(Module &M)
{
    // XXX don't use this to initialize shit unless you want it to wig out
    return false;
}



artd_build_e AdvancedRuntimeDebloat::parseARTDBuildOpt(void)
{
    errs() << "ARTDBuild: " << ARTDBuild << "\n";
    if(ARTDBuild == "static"){
        return ARTD_BUILD_STATIC_E;
    }else if(ARTDBuild == "profile"){
        return ARTD_BUILD_PROFILE_E;
    }else if(ARTDBuild == "test_predict"){
        return ARTD_BUILD_TEST_PREDICT_E;
    }else if(ARTDBuild == "release"){
        return ARTD_BUILD_RELEASE_E;
    }else if(ARTDBuild == "datalog"){
        return ARTD_BUILD_DATALOG_E;
    }else if(ARTDBuild == "maymust"){
        return ARTD_BUILD_MAYMUST_E;
    }else{
        assert(0 && "ERROR: invalid artd-build option");
    }
}

char AdvancedRuntimeDebloat::ID = 0;
static RegisterPass<AdvancedRuntimeDebloat> Y("AdvancedRuntimeDebloat", "Advanced runtime debloat pass");
