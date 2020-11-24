#ifndef WPD_BACKSLICE_HPP
#define WPD_BACKSLICE_HPP

#include <map>

#include <llvm/Support/raw_ostream.h>
#include <llvm/Support/Debug.h>
#include <llvm/IR/Instruction.h>

#include "DebloatProfile.hpp"


void backslice(Instruction *I,
                   std::map<Instruction *, uint64_t> &jump_phi_nodes);


#endif
