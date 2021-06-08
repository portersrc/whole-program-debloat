#include "llvm/ADT/DepthFirstIterator.h"
#include "llvm/ADT/EquivalenceClasses.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/IR/Dominators.h"
#include "llvm/Pass.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/Transforms/Utils/Cloning.h"
#include "llvm/Transforms/Utils/LoopUtils.h"
#include "llvm/Transforms/Utils/LoopVersioning.h"
#include "llvm/Analysis/DependenceAnalysis.h"
#include "llvm/Analysis/ScalarEvolutionExpressions.h"
#include <list>
#include <fstream>
#include <string>

using namespace llvm;

// #define LLVM_DEBUG
#define LSPLIT_NAME "loop-splitting"
// #define DEBUG_TYPE LSPLIT_NAME

STATISTIC(NumLoopsSplitted, "Number of loops splitted");
static cl::opt<float>
       Threshold("threshold", cl::init(0.0), cl::Required,
                 cl::desc("Set the RD threshold for loops to be splitted."));

namespace {
/// \brief Maintains the set of instructions of the loop for a partition before
/// cloning.  After cloning, it hosts the new loop.
    class InstPartition {
        typedef SmallPtrSet<Instruction *, 8> InstructionSet;

    public:
        InstPartition(Instruction *I, Loop *L)
                : OrigLoop(L), ClonedLoop(nullptr), Reuse(0) {
            if (I) Set.insert(I);
        }

        /// \brief Adds an instruction to this partition.
        void add(Instruction *I, unsigned reuse) { Set.insert(I); Reuse += reuse; }

        /// \brief Collection accessors.
        InstructionSet::iterator begin() { return Set.begin(); }
        InstructionSet::iterator end() { return Set.end(); }
        InstructionSet::const_iterator begin() const { return Set.begin(); }
        InstructionSet::const_iterator end() const { return Set.end(); }
        bool empty() const { return Set.empty(); }
        bool contains(Instruction *I) { return Set.count(I); }
        bool hasReuse() const { return Reuse > 0; }

        unsigned getSize() const { return Set.size(); }
        unsigned getReuse() const { return Reuse; }

        /// \brief Moves this partition into \p Other.  This partition becomes empty
        /// after this.
        void moveTo(InstPartition &Other) {
            Other.Set.insert(Set.begin(), Set.end());
            Set.clear();
        }

        /// \brief Populates the partition with a transitive closure of all the
        /// instructions that the seeded instructions dependent on.
        void populateUsedSet() {
            // FIXME: We currently don't use control-dependence but simply include all
            // blocks (possibly empty at the end) and let simplifycfg mostly clean this
            // up.
            for (auto *B : OrigLoop->getBlocks())
                Set.insert(B->getTerminator());

            // Follow the use-def chains to form a transitive closure of all the
            // instructions that the originally seeded instructions depend on.
            SmallVector<Instruction *, 8> Worklist(Set.begin(), Set.end());
            while (!Worklist.empty()) {
                Instruction *I = Worklist.pop_back_val();
                LLVM_DEBUG(dbgs() << "\nCurrent instruction: ");
#ifdef LLVM_DEBUG
                I->dump();
#endif
                // Insert instructions from the loop that we depend on.
                for (Value *V : I->operand_values()) {
                    auto *I = dyn_cast<Instruction>(V);
                    if (I && OrigLoop->contains(I->getParent()) && Set.insert(I).second) {
#ifdef LLVM_DEBUG
                        I->dump();
#endif
                        Worklist.push_back(I);
                    }
                }
            }
        }

        /// \brief Clones the original loop.
        ///
        /// Updates LoopInfo and DominatorTree using the information that block \p
        /// LoopDomBB dominates the loop.
        Loop *cloneLoopWithPreheader(BasicBlock *InsertBefore, BasicBlock *LoopDomBB,
                                     unsigned Index, LoopInfo *LI,
                                     DominatorTree *DT) {
            ClonedLoop = ::cloneLoopWithPreheader(InsertBefore, LoopDomBB, OrigLoop,
                                                  VMap, Twine(".lsplit") + Twine(Index),
                                                  LI, DT, ClonedLoopBlocks);
            return ClonedLoop;
        }

        /// \brief The cloned loop.  If this partition is mapped to the original loop,
        /// this is null.
        const Loop *getClonedLoop() const { return ClonedLoop; }

        /// \brief Returns the loop where this partition ends up after splitting.
        /// If this partition is mapped to the original loop then use the block from
        /// the loop.
        const Loop *getSplittedLoop() const {
            return ClonedLoop ? ClonedLoop : OrigLoop;
        }

        /// \brief The VMap that is populated by cloning and then used in
        /// remapinstruction to remap the cloned instructions.
        ValueToValueMapTy &getVMap() { return VMap; }

        /// \brief Remaps the cloned instructions using VMap.
        void remapInstructions() {
            remapInstructionsInBlocks(ClonedLoopBlocks, VMap);
        }

        /// \brief Based on the set of instructions selected for this partition,
        /// removes the unnecessary ones.
        void removeUnusedInsts() {
            SmallVector<Instruction *, 8> Unused;

            for (auto *Block : OrigLoop->getBlocks())
                for (auto &Inst : *Block) {
                    if (!Set.count(&Inst)) {
                        Instruction *NewInst = &Inst;
                        if (!VMap.empty())
                            NewInst = cast<Instruction>(VMap[NewInst]);

                        assert(!isa<BranchInst>(NewInst) &&
                               "Branches are marked used early on");
                        Unused.push_back(NewInst);
                    }
                    if (Reuse < Threshold * getSize())
                        if (Inst.getName().count("Pin") || Inst.getName().count("UnPin"))
                            Unused.push_back(&Inst);
                }

            // Delete the instructions backwards, as it has a reduced likelihood of
            // having to update as many def-use and use-def chains.
            for (auto *Inst : make_range(Unused.rbegin(), Unused.rend())) {
                if (!Inst->use_empty())
                    Inst->replaceAllUsesWith(UndefValue::get(Inst->getType()));
                Inst->eraseFromParent();
            }
        }

        void print() const {
            for (auto *I : Set)
                // Prefix with the block name.
                dbgs() << "  " << I->getParent()->getName() << ":" << *I << "\n";
        }

        void printBlocks() const {
            for (auto *BB : getSplittedLoop()->getBlocks())
                dbgs() << *BB;
        }

    private:
        /// \brief Instructions from OrigLoop selected for this partition.
        InstructionSet Set;

        /// \brief The original loop.
        Loop *OrigLoop;

        /// \brief The cloned loop.  If this partition is mapped to the original loop,
        /// this is null.
        Loop *ClonedLoop;

        /// \brief The blocks of ClonedLoop including the preheader.  If this
        /// partition is mapped to the original loop, this is empty.
        SmallVector<BasicBlock *, 8> ClonedLoopBlocks;

        /// \brief These gets populated once the set of instructions have been
        /// finalized. If this partition is mapped to the original loop, these are not
        /// set.
        ValueToValueMapTy VMap;

        unsigned Reuse;
    };

/// \brief Holds the set of Partitions.  It populates them, merges them and then
/// clones the loops.
    class InstPartitionContainer {
        typedef DenseMap<Instruction *, unsigned> InstToPartitionIdT;

    public:
        InstPartitionContainer(Loop *L, LoopInfo *LI, DominatorTree *DT)
                : L(L), LI(LI), DT(DT) {}

        /// \brief Returns the number of partitions.
        unsigned getSize() const { return PartitionContainer.size(); }

        //  Initially we isolate memory instructions into as many partitions as
        //  possible, then later we may merge them back together.
        void addToNewPartition(Instruction *Inst) {
            PartitionContainer.emplace_back(Inst, L);
        }

        void addToCurrentPartition(Instruction *Inst, int reuse) {
            PartitionContainer.back().add(Inst, reuse);
        }

        /// \brief Merges the partitions according to various heuristics.
        void mergeBeforePopulating() {
            mergeAdjacentPartitionsIf(
                    [](const InstPartition *P) { return !P->hasReuse(); });
        }

        /// \brief Merges partitions in order to ensure that no loads are duplicated.
        ///
        /// We can't duplicate loads because that could potentially reorder them.
        /// LoopAccessAnalysis provides dependency information with the context that
        /// the order of memory operation is preserved.
        ///
        /// Return if any partitions were merged.
        bool mergePartitions() {
            bool merged = false;
            // Get the starting point
            unsigned maxReuse = 0;
            unsigned distance;
            PartitionContainerT::iterator SI;
            for (PartitionContainerT::iterator I = PartitionContainer.begin(),
                         E = PartitionContainer.end();
                 I != E; ++I) {
                unsigned reuse = (*I).getReuse();
                if (maxReuse < reuse) {
                    maxReuse = reuse;
                    SI = I;
                    distance = std::distance(PartitionContainer.begin(), SI);
                }
            }

            // remove redundant partitions
            std::vector<PartitionContainerT::iterator> Iters;
            for (PartitionContainerT::iterator I = PartitionContainer.begin(),
                         E = PartitionContainer.end();
                 I != E; ++I) {
                if (std::distance(PartitionContainer.begin(), I) != distance)
                    for (Instruction *Inst : *SI)
                        if (isa<GetElementPtrInst>(Inst))
                            if ((*I).contains(Inst)) {
                                Iters.emplace_back(I);
                                break;
                            }
            }
            for (PartitionContainerT::iterator I : Iters)
                (*I).moveTo(*SI);

            // Expansion
            std::vector<Instruction*> worklist;
            for (Instruction *Inst : *SI)
                if (isa<GetElementPtrInst>(Inst))
                    worklist.push_back(Inst);

            while (!worklist.empty()) {
                Instruction* currInst = worklist.back();
                worklist.pop_back();
                for (PartitionContainerT::iterator I = PartitionContainer.begin(),
                             E = PartitionContainer.end();
                     I != E; ++I) {
                    if ((*I).hasReuse()
                        && std::distance(PartitionContainer.begin(), I) != distance
                        && (*I).contains(currInst)) {
                        for (Instruction *Inst : *SI)
                            if (isa<GetElementPtrInst>(Inst))
                                worklist.push_back(Inst);
                        (*I).moveTo(*SI);
                        merged = true;
                    }
                }
            }

            // Remove the empty partitions.
            PartitionContainer.remove_if(
                    [](const InstPartition &P) { return P.empty(); });

            return merged;
        }

        /// \brief Sets up the mapping between instructions to partitions.
        void setupPartitionIdOnInstruction(Instruction *Inst, unsigned ID) {
            bool NewElt;
            InstToPartitionIdT::iterator Iter;

            std::tie(Iter, NewElt) =
                    InstToPartitionId.insert(std::make_pair(Inst, ID));
            assert(NewElt && "Same instruction has multiple IDs");
        }

        /// \brief Populates the partition with everything that the seeding
        /// instructions require.
        void populateUsedSet() {
            for (auto &P : PartitionContainer)
                P.populateUsedSet();
        }

        /// \brief This performs the main chunk of the work of cloning the loops for
        /// the partitions.
        void cloneLoops() {
            BasicBlock *OrigPH = L->getLoopPreheader();
            // At this point the predecessor of the preheader is either the memcheck
            // block or the top part of the original preheader.
            BasicBlock *Pred = OrigPH->getSinglePredecessor();
            assert(Pred && "Preheader does not have a single predecessor");
            BasicBlock *ExitBlock = L->getExitBlock();
            assert(ExitBlock && "No single exit block");
            Loop *NewLoop;

            assert(!PartitionContainer.empty() && "at least two partitions expected");
            // We're cloning the preheader along with the loop so we already made sure
            // it was empty.
            assert(&*OrigPH->begin() == OrigPH->getTerminator() &&
                   "preheader not empty");

            // Create a loop for each partition except the last.  Clone the original
            // loop before PH along with adding a preheader for the cloned loop.  Then
            // update PH to point to the newly added preheader.
            BasicBlock *TopPH = OrigPH;
            unsigned Index = 1;
            for (auto I = std::next(PartitionContainer.rbegin()),
                         E = PartitionContainer.rend();
                 I != E; ++I, --Index, TopPH = NewLoop->getLoopPreheader()) {
                auto *Part = &*I;

                NewLoop = Part->cloneLoopWithPreheader(TopPH, Pred, Index, LI, DT);

                Part->getVMap()[ExitBlock] = TopPH;
                Part->remapInstructions();
            }
            Pred->getTerminator()->replaceUsesOfWith(OrigPH, TopPH);

            // Now go in forward order and update the immediate dominator for the
            // preheaders with the exiting block of the previous loop.  Dominance
            // within the loop is updated in cloneLoopWithPreheader.
            for (auto Curr = PartitionContainer.cbegin(),
                         Next = std::next(PartitionContainer.cbegin()),
                         E = PartitionContainer.cend();
                 Next != E; ++Curr, ++Next)
                DT->changeImmediateDominator(
                        Next->getSplittedLoop()->getLoopPreheader(),
                        Curr->getSplittedLoop()->getExitingBlock());
        }

        /// \brief Removes the dead instructions from the cloned loops.
        void removeUnusedInsts() {
            for (auto &Partition : PartitionContainer)
                Partition.removeUnusedInsts();
        }

        void print(raw_ostream &OS) const {
            unsigned Index = 0;
            for (const auto &P : PartitionContainer) {
                OS << "Partition " << Index++ << " (" << &P << "):\n";
                P.print();
            }
        }

        void dump() const { print(dbgs()); }

#ifndef NDEBUG
        friend raw_ostream &operator<<(raw_ostream &OS,
                                       const InstPartitionContainer &Partitions) {
            Partitions.print(OS);
            return OS;
        }
#endif

        void printBlocks() const {
            unsigned Index = 0;
            for (const auto &P : PartitionContainer) {
                dbgs() << "\nPartition " << Index++ << " (" << &P << "):\n";
                P.printBlocks();
            }
        }

        bool ifQualified() {
            for (PartitionContainerT::iterator I = PartitionContainer.begin(),
                 E = PartitionContainer.end(); I != E; ++I) {
                unsigned reuse = (*I).getReuse();
                if (reuse >= Threshold * (*I).getSize()) return true;
            }
            return false;
        }

    private:
        typedef std::list<InstPartition> PartitionContainerT;

        /// \brief List of partitions.
        PartitionContainerT PartitionContainer;

        /// \brief Mapping from Instruction to partition.
        InstToPartitionIdT InstToPartitionId;

        Loop *L;
        LoopInfo *LI;
        DominatorTree *DT;

        /// \brief The control structure to merge adjacent partitions if both satisfy
        /// the \p Predicate.
        template <class UnaryPredicate>
        void mergeAdjacentPartitionsIf(UnaryPredicate Predicate) {
            InstPartition *PrevMatch = nullptr;
            for (auto I = PartitionContainer.begin(); I != PartitionContainer.end();) {
                auto DoesMatch = Predicate(&*I);
                if (PrevMatch == nullptr && DoesMatch) {
                    PrevMatch = &*I;
                    ++I;
                } else if (PrevMatch != nullptr && DoesMatch) {
                    I->moveTo(*PrevMatch);
                    I = PartitionContainer.erase(I);
                } else {
                    PrevMatch = nullptr;
                    ++I;
                }
            }

            // Fix the issue of missing increments for splitted loops
            std::vector<Instruction *> Insts;
            for (auto I = PartitionContainer.begin(); I != PartitionContainer.end(); ++I) {
                for (Instruction *Inst : *I) {
                    if (Inst->getParent()->getName().endswith("inc"))
                        Insts.emplace_back(Inst);
                }
            }

            for (auto I = PartitionContainer.begin(); I != PartitionContainer.end(); ++I) {
                if (!(*I).hasReuse())
                    for (Instruction *Inst : Insts)
                        (*I).add(Inst, 0);
            }
        }
    };

/// \brief The pass class.
    class LoopSplitting : public FunctionPass {
    public:
        LoopSplitting() : FunctionPass(ID) {}

        bool runOnFunction(Function &F) override {
            bool flag = true, Changed = false;

            if (flag) {
                LI = &getAnalysis<LoopInfoWrapperPass>().getLoopInfo();
                DT = &getAnalysis<DominatorTreeWrapperPass>().getDomTree();
                SE = &getAnalysis<ScalarEvolutionWrapperPass>().getSE();
                DA = &getAnalysis<DependenceAnalysisWrapperPass>().getDI();

                // Build up a worklist of inner-loops to split.
                SmallVector<Loop *, 8> Worklist;

                for (Loop *TopLevelLoop : *LI)
                    for (Loop *L : depth_first(TopLevelLoop))
                        // We only handle inner-most loops.
                        if (L->getSubLoops().empty())
                            Worklist.push_back(L);

                // Now walk the identified inner loops.
                for (Loop *L : Worklist)
                    Changed |= processLoop(L);
                errs() << "\n# of splitted loops: " << NumLoopsSplitted << "\n";
            }

            // Process each loop nest in the function.
            return Changed;
        }

        void getAnalysisUsage(AnalysisUsage &AU) const override {
            AU.addRequired<ScalarEvolutionWrapperPass>();
            AU.addRequired<LoopInfoWrapperPass>();
            AU.addRequired<DominatorTreeWrapperPass>();
            AU.addRequired<DependenceAnalysisWrapperPass>();
        }

        static char ID;

    private:
        /// \brief Try to split an inner-most loop.
        bool processLoop(Loop *L) {
            assert(L->getSubLoops().empty() && "Only process inner loops.");

            LLVM_DEBUG(dbgs() << "\nLSplit: In \"" << L->getHeader()->getParent()->getName()
                  << "\" checking " << *L << "\n");

            BasicBlock *PH = L->getLoopPreheader();
            if (!PH) {
                LLVM_DEBUG(dbgs() << "Skipping; no preheader");
                return false;
            }
            if (!L->getExitBlock()) {
                LLVM_DEBUG(dbgs() << "Skipping; multiple exit blocks");
                return false;
            }

            InstPartitionContainer Partitions(L, LI, DT);

            // compute memory reuse density for each pair of instructions
            unsigned ID = 0;
            for (Loop::block_iterator I = L->block_begin(), E = L->block_end(); I != E; ++I) {
                BasicBlock *bb = *I;
                for (BasicBlock::iterator II = bb->begin(), IE = bb->end(); II != IE; ++II) {
                    Instruction *curr_instr = &(*II);
                    if (isa<LoadInst>(*curr_instr) || isa<StoreInst>(*curr_instr)) {
                        bool flag = true;
                        Partitions.setupPartitionIdOnInstruction(curr_instr, ID++);
                        // iterate instructions in current basic block
                        for (BasicBlock::iterator J = II; J != IE; ++J) {
                            Instruction *instr = &(*J);
                            if (isa<LoadInst>(*instr) || isa<StoreInst>(*instr)) {
                                if (curr_instr != instr) {
                                    int reuse;
                                    if (auto D = DA->depends(curr_instr, instr, true)) {
                                        unsigned levels = D->getLevels();
                                        reuse = 0;
                                        for (unsigned i = 1; i <= levels; ++i) {
                                            const SCEV *Distance = D->getDistance(i);
                                            const SCEVConstant *SCEVConst = dyn_cast_or_null<SCEVConstant>(Distance);
                                            if (SCEVConst) {
                                                reuse += i;//The value of distance is of not use as of now as
                                                //it will be approximated to ~ n
                                            } else if (D->isScalar(i)) {
                                                //reuse += 0; This scalar variable is stored in register so
                                                //not required for mem reuse
                                            } else if (D->isAnti()) {
                                                unsigned Dir = D->getDirection(i);
                                                if (Dir == Dependence::DVEntry::LT || Dir == Dependence::DVEntry::LE
                                                    || Dir == Dependence::DVEntry::GT || Dir == Dependence::DVEntry::GE
                                                    || Dir == Dependence::DVEntry::EQ ||
                                                    Dir == Dependence::DVEntry::ALL)
                                                    reuse += i;
                                            } else {
                                                //There is depedence
                                                reuse += i;
                                            }
                                        }
                                    }
                                    // reuse is not zero, record two instructions along with their reuse
                                    if (reuse) {
                                        if (flag) Partitions.addToNewPartition(curr_instr);
                                        Partitions.addToCurrentPartition(instr, reuse);
                                        flag = false;
                                    }
                                    // include loads and stores in between
                                    else if (!flag) {
                                        Partitions.addToCurrentPartition(instr, reuse);
                                    }
                                }
                            }
                        }
                        if (flag) Partitions.addToNewPartition(curr_instr);
                    }
                }
            }

            // Add partitions for values used outside.  These partitions can be out of
            // order from the original program order.  This is OK because if the
            // partition uses a load we will merge this partition with the original
            // partition of the load that we set up in the previous loop (see
            // mergeToAvoidDuplicatedLoads).
            auto DefsUsedOutside = findDefsUsedOutsideOfLoop(L);
            for (auto *Inst : DefsUsedOutside)
                Partitions.addToNewPartition(Inst);

            LLVM_DEBUG(dbgs() << "\nInitial partitions:\n" << Partitions);
            if (Partitions.getSize() < 2)
                return false;

            Partitions.mergeBeforePopulating();
            LLVM_DEBUG(dbgs() << "\nMerged partitions:\n" << Partitions);
            if (Partitions.getSize() < 2)
                return false;

            // Now, populate the partitions with non-memory operations.
            Partitions.populateUsedSet();
            LLVM_DEBUG(dbgs() << "\nPopulated partitions:\n" << Partitions);
            if (Partitions.getSize() < 2)
                return false;

            Partitions.mergePartitions();
            LLVM_DEBUG(dbgs() << "\nPartitions merged to ensure unique loads:\n" << Partitions);
            if (Partitions.getSize() < 2)
                return false;

            LLVM_DEBUG(dbgs() << "\nSplitting loop: " << *L << "\n");

            // To keep things simple have an empty preheader before we version or clone
            // the loop.  (Also split if this has no predecessor, i.e. entry, because we
            // rely on PH having a predecessor.)
            if (!PH->getSinglePredecessor() || &*PH->begin() != PH->getTerminator())
                SplitBlock(PH, PH->getTerminator(), DT, LI);

            if (Partitions.ifQualified()) {
                // Create identical copies of the original loop for each partition and hook
                // them up sequentially.
                Partitions.cloneLoops();

                // Now, we remove the instruction from each loop that don't belong to that
                // partition.
                Partitions.removeUnusedInsts();
                LLVM_DEBUG(dbgs() << "\nAfter removing unused Instrs:\n");
                LLVM_DEBUG(Partitions.printBlocks());
                if (Partitions.getSize() < 2)
                    return false;

                ++NumLoopsSplitted;
                return true;
            } else {
                return false;
            }
        }

        // Analyses used.
        LoopInfo *LI;
        DominatorTree *DT;
        ScalarEvolution *SE;
        DependenceInfo *DA;
    };
} // anonymous namespace

char LoopSplitting::ID = 0;
static RegisterPass<LoopSplitting> X("LoopSplitting", "Splitting Loops");