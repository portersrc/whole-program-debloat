
#include "CGPredict.hpp"
#include "../common/backslice.hpp"
#include "../common/util.hpp"




namespace {

    struct CGPredictInstrument : public CGPredict, public FunctionPass {

      public:
        static char ID;
        LoopInfo *LI;

        CGPredictInstrument() : FunctionPass(ID) {}

        bool doInitialization(Module &) override;
        bool runOnFunction(Function &) override;
        bool doFinalization(Module &) override;

        void instrument_func_start(Instruction *inst_before,
                                   unsigned int func_id);

        void getAnalysisUsage(AnalysisUsage &au) const override
        {
            au.addRequired<PostDominatorTreeWrapperPass>();
            au.addRequired<LoopInfoWrapperPass>();
            au.setPreservesCFG();
            au.addPreserved<GlobalsAAWrapperPass>();
        }

    };
}


bool CGPredictInstrument::doInitialization(Module &M)
{
    call_inst_count = 0;

    int32Ty = IntegerType::getInt32Ty(M.getContext());

    init_debrt_funcs(M);

    read_func_name_to_id();
    return false;
}

bool CGPredictInstrument::doFinalization(Module &M)
{
    dump_stats();
    dump_func_name_to_id();
    return false;
}


bool CGPredictInstrument::runOnFunction(Function &F)
{

    LI = &getAnalysis<LoopInfoWrapperPass>().getLoopInfo();

    string called_func_name = F.getName().str();

    instrument_func_start(F.getEntryBlock().getFirstNonPHI(),
                          func_name_to_id[called_func_name]);

}


void CGPredictInstrument::instrument_func_start(Instruction *inst_before,
                                                unsigned int func_id)
{
    CGPredict::instrument_func_start(debrt_cgmonitor_func,
                                     inst_before,
                                     func_id);
}


char CGPredictInstrument::ID = 0;
static RegisterPass<CGPredictInstrument>
Y("CGPredictInstrument", "Add profiling support for callgraph prediction");
