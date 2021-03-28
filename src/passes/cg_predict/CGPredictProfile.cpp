
#include "CGPredictProfile.hpp"
#include "../common/backslice.hpp"
#include "../common/util.hpp"





namespace {

    struct CGPredictProfile : public FunctionPass {

      public:
        static char ID;
        LoopInfo *LI;

        CGPredictProfile() : FunctionPass(ID) {}

        bool doInitialization(Module &) override;
        bool runOnFunction(Function &) override;
        bool doFinalization(Module &) override;
        void instrument_func_start(Instruction *inst_before,
                                   unsigned int func_id);
        void instrument_func_end(Instruction *inst_before,
                                 unsigned int func_id);

        void getAnalysisUsage(AnalysisUsage &au) const override
        {
            au.addRequired<PostDominatorTreeWrapperPass>();
            au.addRequired<LoopInfoWrapperPass>();
            au.setPreservesCFG();
            au.addPreserved<GlobalsAAWrapperPass>();
        }

      private:
        Function *debprof_print_args_func;
        Function *debprof_print_func_end;
        unordered_set<Function *> app_funcs;
        map<CallInst *, unsigned int> call_inst_to_id;
        map<string, unsigned int> func_name_to_id;
        unsigned int call_inst_count;
        unsigned int func_count;
        set<Instruction *> jump_phi_nodes;
        Type *int32Ty;

        void init_debprof_print_func(Module &);
        void dump_func_name_to_id(void);
        void dump_stats(void);

    };
}


bool CGPredictProfile::doInitialization(Module &M)
{
    call_inst_count = 0;
    func_count = 0;

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


void CGPredictProfile::dump_stats(void)
{
    FILE *fp = fopen("cgpprof_pass_stats.txt", "w");
    fclose(fp);
}


void CGPredictProfile::dump_func_name_to_id(void)
{
    FILE *fp = fopen("cgpprof_func_name_to_id.txt", "w");
    for(auto it = func_name_to_id.begin(); it != func_name_to_id.end(); it++){
        fprintf(fp, "%s %u\n", it->first.c_str(), it->second);
    }
    fclose(fp);
}


bool CGPredictProfile::runOnFunction(Function &F)
{

    LI = &getAnalysis<LoopInfoWrapperPass>().getLoopInfo();

    //BasicBlock &entry_block = F.getEntryBlock();

    string called_func_name = F.getName().str();
    if(func_name_to_id.find(called_func_name) == func_name_to_id.end()){
        func_name_to_id[called_func_name] = func_count++;
    }

    instrument_func_start(F.getEntryBlock().getFirstNonPHI(),
                          func_name_to_id[called_func_name]);

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


void CGPredictProfile::init_debprof_print_func(Module &M)
{
    Type *ArgTypes[] = { int32Ty  };
    string custom_instr_func_name("debprof_print_args");

    debprof_print_args_func =
      Function::Create(FunctionType::get(int32Ty, ArgTypes, false),
                       Function::ExternalLinkage,
                       "debprof_print_args",
                       M);

    debprof_print_func_end =
      Function::Create(FunctionType::get(int32Ty, ArgTypes, false),
                       Function::ExternalLinkage,
                       "debprof_print_func_end",
                       M);

}

void CGPredictProfile::instrument_func_start(Instruction *inst_before,
                                             unsigned int func_id)
{
    IRBuilder<> builder(inst_before);
    vector<Value *> ArgsV;
    ArgsV.push_back(llvm::ConstantInt::get(int32Ty, func_id, false));
    LLVM_DEBUG(dbgs() << "Instrumenting ret-inst::" << inst_before << "\n");
    CallInst *debprof_call = builder.CreateCall(debprof_print_args_func, ArgsV);
}
void CGPredictProfile::instrument_func_end(Instruction *inst_before,
                                           unsigned int func_id)
{
    IRBuilder<> builder(inst_before);
    vector<Value *> ArgsV;
    ArgsV.push_back(llvm::ConstantInt::get(int32Ty, func_id, false));
    LLVM_DEBUG(dbgs() << "Instrumenting ret-inst::" << inst_before << "\n");
    CallInst *debprof_call = builder.CreateCall(debprof_print_func_end, ArgsV);
}



char CGPredictProfile::ID = 0;
static RegisterPass<CGPredictProfile>
Y("CGPredictProfile", "Add profiling support for callgraph prediction");
