#include "backslice.hpp"

void backslice(Instruction *I, std::map<Instruction *, uint64_t> &jump_phi_nodes)
{
    LLVM_DEBUG(dbgs() << "hit 0\n");

    Instruction *I2, *I3;

    // FIXME: jump_phi_nodes needs proper initialization, etc.
    if(!jump_phi_nodes[I]){
        LoadInst *LI = dyn_cast<LoadInst>(I);
        CallInst *CI = dyn_cast<CallInst>(I);
        SelectInst *SI = dyn_cast<SelectInst>(I);

        /**************************************************************************
        * If instruction is a function pointer or a binary operator, we have
        * found the native birthpoint.
        **************************************************************************/
        if(CI || SI || I->isBinaryOp() || dyn_cast<GetElementPtrInst>(I) ||
           dyn_cast<AllocaInst>(I) || dyn_cast<GlobalVariable>(I)){
            LLVM_DEBUG(dbgs() << "hit 1\n");
            //instrument(I, dyn_cast<Value>(I));
        }else if(LI){
            /**************************************************************************
            * If instruction is a load instruction, we have to check if it loading from
            * a local variable (alloca), a global variable (globalvariable) or a pointer
            * (getelementptrinst/bitcast) as this means we have found the native birthpoint.
            * Else, backslice the operand.
            **************************************************************************/
            AllocaInst *AI = dyn_cast<AllocaInst>(LI->getOperand(0));
            GlobalVariable *GV = dyn_cast<GlobalVariable>(LI->getOperand(0));
            GetElementPtrInst *GEP = dyn_cast<GetElementPtrInst>(LI->getOperand(0));
            InvokeInst *II = dyn_cast<InvokeInst>(LI->getOperand(0));
            I2 = dyn_cast<Instruction>(LI->getOperand(0));

            if((!I2 && !GV) || AI || GV || GEP || II
               || dyn_cast<Instruction>(LI->getOperand(0))->isCast()){
                //instrument(I, dyn_cast<Value>(I));
                LLVM_DEBUG(dbgs() << "hit 2\n");
                LLVM_DEBUG(dbgs() << *I << "\n");
                LLVM_DEBUG(dbgs() << "hit 2 done\n");
            }
            else {
                backslice(I2, jump_phi_nodes);
                LLVM_DEBUG(dbgs() << "hit 3\n");
            }
        }else if(isa<PHINode>(I)){
            /**************************************************************************
            * If instruction is a Phi function, we backslice for each operand in the Phi
            * function.
            **************************************************************************/
            jump_phi_nodes[I] = 1;
            I3 = I;
            while(isa<PHINode>(I3)){
                I3 = I3->getNextNode();
            }
            I3 = I3->getPrevNode();

            uint64_t i;
            for(i = 0; i < I->getNumOperands(); ++i){
                I2 = dyn_cast<Instruction>(I->getOperand(i));
                if(I2){
                    InvokeInst *II = dyn_cast<InvokeInst>(I2);
                    if(!II){
                        backslice(I2, jump_phi_nodes);
                        LLVM_DEBUG(dbgs() << "hit 4\n");
                    }
                    else {
                        //instrument(I2, dyn_cast<Value>(I2));
                        LLVM_DEBUG(dbgs() << "hit 5\n");
                    }
                }
                else {
                    //instrument(I3, dyn_cast<Value>(I->getOperand(i)));
                    LLVM_DEBUG(dbgs() << "hit 6\n");
                }
            }

        }else {
            /**************************************************************************
            * Normally, these are casting functions left so we just backslice until we get
            * to a load
            **************************************************************************/
            I2 = dyn_cast<Instruction>(I->getOperand(0));
            if(I2){
                InvokeInst *II = dyn_cast<InvokeInst>(I2);
                if(!II){
                    backslice(dyn_cast<Instruction>(I->getOperand(0)), jump_phi_nodes);
                    LLVM_DEBUG(dbgs() << "hit 7\n");
                }
                else {
                    //instrument(I2, dyn_cast<Value>(I2));
                    LLVM_DEBUG(dbgs() << "hit 8\n");
                }
            }
            else {
                //instrument(I, dyn_cast<Value>(I->getOperand(0)));
                LLVM_DEBUG(dbgs() << "hit 9\n");
            }
        }
    }
}
