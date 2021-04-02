#include "CGPredict.hpp"


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




void CGPredict::dump_stats(void)
{
    FILE *fp = fopen("cgpprof_pass_stats.txt", "w");
    fclose(fp);
}


void CGPredict::dump_func_name_to_id(void)
{
    FILE *fp = fopen("cgpprof_func_name_to_id.txt", "w");
    for(auto it = func_name_to_id.begin(); it != func_name_to_id.end(); it++){
        fprintf(fp, "%s %u\n", it->first.c_str(), it->second);
    }
    fclose(fp);
}


void CGPredict::init_debprof_print_func(Module &M)
{
    Type *ArgTypes[] = { int32Ty  };
    string custom_instr_func_name("debprof_print_args");

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
void CGPredict::init_debrt_funcs(Module &M)
{
    Type *ArgTypes[] = { int32Ty  };

    debrt_cgmonitor_func =
      Function::Create(FunctionType::get(int32Ty, ArgTypes, true),
                       Function::ExternalLinkage,
                       "debrt_cgmonitor",
                       M);

}

void CGPredict::instrument_func_start(Function *f,
                                      Instruction *inst_before,
                                      unsigned int func_id)
{
    IRBuilder<> builder(inst_before);
    vector<Value *> ArgsV;
    ArgsV.push_back(llvm::ConstantInt::get(int32Ty, 1, false));
    ArgsV.push_back(llvm::ConstantInt::get(int32Ty, func_id, false));

    LLVM_DEBUG(dbgs() << "Instrumenting func start: " << inst_before << "\n");
    CallInst *debprof_call = builder.CreateCall(f, ArgsV);
}


void CGPredict::read_func_name_to_id(void)
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


