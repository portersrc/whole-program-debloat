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

#include <set>
#include <stack>
#include <queue>
#include <string>
#include <map>
#include <algorithm>

using namespace llvm;
using namespace std;


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
        Function *debrt_protect_end_indirect_func;
        map<Function *, int> func_to_id;
        map<int, string> func_id_to_name;
        map<string, int> func_name_to_id;
        Type *int32Ty;
        Type *int64Ty;
        map<Function *, set<Function *> > adj_list;
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
        int loop_id_counter;


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
        void build_static_reachability(void);
        void extend_encompassed_funcs(void);
        void build_toplevel_funcs(void);
        void create_disjoint_sets(void);
        bool is_reachable(BasicBlock *B1, BasicBlock *B2);

        bool instrument_main(Module &M);
        void instrument(void);
        void instrument_loop(Loop *loop, int func_id);
        void instrument_loop_sink(int toplevel_func_id,
                                     Loop *toplevel_loop,
                                     vector<BasicBlock *> &BBs);
        void instrument_after_invoke(InvokeInst *II,
                                     vector<Value *> &ArgsV,
                                     Function *debrt_func);
        void instrument_indirect(void);


        string get_demangled_name(const Function &F);
        void dump_static_reachability(void);
        void dump_loop_static_reachability(void);
        void dump_encompassed_funcs(void);
        void dump_loop_id_to_func_id(void);
        void dump_func_name_to_id(void);
        void dump_func_ptrs(void);
        void dump_disjoint_sets(void);
    };
}


void WholeProgramDebloat::instrument_loop_sink(int toplevel_func_id,
                                                  Loop *toplevel_loop,
                                                  vector<BasicBlock *> &BBs)
{

    int loop_id = loop_id_counter;

    // Find preheader
    //BasicBlock *preheader = toplevel_loop->getLoopPreheader();
    //assert(preheader); // must run -loop-simplify for this to be OK.

    // TODO for common dominator probably use:
    //   https://llvm.org/doxygen/classllvm_1_1DominatorTreeBase.html

    //vector<Function *> callees;

    vector<set<BasicBlock *> > Fs; // FIXME isn't confusing that this is called Fs when it's actually basic blocks
    vector<set<Function *> > Ss;
    set<BasicBlock *> callee_blocks_set;
    vector<BasicBlock *> callee_blocks;
    map<BasicBlock *, Function *> block_to_callee;

    // Find each called function f
    for(auto B : BBs){
        for(auto &I : (*B)){
            CallBase *cb = dyn_cast<CallBase>(&I);
            if(cb){
                Function *callee = cb->getCalledFunction();
                if(func_to_id.count(callee) > 0){
                    //callees.push_back(callee);
                    assert(callee_blocks_set.find(B) == callee_blocks_set.end());
                    callee_blocks_set.insert(B); // FIXME dont want duplicates
                    callee_blocks.push_back(B);
                    block_to_callee[B] = callee;
                }
            }
        }
    }



    // Identify F sets in BBs
    int i;
    int j;
    for(i = 0; i < callee_blocks.size()-1; i++){
        for(j = i+1; j < callee_blocks.size(); j++){
            if(  is_reachable(callee_blocks[i], callee_blocks[j])
              || is_reachable(callee_blocks[j], callee_blocks[i])){
                // TODO
                // merge_Fs(i, j);
            }
        }
    }

    // Identify S sets from F sets
    for(i = 0; i < Fs.size(); i++){
        for(auto f : Fs[i]){
            Ss[i].insert(static_reachability[block_to_callee[f]].begin(), static_reachability[block_to_callee[f]].end());
        }
    }

    if(Fs.size() < 2){
        assert(Ss.size() == 1);
        for(auto f : Ss[0]){
            // FIXME: make sure to handle whatever the equivalent of this might
            // be for this new algorithm.
            //   "If there was at least one function call inside the loop, then we
            //   will instrument it."
            loop_static_reachability[loop_id].insert(f);
            // FIXME cont. : And this probably includes a bump to loop_id_counter
        }
        return;
    }


    // For each S1, S2 pair in S sets
    for(i = 0; i < Ss.size()-1; i++){
        for(j = i+1; j < Ss.size(); j++){
            bool sunk_S1 = false;
            bool sunk_S2 = false;

            // If there is substantial security benefit to
            // mapping S1 only when needed, sink its instrumentation
            set<Function *> set_diff_tmp;
            set<Function *> set_diff_fin;
            set_difference(Ss[i].begin(),
                           Ss[i].end(),
                           Ss[j].begin(),
                           Ss[j].end(),
                           inserter(set_diff_tmp, set_diff_tmp.end()));
            set_difference(set_diff_tmp.begin(),
                           set_diff_tmp.end(),
                           loop_static_reachability[loop_id].begin(),
                           loop_static_reachability[loop_id].end(),
                           inserter(set_diff_fin, set_diff_fin.end()));
            // FIXME: write a function like get_set_diff_size()
            // FIXME: don't just use the size of set_diff_fin. that's wrong
            // FIXME: And fix THRESH. not some dumb integer
            #define THRESH 10 // FIXME
            if(set_diff_fin.size() > THRESH){
              // TODO sink instrumentation of S1 to TRICKY TODO NOT NECESSARILY IMM DOM OF F1
              sunk_S1 = true;
            }

            // ... similarly for S2
            set_diff_tmp.clear();
            set_diff_fin.clear();
            set_difference(Ss[j].begin(),
                           Ss[j].end(),
                           Ss[i].begin(),
                           Ss[i].end(),
                           inserter(set_diff_tmp, set_diff_tmp.end()));
            set_difference(set_diff_tmp.begin(),
                           set_diff_tmp.end(),
                           loop_static_reachability[loop_id].begin(),
                           loop_static_reachability[loop_id].end(),
                           inserter(set_diff_fin, set_diff_fin.end()));
            // FIXME
            // FIXME see above
            // FIXME
            if(set_diff_fin.size() > THRESH){
              // TODO sink instrumentation of S2 to TRICKY TODO NOT NECESSARILY IMM DOM OF F2
              sunk_S2 = true;
            }

            // If the intersection is large, then we may find control
            // divergence deeper in the call chain where the security
            // benefit warrants sinking the instrumentation. We do this
            // for either set, as long as we haven't sunk the instrumentation
            // for it yet.

            set<Function *> set_intersect_fin;
            set_diff_fin.clear();
            set_intersection(Ss[i].begin(),
                             Ss[i].end(),
                             Ss[j].begin(),
                             Ss[j].end(),
                             inserter(set_intersect_fin, set_intersect_fin.end()));
            set_difference(set_intersect_fin.begin(),
                           set_intersect_fin.end(),
                           loop_static_reachability[loop_id].begin(),
                           loop_static_reachability[loop_id].end(),
                           inserter(set_diff_fin, set_diff_fin.end()));
            // FIXME FIXME FIXME
            // FIXME FIXME FIXME see above about size and THRESH

            if(set_diff_fin.size() > THRESH){
                set<Function *> tmp_F;
                if(!sunk_S1 && !sunk_S2){
                    // FIXME this doesn't work because Fs has basic blocks!!!!
                    //set_union(Fs[i].begin(),
                    //          Fs[i].end(),
                    //          Fs[j].begin(),
                    //          Fs[j].end(),
                    //          inserter(tmp_F, tmp_F.end()));
                }else if(!sunk_S1){
                    // FIXME: assignment fails
                    //tmp_F = Fs[i];
                }else if(!sunk_S2){
                    // FIXME: assignment fails
                    //tmp_F = Fs[j];
                }else{
                    assert(sunk_S1 && sunk_S2);
                }

                for(auto f : tmp_F){
                    // add f to the instrumentation of Li
                    loop_static_reachability[loop_id].insert(f);
                    // And then recurse on callees
                    // FIXME: adj_list comes into play here???
                    for(auto callee : adj_list[f]){
                      // RECURSE
                      // RECURSE
                      // RECURSE
                      //instrument_loop_sink(toplevel_func_id, toplevel_loop, callee->getBlocks());
                    }
                }

            }else{
                // Else, the intersection is small.
                // Thus, we tried already to sink S1 or S2 based on
                // set difference. And we tried already to recurse when
                // that didn't work but the intersection was still big.
                // Now "go back" and make sure that if we didn't sink S1 or
                // S2, that they are added to the loop preheader instrumentation
                if(!sunk_S1){
                    // add S1 to IS0
                    for(auto f : Ss[i]){
                        // FIXME meta:  uhhh. are these FIXMEs relevant here???
                        // FIXME: make sure to handle whatever the equivalent of this might
                        // be for this new algorithm.
                        //   "If there was at least one function call inside the loop, then we
                        //   will instrument it."
                        loop_static_reachability[loop_id].insert(f);
                        // FIXME cont. : And this probably includes a bump to loop_id_counter
                    }
                }
                if(!sunk_S2){
                    // add S2 to IS0
                    for(auto f : Ss[j]){
                        // FIXME meta:  uhhh. are these FIXMEs relevant here???
                        // FIXME: make sure to handle whatever the equivalent of this might
                        // be for this new algorithm.
                        //   "If there was at least one function call inside the loop, then we
                        //   will instrument it."
                        loop_static_reachability[loop_id].insert(f);
                        // FIXME cont. : And this probably includes a bump to loop_id_counter
                    }
                }
            }
        }
    }



    /*

    // If there was at least one function call inside the loop, then we
    // will instrument it.
    if(loop_static_reachability.find(loop_id) != loop_static_reachability.end()){

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

    */
}


void WholeProgramDebloat::instrument_loop(Loop *loop, int func_id)
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
                if(func_to_id.count(callee) > 0){
                    loop_static_reachability[loop_id].insert(callee);
                }
            }
        }
    }

    // If there was at least one function call inside the loop, then we
    // will instrument it.
    if(loop_static_reachability.find(loop_id) != loop_static_reachability.end()){

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
                            if(encompassed_funcs.find(f) == encompassed_funcs.end()){
                                // instrument before indirect func call
                                vector<Value *> ArgsV;
                                IRBuilder<> builder(CB);
                                ArgsV.push_back(builder.CreatePtrToInt(v, int64Ty));
                                builder.CreateCall(debrt_protect_indirect_func, ArgsV);
                                
                                // instrument after indirect func call
                                if(CI){
                                    IRBuilder<> builder_end(CI);
                                    builder_end.SetInsertPoint(CI->getNextNode());
                                    builder_end.CreateCall(debrt_protect_end_indirect_func, ArgsV);
                                }else if(II){
                                    errs() << "indirect func invoke case\n";
                                    instrument_after_invoke(II, ArgsV, debrt_protect_end_indirect_func);
                                }else{
                                    assert(0);
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
            if(false){
                vector<BasicBlock *> loop_BBs = (*loop)->getBlocks();
                instrument_loop_sink(func_to_id[f], *loop, loop_BBs);
            }else{
                instrument_loop(*loop, func_to_id[f]);
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

    // Give each application function an ID
    int count = 0;
    for(auto &F : M){
        if(F.hasName() && !F.isDeclaration()){
            func_name_to_id[F.getName().str()] = count;
            func_to_id[&F] = count;
            func_id_to_name[count] = F.getName().str();
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
    Type *ArgTypes64[] = { int64Ty };

    debrt_init_func = Function::Create(FunctionType::get(int32Ty, ArgTypes, false),
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
    debrt_protect_end_indirect_func = Function::Create(FunctionType::get(int32Ty, ArgTypes64, false),
            Function::ExternalLinkage,
            "debrt_protect_indirect_end",
            M);
}



bool WholeProgramDebloat::runOnModule_real(Module &M)
{
    // Initialization
    wpd_init(M);

    // Build all_funcs, adj_list, func_to_loop_info
    // Paritlally build encompassed_funcs
    build_basic_structs(M);

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
void checkPostDominance(BasicBlock *B1, BasicBlock *B2)
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
bool WholeProgramDebloat::is_reachable(BasicBlock *B1, BasicBlock *B2)
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
}

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
    FILE *fp_loop_reachability = fopen("wpd_loop_static_reachability.txt", "w");
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
bool WholeProgramDebloat::doFinalization(Module &M)
{
    dump_encompassed_funcs();
    dump_static_reachability();
    dump_loop_static_reachability();
    dump_func_name_to_id();
    dump_func_ptrs();
    dump_loop_id_to_func_id();
    dump_disjoint_sets();
    return false;
}
bool WholeProgramDebloat::doInitialization(Module &M)
{
    // XXX don't use this to initialize shit unless you want it to wig out
    return false;
}

char WholeProgramDebloat::ID = 0;
static RegisterPass<WholeProgramDebloat> Y("WholeProgramDebloat", "Whole program debloat pass");
