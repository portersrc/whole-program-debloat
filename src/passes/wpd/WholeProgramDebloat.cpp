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
#include <llvm/Demangle/Demangle.h>

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
        Function *debrt_protect_func;
        Function *debrt_protect_end_func;
        Function *debrt_protect_indirect_func;
        Function *debrt_protect_end_indirect_func;
        map<Function *, int> function_map;
        Type *int32Ty;
        Type *int64Ty;
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

        bool runOnModule(Module &) override;
        bool doInitialization(Module &) override;
        bool doFinalization(Module &) override;

        void wpd_init(Module &M);
        void mark_no_instrument_callees_in_loop(Module &M);
        void mark_no_instrument_reachable_funcs(void);
        void instrument(void);
        void instrument_loop(Loop *loop, Function *parent_func);
        void instrument_after_invoke(InvokeInst *II,
                                     vector<Value *> &ArgsV,
                                     Function *debrt_func);
        void instrument_indirect(void);
        bool instrument_main(Module &M);
        string get_demangled_name(const Function &F);
        void dump_static_callsets(void);
    };
}


void WholeProgramDebloat::instrument_loop(Loop *loop, Function *parent_func)
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
            CallBase *CB = dyn_cast<CallInst>(&I);
            if(!CB){
                CB = dyn_cast<InvokeInst>(&I);
            }
            if(CB){
                Function *newF = CB->getCalledFunction();
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
                CallBase *CB = dyn_cast<CallInst>(&I);
                if(!CB){
                    CB = dyn_cast<InvokeInst>(&I);
                }
                if(CB){
                    Function *newF = CB->getCalledFunction();
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

    // If there was at least one function call inside the loop, then we
    // will instrument it.
    if(setFunctions.size() > 0){
        // Create arguments for the library function
        // errs() << "Make arguments\n";
        vector<Value *> ArgsV;
        ArgsV.push_back(ConstantInt::get(int32Ty, 1+setFunctions.size(), false));
        ArgsV.push_back(ConstantInt::get(int32Ty, function_map[parent_func], false));
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

        // dont assert. can refer to https://llvm.org/docs/LoopTerminology.html
        // statically infinite loop is possible. we just won't instrument exits in
        // that case
        //assert(exit_blocks.size() > 0);

        for(auto exit_block : exit_blocks){
            Instruction *ebt = exit_block->getTerminator();
            assert(ebt);
            IRBuilder<> builder_exit(ebt);
            builder_exit.CreateCall(debrt_protect_end_func, ArgsV);
        }
    }

}


void WholeProgramDebloat::mark_no_instrument_callees_in_loop(Module &M)
{
    LoopInfo *li;
    CallBase *cb;
    for(auto &F : M){
        if(F.hasName() && !F.isDeclaration()){
            all_funcs.insert(&F);
            li = &getAnalysis<LoopInfoWrapperPass>(F).getLoopInfo();
            for(auto &B : F){
                for(auto &I : B){
                    cb = dyn_cast<CallInst>(&I);
                    if(!cb){
                        cb = dyn_cast<InvokeInst>(&I);
                    }
                    if(cb){
                        Function *callee = cb->getCalledFunction();
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
                        if(v->getType()->isPointerTy()){
                            // instrument before indirect func call
                            vector<Value *> ArgsV;
                            IRBuilder<> builder(CB);
                            ArgsV.push_back(builder.CreatePtrToInt(v, int64Ty));
                            builder.CreateCall(debrt_protect_indirect_func, ArgsV);

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
            instrument_loop(*loop, f);
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
                    if(function_map.count(callee) > 0){
                        if(no_instrument_funcs.find(callee) != no_instrument_funcs.end()){
                            // Case: callee is no-instrument

                            // find statically reachable funcs of the callee
                            queue<Function *> q;
                            set<Function *> reachable_funcs;
                            q.push(callee);
                            while(!q.empty()){
                                Function *qf = q.front();
                                q.pop();
                                reachable_funcs.insert(qf);
                                for(auto qcallee : adj_list[qf]){
                                    if(reachable_funcs.find(qcallee) == reachable_funcs.end()){
                                        q.push(qcallee);
                                    }
                                }
                            }

                            // instrument before callee
                            vector<Value *> ArgsV;
                            ArgsV.push_back(ConstantInt::get(int32Ty, 1+reachable_funcs.size(), false));
                            ArgsV.push_back(ConstantInt::get(int32Ty, function_map[f], false));
                            for(auto rf : reachable_funcs){
                                ArgsV.push_back(ConstantInt::get(int32Ty, function_map[rf], false));
                            }
                            IRBuilder<> builder(CB);
                            builder.CreateCall(debrt_protect_func, ArgsV);

                            // instrument after callee
                            if(CI){
                                IRBuilder<> builder_end(CI);
                                builder_end.SetInsertPoint(CI->getNextNode());
                                builder_end.CreateCall(debrt_protect_end_func, ArgsV);
                            }else if(II){
                                errs() << "no-instrument invoke case\n";
                                instrument_after_invoke(II, ArgsV, debrt_protect_end_func);
                            }else{
                                assert(0);
                            }

                        }else{
                            // Case: callee can be instrumented.

                            // instrument before callee
                            vector<Value *> ArgsV;
                            ArgsV.push_back(ConstantInt::get(int32Ty, 2, false));
                            ArgsV.push_back(ConstantInt::get(int32Ty, function_map[f], false));
                            ArgsV.push_back(ConstantInt::get(int32Ty, function_map[callee], false));
                            IRBuilder<> builder(CB);
                            builder.CreateCall(debrt_protect_func, ArgsV);


                            // instrument after callee
                            if(CI){
                                IRBuilder<> builder_end(CI);
                                builder_end.SetInsertPoint(CI->getNextNode());
                                builder_end.CreateCall(debrt_protect_end_func, ArgsV);
                            }else if(II){
                                errs() << "yes-instrument invoke case\n";
                                instrument_after_invoke(II, ArgsV, debrt_protect_end_func);
                            }else{
                                assert(0);
                            }
                        }
                    }
                }
            }
        }
    }

    // instrument indirect function calls
    instrument_indirect();

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
            ArgsV.push_back(ConstantInt::get(int32Ty, function_map[&F], false));
            builder.CreateCall(debrt_init_func, ArgsV);
            found_main = 1;
            break;
        }
    }
    assert(found_main == 1);
}


bool WholeProgramDebloat::runOnModule(Module &M)
{
    wpd_init(M);

    instrument_main(M);

    // mark as no-instrument any functions that are called inside a loop
    mark_no_instrument_callees_in_loop(M);

    // mark as no-instrument any functions that are reachable from a function
    // that is no-instrument
    mark_no_instrument_reachable_funcs();

    instrument();
}


void WholeProgramDebloat::wpd_init(Module &M)
{
    // errs() << "Write Function to IDs map to a file\n";
    // Give each application function an ID and write it to a file
    FILE *fp = fopen("wpd_func_name_to_id.txt", "w");
    FILE *fp_funcptrs = fopen("wpd_func_ptrs.txt", "w");
    int count = 0 ;
    for(auto &F : M){
        if(F.hasName() && !F.isDeclaration()){
            fprintf(fp, "%s %u\n", F.getName().str().c_str(), count);
            function_map[&F] = count;
            count += 1;
            if(F.hasAddressTaken()){
                //errs() << "F.hasAddressTaken() is: " << F.getName() << "\n";
                fprintf(fp_funcptrs, "%s\n", F.getName().str().c_str());
            }
        }
    }
    fclose(fp);
    fclose(fp_funcptrs);

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
    debrt_protect_func = Function::Create(FunctionType::get(int32Ty, ArgTypes, true),
            Function::ExternalLinkage,
            "debrt_protect",
            M);
    debrt_protect_end_func = Function::Create(FunctionType::get(int32Ty, ArgTypes, true),
            Function::ExternalLinkage,
            "debrt_protect_end",
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

bool WholeProgramDebloat::doInitialization(Module &M)
{
    // XXX don't use this to initialize shit unless you want it to wig out
    return false;
}

void WholeProgramDebloat::dump_static_callsets(void)
{
    FILE *fp_callset = fopen("wpd_func_id_to_callset.txt", "w");
    //errs() << "Dumping static callsets\n";
    for(auto p : adj_list){
        Function *f = p.first;
        set<Function *> &callees = p.second;
        //errs() << f->getName() << ": ";
        //fprintf(fp_callset, "%s ", f->getName().str().c_str());
        fprintf(fp_callset, "%d ", function_map[f]);
        for(auto callee : callees){
            //errs() << callee->getName() << " ";
            //fprintf(fp_callset, "%s,", callee->getName().str().c_str());
            fprintf(fp_callset, "%d,", function_map[callee]);
        }
        //errs() << "\n";
        fprintf(fp_callset, "\n");
    }
    fclose(fp_callset);
}
bool WholeProgramDebloat::doFinalization(Module &M)
{
    dump_static_callsets();
    return false;
}

char WholeProgramDebloat::ID = 0;
static RegisterPass<WholeProgramDebloat> Y("WholeProgramDebloat", "Whole program debloat pass");
