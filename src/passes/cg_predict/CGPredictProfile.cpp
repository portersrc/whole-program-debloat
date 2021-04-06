
#include "CGPredict.hpp"
#include "../common/backslice.hpp"
#include "../common/util.hpp"




namespace {

    struct CGPredictProfile : public CGPredict, public FunctionPass {

      public:
        static char ID;
        LoopInfo *LI;

        CGPredictProfile() : FunctionPass(ID) {}

        bool doInitialization(Module &) override;
        bool runOnFunction(Function &) override;
        bool doFinalization(Module &) override;

        void init_debprof_print_funcs(Module &M);

        void instrument_func_start(Instruction *inst_before,
                                   unsigned int func_id);
        void instrument_func_end(ReturnInst *return_inst,
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


bool CGPredictProfile::doInitialization(Module &M)
{
    init_aux(M);

    // Start at 1. func_count == 0 could be called the "the null function",
    // i.e. when we want to predict that no function call will happen.
    func_count = 1;

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

    init_debprof_print_funcs(M);
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

void CGPredictProfile::instrument_func_end(ReturnInst *return_inst,
                                           unsigned int func_id)
{
    IRBuilder<> builder(return_inst);
    vector<Value *> ArgsV;
    ArgsV.push_back(llvm::ConstantInt::get(int32Ty, func_id, false));
    CallInst *debprof_call = builder.CreateCall(debprof_print_func_end, ArgsV);
}


void CGPredictProfile::instrument_func_start(Instruction *inst_before,
                                             unsigned int func_id)
{
    CGPredict::instrument_func_start(debprof_print_args_func, inst_before, func_id);
}


void CGPredictProfile::init_debprof_print_funcs(Module &M)
{
    Type *ArgTypes[] = { int32Ty  };

    debprof_print_args_func =
      Function::Create(FunctionType::get(int32Ty, ArgTypes, true),
                       Function::ExternalLinkage,
                       "debprof_print_args",
                       M);

    debprof_print_func_end =
      Function::Create(FunctionType::get(int32Ty, ArgTypes, false),
                       Function::ExternalLinkage,
                       "debprof_print_func_end",
                       M);

}

char CGPredictProfile::ID = 0;
static RegisterPass<CGPredictProfile>
Y("CGPredictProfile", "Add profiling support for callgraph prediction");
