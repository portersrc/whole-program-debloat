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
        map<BasicBlock *, int> bb_map;
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
        map<int, int> loop_id_to_func_id; // for debugging
        set<string> func_has_addr_taken;
        int loop_id_counter;


        void getAnalysisUsage(AnalysisUsage &AU) const
        {
            AU.addRequired<LoopInfoWrapperPass>();
            AU.setPreservesAll();
        }

        bool runOnModule(Module &) override;
        bool doInitialization(Module &) override;
        bool doFinalization(Module &) override;

        void wpd_init(Module &M);
        void build_basic_structs(Module &M);
        void build_static_reachability(void);
        void extend_encompassed_funcs(void);
        void build_toplevel_funcs(void);

        bool instrument_main(Module &M);
        void instrument(void);
        void instrument_loop(Loop *loop, int func_id);
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
    };
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
                //errs() << "hit case where preheader gets assigned to pred\n";
                preheader = pred;
                break;
            }
        }
    }

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
                        if(v->getType()->isPointerTy()){
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
        // errs() << "Label Basicblocks\n";
        // Label each Basicblock within the funciton with a unique id
        int bb = 0;
        for(auto &b : *f){
            bb_map[&b] = bb;
            bb += 1;
        }
        errs() << "Instrumenting " << f->getName().str() << "\n";

        // Instrument outer loops
        LoopInfo *LI = &getAnalysis<LoopInfoWrapperPass>(*f).getLoopInfo();
        for(auto loop = LI->begin(), e = LI->end(); loop != e; ++loop){
            instrument_loop(*loop, func_to_id[f]);
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
                        if(encompassed_funcs.find(callee) != encompassed_funcs.end()){
                            // Case: callee is no-instrument

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
            count++;
            if(F.hasAddressTaken()){
                //errs() << "F.hasAddressTaken() is: " << F.getName() << "\n";
                func_has_addr_taken.insert(F.getName().str());
            }
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


bool WholeProgramDebloat::runOnModule(Module &M)
{
    // Initialization
    wpd_init(M);

    // Build all_funcs, adj_list, func_to_loop_info
    // Paritlally build encompassed_funcs
    build_basic_structs(M);

    // Build a map of func -> set of statically reachable funcs
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
    FILE *fp_funcptrs = fopen("wpd_func_ptrs.txt", "w");
    for(auto func_name : func_has_addr_taken){
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
    return false;
}
bool WholeProgramDebloat::doInitialization(Module &M)
{
    // XXX don't use this to initialize shit unless you want it to wig out
    return false;
}

char WholeProgramDebloat::ID = 0;
static RegisterPass<WholeProgramDebloat> Y("WholeProgramDebloat", "Whole program debloat pass");
