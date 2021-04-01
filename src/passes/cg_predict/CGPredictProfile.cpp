
#include "CGPredict.hpp"
#include "../common/backslice.hpp"
#include "../common/util.hpp"


//struct CGPredict;


namespace {

    struct CGPredictProfile : public CGPredict, public FunctionPass {

      public:
        static char ID;
        LoopInfo *LI;

        CGPredictProfile() : FunctionPass(ID) {}

        bool doInitialization(Module &) override;
        bool runOnFunction(Function &) override;
        bool doFinalization(Module &) override;

        void getAnalysisUsage(AnalysisUsage &au) const override
        {
            au.addRequired<PostDominatorTreeWrapperPass>();
            au.addRequired<LoopInfoWrapperPass>();
            au.setPreservesCFG();
            au.addPreserved<GlobalsAAWrapperPass>();
        }

    };
}


bool CGPredictProfile::doInitialization(Module &M)
{
    call_inst_count = 0;

    // Start at 1. func_count == 0 could be called the "the null function",
    // i.e. when we want to predict that no function call will happen.
    func_count = 1;

    int32Ty = IntegerType::getInt32Ty(M.getContext());

    for(auto &f : M){
        LLVM_DEBUG(dbgs() << "seeing: " << getDemangledName(f) << "\n");
        if(f.hasName() && !f.isDeclaration()){
            LLVM_DEBUG(dbgs() << "  inserting: " << getDemangledName(f) << "\n");
            app_funcs.insert(&f);
        }else{
            if(!f.hasName()){
                LLVM_DEBUG(dbgs() << "  no name\n");
            }else if(f.isDeclaration()){
                LLVM_DEBUG(dbgs() << "  is declaration\n");
            }else{
                assert(0 && "unexpected: has name, isn't declaration, bug fell through\n");
            }
        }
    }

    init_debprof_print_func(M);
    return false;
}

bool CGPredictProfile::doFinalization(Module &M)
{
    dump_stats();
    dump_func_name_to_id();
    return false;
}


bool CGPredictProfile::runOnFunction(Function &F)
{

    LI = &getAnalysis<LoopInfoWrapperPass>().getLoopInfo();

    //BasicBlock &entry_block = F.getEntryBlock();

    string called_func_name = F.getName().str();
    if(func_name_to_id.find(called_func_name) == func_name_to_id.end()){
        func_name_to_id[called_func_name] = func_count++;
    }

    instrument_func_start(F.getEntryBlock().getFirstNonPHI(), func_name_to_id[called_func_name]);

    for(Function::iterator it_bb = F.begin();
        it_bb != F.end();
        ++it_bb){

        BasicBlock *bb = &*it_bb;
        for(BasicBlock::iterator it_inst = bb->begin();
            it_inst != bb->end();
            ++it_inst){

            if(ReturnInst *RI = dyn_cast<ReturnInst>(&*it_inst)){
                instrument_func_end(RI, func_name_to_id[called_func_name]);
            }

        }
    }
}


char CGPredictProfile::ID = 0;
static RegisterPass<CGPredictProfile>
Y("CGPredictProfile", "Add profiling support for callgraph prediction");
