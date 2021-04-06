
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

        void instrument_func_end(Function &F);
        void instrument_func_end_aux(Instruction *inst_before);

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
    init_types(M);

    init_debrt_funcs(M);

    read_func_name_to_id();
    return false;
}


bool CGPredictInstrument::doFinalization(Module &M)
{
    return false;
}


bool CGPredictInstrument::runOnFunction(Function &F)
{

    LI = &getAnalysis<LoopInfoWrapperPass>().getLoopInfo();

    string called_func_name = F.getName().str();

    instrument_func_start(debrt_cgmonitor_func,
                          F.getEntryBlock().getFirstNonPHI(),
                          func_name_to_id[called_func_name]);
    instrument_func_end(F);
}


void CGPredictInstrument::instrument_func_end(Function &F)
{
    for(Function::iterator it_bb = F.begin();
        it_bb != F.end();
        ++it_bb){

        BasicBlock *bb = &*it_bb;
        for(BasicBlock::iterator it_inst = bb->begin();
            it_inst != bb->end();
            ++it_inst){

            if(ReturnInst *RI = dyn_cast<ReturnInst>(&*it_inst)){
                instrument_func_end_aux(RI);
            }

        }
    }
}


void CGPredictInstrument::instrument_func_end_aux(Instruction *inst_before)
{
    Value *retinstrIntrinsic;
    vector<Value *> ArgsVIntrinsic;

    IRBuilder<> builderIntrinsic(inst_before);
    ArgsVIntrinsic.push_back(llvm::ConstantInt::get(int32Ty, 0, false));
    LLVM_DEBUG(dbgs() << "Instrumenting ret-inst::" << inst_before << "\n");
    retinstrIntrinsic =
      builderIntrinsic.CreateCall(debrt_cgreturn_func_intrinsic, ArgsVIntrinsic);
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
    CallInst *retinstr = builder.CreateCall(debrt_cgreturn_func, ArgsV);
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
    Type *ArgTypes[]    = { int32Ty };
    Type *ArgTypes64[]  = { int64Ty };
    Type *ArgTypesPtr[] = { ptr_i8 };

    debrt_cgmonitor_func =
      Function::Create(FunctionType::get(int32Ty, ArgTypes, true),
                       Function::ExternalLinkage,
                       "debrt_cgmonitor",
                       M);

    // FIXME ? Why ArgTypes64
    debrt_cgreturn_func =
      Function::Create(FunctionType::get(int32Ty, ArgTypes64, false),
                       Function::ExternalLinkage,
                       "debrt_cgreturn",
                       M);

    debrt_cgreturn_func_intrinsic =
      Function::Create(FunctionType::get(ptr_i8, ArgTypes, false),
                       Function::ExternalLinkage,
                       "llvm.returnaddress",
                       &M);
}





char CGPredictInstrument::ID = 0;
static RegisterPass<CGPredictInstrument>
Y("CGPredictInstrument", "Instrumentation pass for callgraph prediction");
