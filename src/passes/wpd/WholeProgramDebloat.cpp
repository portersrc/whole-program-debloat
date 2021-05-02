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

        Function *debrt_protect_func;
        Function *debrt_protect_end_func;
        map<Function *, int> function_map;
        queue<Function *> funcs_outside_loops;
        Type *int32Ty;
        LoopInfo *LI;
        map<BasicBlock *, int> bb_map;
        map<Function *, set<Function *> > adj_list;
        set<Function *> all_funcs;
        // "no instrument funcs" is a set of functions that we aren't
        // allowed to instrument _inside of_, because they are either
        // called inside of a loop, or they are called by a function
        // that's called inside of a loop.
        set<Function *> no_instrument_funcs;


        void getAnalysisUsage(AnalysisUsage &AU) const
        {
            AU.addRequired<LoopInfoWrapperPass>();
            AU.setPreservesAll();
        }

        void wpd_init(Module &M);
        void mark_no_instrument_callees_in_loop(Module &M);
        void mark_no_instrument_reachable_funcs(void);
        void instrument(void);

        bool doInitialization(Module &) override;
        bool runOnModule(Module &) override;
        bool runOnModuleOld(Module &M);
        bool doFinalization(Module &) override;


        void find_other_nonloop_funcs(Function *F);
        void instrument_loop(Loop *loop);
    };
}

void WholeProgramDebloat::find_other_nonloop_funcs(Function *F)
{
    // Go through each instruction not within a loop and check if there is a function call so we can go through its loops
    for(auto &B : *F){
        if(LI && !LI->getLoopFor(&B)){
            for(auto &I : B){
                CallInst *CI = dyn_cast<CallInst>(&I);
                if(CI){
                    Function *newF = CI->getCalledFunction();
                    if(function_map.count(newF) > 0){
                        //errs() << "Function(" << newF->getName().str() << ") also is not within a loop nest so check loop nest functions within it\n";
                        funcs_outside_loops.push(newF);
                    }
                }
            }
        }
    }
}

void WholeProgramDebloat::instrument_loop(Loop *loop)
{
    // Find preheader
    // FIXME This looks sus.
    // Consider checking LLVM doxygen on getLoopPreheader. The fix could be to
    // walk incoming edges to the first BB of the loop. Another option
    // if needed is to run loop-simplify beforehand.
    // see also https://llvm.org/docs/LoopTerminology.html
    BasicBlock *preheader = loop->getLoopPreheader();
    BasicBlock *header = *(loop->block_begin());
    if(!preheader){
        for(BasicBlock *pred : predecessors(header)){
            int idH = bb_map[header];
            int idP = bb_map[pred];
            if(idP < idH){
                //errs() << "hit case where preader gets assigned to pred\n";
                preheader = pred;
                break;
            }
        }
    }
    // errs() << "Get Preheader\n";

    // Find the functions within the loops
    queue<Function *> queueFunctions;
    set<Function *> setFunctions;
    for(auto bb = loop->block_begin(); bb != loop->block_end(); ++bb){
        for(auto &I : *(*bb)){
            CallInst *CI = dyn_cast<CallInst>(&I);
            if(CI){
                Function *newF = CI->getCalledFunction();
                if(function_map.count(newF) > 0){
                    // errs() << "Function(" << newF->getName().str() << ") is within loop nest\n";
                    queueFunctions.push(newF);
                    setFunctions.insert(newF);
                }
            }
        }
    }

    // Find the children of the functions that we have already seen
    while(!queueFunctions.empty()){
        Function *curr = queueFunctions.front();
        queueFunctions.pop();

        for(auto &B : *curr){
            for(auto &I : B){
                CallInst *CI = dyn_cast<CallInst>(&I);
                if(CI){
                    Function *newF = CI->getCalledFunction();
                    if(function_map.count(newF) > 0){
                        if(setFunctions.find(newF) == setFunctions.end()){
                            // errs() << "Function(" << newF->getName().str() << ") is within loop nest\n";
                            queueFunctions.push(newF);
                            setFunctions.insert(newF);
                        }
                    }
                }
            }
        }
    }


    // Create arguments for the library function
    // errs() << "Make arguments\n";
    vector<Value *> ArgsV;
    ArgsV.push_back(ConstantInt::get(int32Ty, setFunctions.size(), false));
    for(auto F : setFunctions){
        ArgsV.push_back(ConstantInt::get(int32Ty, function_map[F], false));
    }

    // instrument the preheader of the loop
    Instruction *TI = preheader->getTerminator();
    assert(TI);
    assert(debrt_protect_func);
    IRBuilder<> builder(TI);
    builder.CreateCall(debrt_protect_func, ArgsV);
    // errs() << "Inserted library function within preheader(" << preheader->getName().str() << "\n";

    // instrument the exit(s) block(s) of the loop
    SmallVector<BasicBlock *, 8> exit_blocks;
    loop->getUniqueExitBlocks(exit_blocks);
    assert(exit_blocks.size() > 0);
    for(auto exit_block : exit_blocks){
        Instruction *ebt = exit_block->getTerminator();
        assert(ebt);
        IRBuilder<> builder_exit(ebt);
        builder_exit.CreateCall(debrt_protect_end_func, ArgsV);
    }

}


void WholeProgramDebloat::mark_no_instrument_callees_in_loop(Module &M)
{
    LoopInfo *li;
    CallInst *ci;
    for(auto &F : M){
        if(F.hasName() && !F.isDeclaration()){
            all_funcs.insert(&F);
            li = &getAnalysis<LoopInfoWrapperPass>(F).getLoopInfo();
            for(auto &B : F){
                for(auto &I : B){
                    ci = dyn_cast<CallInst>(&I);
                    if(ci){
                        Function *callee = ci->getCalledFunction();
                        if(function_map.count(callee) > 0){
                            adj_list[&F].insert(callee);
                            if(li && li->getLoopFor(&B)){
                                no_instrument_funcs.insert(callee);
                            }
                        }
                    }
                }
            }
        }
    }
}

void WholeProgramDebloat::mark_no_instrument_reachable_funcs(void)
{

    queue<Function *> q;
    set<Function *> visited;
    for(auto F : no_instrument_funcs){
        q.push(F);
    }

    while(!q.empty()){
        Function *f = q.front();
        q.pop();
        visited.insert(f);
        for(auto callee : adj_list[f]){
            if(visited.find(callee) == visited.end()){
                q.push(callee);
                no_instrument_funcs.insert(callee);
            }
        }
    }
}

void WholeProgramDebloat::instrument(void)
{
    set<Function *> instrument_funcs;
    set_difference(all_funcs.begin(),
                   all_funcs.end(),
                   no_instrument_funcs.begin(),
                   no_instrument_funcs.end(),
                   inserter(instrument_funcs, instrument_funcs.end()));
    for(auto f : instrument_funcs){
        // errs() << "Label Basicblocks\n";
        // Label each Basicblock within the funciton with a unique id
        int bb = 0;
        for(auto &b : *f){
            bb_map[&b] = bb;
            bb += 1;
        }
        errs() << "Instrumenting " << f->getName().str() << "\n";

        // Instrument outer loops
        LI = &getAnalysis<LoopInfoWrapperPass>(*f).getLoopInfo();
        // errs() << "Go through all outer loops" << "\n";
        for(auto loop = LI->begin(), e = LI->end(); loop != e; ++loop ){
            instrument_loop(*loop);
        }

        // instrument call sites
        for(auto &b : *f){
            for(auto &I : b){
                CallInst *CI = dyn_cast<CallInst>(&I);
                if(CI){
                    Function *callee = CI->getCalledFunction();
                    if(function_map.count(callee) > 0){
                        if(no_instrument_funcs.find(callee) != no_instrument_funcs.end()){
                            // Case: callee is no-instrument

                            // TODO find static reachability, instrument that.

                        }else{
                            // Case: callee can be instrumented.

                            // instrument before callee
                            vector<Value *> ArgsV;
                            ArgsV.push_back(ConstantInt::get(int32Ty, 1, false));
                            ArgsV.push_back(ConstantInt::get(int32Ty, function_map[callee], false));
                            IRBuilder<> builder(CI);
                            builder.CreateCall(debrt_protect_func, ArgsV);


                            // instrument after callee
                            IRBuilder<> builder_end(CI);
                            builder_end.SetInsertPoint(CI->getNextNode());
                            builder_end.CreateCall(debrt_protect_end_func, ArgsV);
                        }
                    }
                }
            }
        }

    }
}

bool WholeProgramDebloat::runOnModule(Module &M)
{
    wpd_init(M);

    // mark as no-instrument any functions that are called inside a loop
    mark_no_instrument_callees_in_loop(M);

    // mark as no-instrument any functions that are reachable from a function
    // that is no-instrument
    mark_no_instrument_reachable_funcs();

    instrument();
}

bool WholeProgramDebloat::runOnModuleOld(Module &M)
{
    // errs() << "Find Main\n";
    // Start with the main funciton
    for(auto &F : M){
        if(F.getName() == "main"){
            funcs_outside_loops.push(&F);
            break;
        }
    }

    int bb = 0;
    while(!funcs_outside_loops.empty()){
        Function *curr = funcs_outside_loops.front();
        funcs_outside_loops.pop();
        // errs() << "Found Function(" << curr->getName().str() << ") that is not within loop nest" << "\n";


        // errs() << "Label Basicblocks\n";
        // Label each Basicblock within the funciton with a unique id
        for(auto &B : *curr){
            bb_map[&B] = bb;
            bb += 1;
        }

        // For each loop, check if the loop has funcitons calls within
        LI = &getAnalysis<LoopInfoWrapperPass>(*curr).getLoopInfo();
        // errs() << "Go through all outer loops" << "\n";
        for(auto loop = LI->begin(), e = LI->end(); loop != e; ++loop ){
            instrument_loop(*loop);
        }

        // errs() << "Find Other Functions not within loop nests" << "\n";
        // Otherwise, go to the loops not within loop nests and check if they have loops with function calls
        find_other_nonloop_funcs(curr);
    }

    bb_map.clear();
    function_map.clear();
    return true;
}

void WholeProgramDebloat::wpd_init(Module &M)
{
    // errs() << "Write Function to IDs map to a file\n";
    // Give each application function an ID and write it to a file
    FILE *fp = fopen("wpd_func_name_to_id.txt", "w");
    int count = 0 ;
    for(auto &F : M){
        if(F.hasName() && !F.isDeclaration()){
            fprintf(fp, "%s %u\n", F.getName().str().c_str(), count);
            function_map[&F] = count;
            count += 1;
        }
    }
    fclose(fp);

    // errs() << "Create library function\n";
    // Create library function
    int32Ty = IntegerType::getInt32Ty(M.getContext());
    Type *ArgTypes[] = { int32Ty };
    debrt_protect_func = Function::Create(FunctionType::get(int32Ty, ArgTypes, true),
            Function::ExternalLinkage,
            "debrt_protect",
            M);
    debrt_protect_end_func = Function::Create(FunctionType::get(int32Ty, ArgTypes, true),
            Function::ExternalLinkage,
            "debrt_protect_end",
            M);
}

bool WholeProgramDebloat::doInitialization(Module &M)
{
    // XXX don't use this to initialize shit unless you want it to wig out
    return false;
}

bool WholeProgramDebloat::doFinalization(Module &M)
{
    return false;
}

char WholeProgramDebloat::ID = 0;
static RegisterPass<WholeProgramDebloat> Y("WholeProgramDebloat", "Whole program debloat pass");
