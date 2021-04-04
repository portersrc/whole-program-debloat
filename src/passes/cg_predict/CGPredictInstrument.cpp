
#include "CGPredict.hpp"
#include "../common/backslice.hpp"
#include "../common/util.hpp"


// FIXME relocate these functions
template<typename Out>
void split(const string &s, char delim, Out result)
{
    stringstream ss(s);
    string item;
    while(getline(ss, item, delim)){
        *(result++) = item;
    }
}
vector<string> split(const string &s, char delim)
{
    vector<string> elems;
    split(s, delim, back_inserter(elems));
    return elems;
}






namespace {

    struct CGPredictInstrument : public CGPredict, public FunctionPass {

      public:
        static char ID;
        LoopInfo *LI;
        Function *debrt_cgreturn_func;
        Function *debrt_cgreturn_func_intrinsic;

        CGPredictInstrument() : FunctionPass(ID) {}

        bool doInitialization(Module &) override;
        bool runOnFunction(Function &) override;
        bool doFinalization(Module &) override;

        void read_func_name_to_id(void);
        void init_debrt_funcs(Module &M);

        void instrument_func_start(Instruction *inst_before,
                                   unsigned int func_id);
        void instrument_func_end(Instruction *inst_before,
                                 unsigned int func_id,
                                 Function *debrt_return_func,
                                 Function *debrt_return_func_intrinsic);

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
    init_aux(M);

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


void CGPredictInstrument::instrument_func_end(Instruction *inst_before,
                                              unsigned int func_id,
                                              Function *debrt_return_func,
                                              Function *debrt_return_func_intrinsic)
{
    Value *retinstrIntrinsic;
    vector<Value *> ArgsVIntrinsic;

    IRBuilder<> builderIntrinsic(inst_before);
    ArgsVIntrinsic.push_back(llvm::ConstantInt::get(int32Ty, 0, false));
    LLVM_DEBUG(dbgs() << "Instrumenting ret-inst::" << inst_before << "\n");
    retinstrIntrinsic =
      builderIntrinsic.CreateCall(debrt_return_func_intrinsic, ArgsVIntrinsic);
      //builderIntrinsic.CreateCall(debrt_return_func_intrinsic);
    LLVM_DEBUG(dbgs() << "retinstrIntrinsic::" << *retinstrIntrinsic << "\n");


    IRBuilder<> builder(inst_before);
    vector<Value *> ArgsV;
    LLVM_DEBUG(dbgs() << "retinstrIntrinsic type: " << *(retinstrIntrinsic->getType()) << "\n");
    if(retinstrIntrinsic->getType()->isPointerTy()){
        LLVM_DEBUG(dbgs() << " that type is a pointer\n");
    }
    Value *castedArg = nullptr;
    castedArg = builder.CreatePtrToInt(retinstrIntrinsic, int64Ty);
    ArgsV.push_back(castedArg);
    LLVM_DEBUG(dbgs() << "Instrumenting ret-inst::" << inst_before << "\n");
    CallInst *retinstr = builder.CreateCall(debrt_return_func, ArgsV);
    LLVM_DEBUG(dbgs() << "retinstr::" << *retinstr << "\n");
}


void CGPredictInstrument::read_func_name_to_id(void)
{
    string line;
    ifstream ifs;
    vector<string> elems;

    ifs.open("cgpprof_func_name_to_id.txt");
    if(!ifs.is_open()) {
        perror("Error opening func name to id file");
        exit(EXIT_FAILURE);
    }

    while(getline(ifs, line)){
        elems = split(line, ' ');
        func_name_to_id[elems[0]] = atoi(elems[1].c_str());
    }
}


void CGPredictInstrument::init_debrt_funcs(Module &M)
{
    Type *ArgTypes[] = { int32Ty  };

    debrt_cgmonitor_func =
      Function::Create(FunctionType::get(int32Ty, ArgTypes, true),
                       Function::ExternalLinkage,
                       "debrt_cgmonitor",
                       M);

}





char CGPredictInstrument::ID = 0;
static RegisterPass<CGPredictInstrument>
Y("CGPredictInstrument", "Add profiling support for callgraph prediction");
