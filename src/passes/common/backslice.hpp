#ifndef WPD_BACKSLICE_HPP
#define WPD_BACKSLICE_HPP

#include <llvm/IR/Instruction.h>
#include <llvm/IR/Instructions.h>
#include <llvm/IR/BasicBlock.h>
#include <llvm/IR/GlobalVariable.h>
#include "llvm/Support/Debug.h"

#include <set>


using namespace llvm;
using namespace std;


void backslice(Instruction *I, set<Instruction *> &jump_phi_nodes);


#endif
