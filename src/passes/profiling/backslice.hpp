#ifndef WPD_BACKSLICE_HPP
#define WPD_BACKSLICE_HPP

#include "DebloatProfile.hpp"


void backslice(Instruction *I,
                   std::map<Instruction *, uint64_t> &jump_phi_nodes);


#endif
