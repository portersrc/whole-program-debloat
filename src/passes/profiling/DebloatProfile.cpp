
#include "DebloatProfile.hpp"
#include "../common/backslice.hpp"
#include "../common/util.hpp"





namespace {

    struct DebloatProfile : public FunctionPass {

      public:
        static char ID;
        LoopInfo *LI;

        DebloatProfile() : FunctionPass(ID) {}

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

      private:
        Function *debprof_print_args_func;
        unordered_set<Function *> app_funcs;
        map<CallInst *, unsigned int> call_inst_to_id;
        map<string, unsigned int> func_name_to_id;
        unsigned int call_inst_count;
        unsigned int func_count;
        deb_stats_t stats;
        set<Instruction *> jump_phi_nodes;
        Type *int32Ty;

        void init_debprof_print_func(Module &);
        void dump_stats(void);
        void dump_func_name_to_id(void);

    };
}


bool DebloatProfile::doInitialization(Module &M)
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
    stats.max_num_args = 0;
    stats.num_calls_not_in_loops = 0;
    stats.num_calls_in_loops = 0;
    stats.num_loops_no_preheader = 0;
    return false;
}

bool DebloatProfile::doFinalization(Module &M)
{
    dump_stats();
    dump_func_name_to_id();
    return false;
}


void DebloatProfile::dump_stats(void)
{
    FILE *fp = fopen("debprof_pass_stats.txt", "w");
    fprintf(fp, "max_num_args: %u\n", stats.max_num_args);
    fprintf(fp, "num_calls_in_loops: %u\n", stats.num_calls_in_loops);
    fprintf(fp, "num_calls_not_in_loops: %u\n", stats.num_calls_not_in_loops);
    fprintf(fp, "num_loops_no_preheader: %u\n", stats.num_loops_no_preheader);
    fclose(fp);
}


void DebloatProfile::dump_func_name_to_id(void)
{
    FILE *fp = fopen("debprof_func_name_to_id.txt", "w");
    for(auto it = func_name_to_id.begin(); it != func_name_to_id.end(); it++){
        fprintf(fp, "%s %u\n", it->first.c_str(), it->second);
    }
    fclose(fp);
}


bool DebloatProfile::runOnFunction(Function &F)
{
    LI = &getAnalysis<LoopInfoWrapperPass>().getLoopInfo();
    map<Loop *, set<int> *> loop_to_func_ids;
    return run_on_function(DEB_PROFILE,
                           F,
                           debprof_print_args_func,
                           jump_phi_nodes,
                           LI,
                           NULL,
                           NULL,
                           NULL,
                           NULL,
                           NULL,
                           call_inst_to_id,
                           &call_inst_count,
                           &func_count,
                           &stats,
                           loop_to_func_ids,
                           app_funcs,
                           func_name_to_id);
}


void DebloatProfile::init_debprof_print_func(Module &M)
{
    Type *ArgTypes[] = { int32Ty  };
    string custom_instr_func_name("debprof_print_args");

    debprof_print_args_func =
      Function::Create(FunctionType::get(int32Ty, ArgTypes, true),
                       Function::ExternalLinkage,
                       "debprof_print_args",
                       M);


}




char DebloatProfile::ID = 0;
static RegisterPass<DebloatProfile>
Y("DebloatProfile", "Add profiling support for debloating");
