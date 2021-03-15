
#include "DebloatInstrument.hpp"
#include "../common/backslice.hpp"
#include "../common/util.hpp"










namespace {

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

    struct DebloatInstrument : public FunctionPass {

      public:
        static char ID;
        LoopInfo *LI;

        DebloatInstrument() : FunctionPass(ID) {}

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
        Function *debrt_monitor_func;
        Function *debrt_protect_func;
        Function *debrt_return_func;
        Function *debrt_return_func_intrinsic;
        Function *debrt_protect_loop_func;
        Function *debrt_loop_end_func;
        unordered_set<Function *> app_funcs;
        map<CallInst *, unsigned int> call_inst_to_id;
        map<string, unsigned int> func_name_to_id;
        unsigned int call_inst_count;
        unsigned int func_count;
        deb_stats_t stats;
        map<Loop *, vector<int> *> loop_to_func_ids;
        set<Instruction *> jump_phi_nodes;
        Type *int32Ty;
        Type *int64Ty;

        void init_debrt_funcs(Module &);

        void read_func_name_to_id(void);

    };
}


bool DebloatInstrument::doInitialization(Module &M)
{
    call_inst_count = 0;
    func_count = 0;

    int32Ty = IntegerType::getInt32Ty(M.getContext());
    int64Ty = IntegerType::getInt64Ty(M.getContext());

    for(auto &f : M){
        if(f.hasName() && !f.isDeclaration()){
            app_funcs.insert(&f);
        }
    }

    init_debrt_funcs(M);

    stats.max_num_args = 0;
    stats.num_calls_not_in_loops = 0;
    stats.num_calls_in_loops = 0;
    stats.num_loops_no_preheader = 0;

    read_func_name_to_id();

    return false;
}


void DebloatInstrument::read_func_name_to_id(void)
{
    string line;
    ifstream ifs;
    vector<string> elems;

    ifs.open("debprof_func_name_to_id.txt");
    if(!ifs.is_open()) {
        perror("Error opening func name to id file");
        exit(EXIT_FAILURE);
    }

    while(getline(ifs, line)){
        elems = split(line, ' ');
        func_name_to_id[elems[0]] = atoi(elems[1].c_str());
    }
}


bool DebloatInstrument::doFinalization(Module &M)
{
    return false;
}


bool DebloatInstrument::runOnFunction(Function &F)
{
    LI = &getAnalysis<LoopInfoWrapperPass>().getLoopInfo();
    return run_on_function(false,
                           F,
                           debrt_protect_func,
                           jump_phi_nodes,
                           LI,
                           debrt_return_func,
                           debrt_return_func_intrinsic,
                           call_inst_to_id,
                           &call_inst_count,
                           &func_count,
                           &stats,
                           loop_to_func_ids,
                           app_funcs,
                           func_name_to_id);
}



void DebloatInstrument::init_debrt_funcs(Module &M)
{
    Type *ptr_i8;
    ptr_i8 = PointerType::get(Type::getInt8Ty(M.getContext()), 0);

    Type *ArgTypes[]    = { int32Ty };
    Type *ArgTypes64[]  = { int64Ty };
    Type *ArgTypesPtr[] = { ptr_i8 };

    //debrt_monitor_func =
    //  Function::Create(FunctionType::get(int32Ty, ArgTypes, true),
    //                   Function::ExternalLinkage,
    //                   "debrt_monitor",
    //                   M);

    debrt_protect_func =
      Function::Create(FunctionType::get(int32Ty, ArgTypes, true),
                       Function::ExternalLinkage,
                       "debrt_protect",
                       M);
    debrt_return_func =
      Function::Create(FunctionType::get(int32Ty, ArgTypes64, true),
                       Function::ExternalLinkage,
                       "debrt_return",
                       M);

    debrt_return_func_intrinsic =
      Function::Create(FunctionType::get(ptr_i8, ArgTypes, false),
                       Function::ExternalLinkage,
                       "llvm.returnaddress",
                       &M);

    debrt_protect_loop_func =
      Function::Create(FunctionType::get(int32Ty, ArgTypes, true),
                       Function::ExternalLinkage,
                       "debrt_protect_loop",
                       M);

    debrt_loop_end_func = 
      Function::Create(FunctionType::get(int32Ty, false),
                       Function::ExternalLinkage,
                       "debrt_loop_end",
                       &M);

}




char DebloatInstrument::ID = 0;
static RegisterPass<DebloatInstrument>
Y("DebloatInstrument", "Add instrumentation support for debloating");
