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

using namespace llvm;
using namespace std;

// FIXME: When debrt_protect_func is a member of WholeProgramDebloat and I
// try to use IRBuilder's CreateCall(), I get some isa<X>(Val) type error.
// No clue. 8-hr bug. Leaving in global as a workaround for now.
Function *debrt_protect_func = NULL;

namespace {
    struct WholeProgramDebloat : public ModulePass {
        static char ID;

        WholeProgramDebloat() : ModulePass(ID) {}

        map<Function *, int> function_map;
        queue<Function *> funcs_outside_loops;
        Type *int32Ty;
        Type *int64Ty;
        LoopInfo *LI;

        map<BasicBlock *, int> bb_map;

        void getAnalysisUsage(AnalysisUsage &AU) const
        {
            AU.addRequired<LoopInfoWrapperPass>();
            //AU.addRequired<ScalarEvolutionWrapperPass>();
            AU.setPreservesAll();
        }

        bool doInitialization(Module &) override;
        bool runOnModule(Module &) override;
        bool doFinalization(Module &) override;


        void find_other_nonloop_funcs(Function *F);
        void instrument_loop(Loop *loop, Module &M);
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

void WholeProgramDebloat::instrument_loop(Loop *loop, Module &M)
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
                errs() << "hit case where preader gets assigned to pred\n";
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

    // errs() << "Create library function\n";
    // Create library function
    int32Ty = IntegerType::getInt32Ty(M.getContext());
    Type *ArgTypes[]    = { int32Ty };

    int64Ty = IntegerType::getInt64Ty(M.getContext());
    Type *ArgTypes64[]    = { int64Ty };

    // Create arguments for the library function
    // errs() << "Make arguments\n";
    vector<Value *> ArgsV;
    ArgsV.push_back(ConstantInt::get(int32Ty, setFunctions.size(), false));
    for(auto F : setFunctions){
        ArgsV.push_back(ConstantInt::get(int32Ty, function_map[F], false));
    }


    if(debrt_protect_func == NULL){
        debrt_protect_func = Function::Create(FunctionType::get(int32Ty, ArgTypes, true),
                Function::ExternalLinkage,
                "debrt_protect",
                M);
    }


    Instruction *TI = preheader->getTerminator();
    assert(TI);
    assert(debrt_protect_func);
    IRBuilder<> builder(TI);
    builder.CreateCall(debrt_protect_func, ArgsV);
    // errs() << "Inserted library function within preheader(" << preheader->getName().str() << "\n";

}

bool WholeProgramDebloat::runOnModule(Module &M)
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
            instrument_loop(*loop, M);
        }

        // errs() << "Find Other Functions not within loop nests" << "\n";
        // Otherwise, go to the loops not within loop nests and check if they have loops with function calls
        find_other_nonloop_funcs(curr);
    }

    bb_map.clear();
    function_map.clear();
    return true;
}

bool WholeProgramDebloat::doInitialization(Module &M)
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

    //// errs() << "Create library function\n";
    //// Create library function
    //int32Ty = IntegerType::getInt32Ty(M.getContext());
    //Type *ArgTypes[]    = { int32Ty };

    //int64Ty = IntegerType::getInt64Ty(M.getContext());
    //Type *ArgTypes64[]    = { int64Ty };

    //debrt_protect_func = Function::Create(FunctionType::get(int32Ty, ArgTypes, true),
    //        Function::ExternalLinkage,
    //        "debrt_protect",
    //        M);
    return false;
}

bool WholeProgramDebloat::doFinalization(Module &M)
{
    return false;
}

char WholeProgramDebloat::ID = 0;
static RegisterPass<WholeProgramDebloat> Y("WholeProgramDebloat", "Whole program debloat pass");
