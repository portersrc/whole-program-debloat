#include "CGPredict.hpp"




void CGPredict::dump_stats(void)
{
    FILE *fp = fopen("cgpprof_pass_stats.txt", "w");
    fclose(fp);
}


// FIXME move to constructor
void CGPredict::init_aux(Module &M)
{
    int32Ty = IntegerType::getInt32Ty(M.getContext());
    int64Ty = IntegerType::getInt64Ty(M.getContext());
    ptr_i8  = PointerType::get(Type::getInt8Ty(M.getContext()), 0);
}


void CGPredict::instrument_func_start(Function *call_me,
                                      Instruction *inst_before,
                                      unsigned int func_id)
{
    IRBuilder<> builder(inst_before);
    vector<Value *> ArgsV;
    ArgsV.push_back(llvm::ConstantInt::get(int32Ty, 1, false));
    ArgsV.push_back(llvm::ConstantInt::get(int32Ty, func_id, false));

    LLVM_DEBUG(dbgs() << "Instrumenting func start: " << inst_before << "\n");
    CallInst *debprof_call = builder.CreateCall(call_me, ArgsV);
}
