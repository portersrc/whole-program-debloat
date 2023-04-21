#!/usr/bin/env python3
from os.path import isfile
import sys


#
# TODO
# The purpose of this script....
#

samples = []
static_reachability = {}
loop_static_reachability = {}

funcs_to_func_set_id = {}
func_set_id_to_funcs = {}
func_set_id_counter = 0
unique_func_set_id_deck_root_pairs = {}

BASE_PATH='./'
#BASE_PATH = '/home/rudy/wo/advanced-rtd/whole-program-debloat/test/07_test/' # example test
if len(sys.argv) > 1:
    BASE_PATH = sys.argv[1] + '/'

PROFILE_FILENAME      = BASE_PATH + 'debrt-mapped-rx-pages-artd_profile.out'
TRAIN_FILENAME        = BASE_PATH + 'training-data.out'
FUNC_SET_IDS_FILENAME = BASE_PATH + 'func-set-id-to-funcs.out'
DECK_ROOT_FILENAME    = BASE_PATH + 'func-set-id-deck-root-pairs.out'

if not isfile(PROFILE_FILENAME):
    print('ERROR: Profile filename does not exist ({}).'.format(PROFILE_FILENAME))
    print('Exiting')
    sys.exit(1)




class LogType:
    DECKING = 0
    RECORDED_FUNC_IDS = 1
    PROFILE = 2


class DeckChange:
    GROW = 0
    SHRINK = 1


class DeckType:
    SINGLE = 0
    LOOP = 1
    REACHABLE = 2
    INDIRECT = 3


class IndirectDeckType:
    SINGLE = 0
    REACHABLE = 1


class LineParts:
    def __init__(self, data_part, log_type, deck_change, deck_type, indirect_deck_type):
        self.data_part = data_part
        self.log_type = log_type
        self.deck_change = deck_change
        self.deck_type = deck_type
        self.indirect_deck_type = indirect_deck_type



def get_func_set_id(funcs, deck_root_str):
    global func_set_id_counter
    deck_root = int(deck_root_str)
    # If the deck root is a loop, don't insert it (i.e. we dont care about
    # that for the purposes of func set ID generation). Note that down
    # the line, this matters for identifying RPs. The compiler pass will manage
    # that question (see build_RPs).
    if deck_root >= 0:
        # Not sure if this check is necessary... but whatever. this ensures we
        # don't put a duplicate into funcs
        if deck_root_str not in set(funcs):
            funcs.append(deck_root_str)
    key = ','.join(sorted(funcs))
    if key not in funcs_to_func_set_id:
        funcs_to_func_set_id[key] = func_set_id_counter
        func_set_id_to_funcs[func_set_id_counter] = key
        func_set_id_counter += 1
    return funcs_to_func_set_id[key]


class Sample:
    #def __init__(self, func_set_id, features, deck_type, target):
    #def __init__(self, func_set_id, features):
    #def __init__(self, func_set_id, features, deck_type):
    #def __init__(self, features, deck_type):
    def __init__(self, features):
        self.features = features
        self.func_set_id = None
        self.deck_type = None
        #self.deck_type = deck_type
        #self.target = target

    def __str__(self):
        return str(self.func_set_id) + ',' + ','.join(self.features)


def parse_line(line_vec):
    if line_vec[0].startswith('page'):
        log_type = LogType.DECKING
    elif line_vec[0] == 'recorded-func-ids':
        log_type = LogType.RECORDED_FUNC_IDS
    else:
        assert line_vec[0].startswith('profile')
        log_type = LogType.PROFILE

    deck_change = None
    deck_type = None
    indirect_deck_type = None
    if log_type == LogType.DECKING:
        # XXX The way these checks are written, order matters!
        # For example, line_vec[0] can be "page-grow-single-indirect", so
        # first check if 'indirect' is in the string. If it's not, then (and
        # only then) is it safe to assume that 'single' in the string implies
        # a DeckType of SINGLE.
        if 'indirect' in line_vec[0]:
            deck_type = DeckType.INDIRECT
            if 'single' in line_vec[0]:
                indirect_deck_type = IndirectDeckType.SINGLE
            else:
                assert 'reachable' in line_vec[0]
                indirect_deck_type = IndirectDeckType.REACHABLE
        elif 'single' in line_vec[0]:
            deck_type = DeckType.SINGLE
        elif 'loop' in line_vec[0]:
            deck_type = DeckType.LOOP
        else:
            assert 'reachable' in line_vec[0]
            deck_type = DeckType.REACHABLE

        if 'grow' in line_vec[0]:
            deck_change = DeckChange.GROW
        else:
            assert 'shrink' in line_vec[0]
            deck_change = DeckChange.SHRINK

    return LineParts(line_vec[1:], log_type, deck_change, deck_type, indirect_deck_type)


def process_profile_log():
    uniq_func_set_cnt = 0
    samples_shadow = []
    sample_stack = []
    sample_stack_shadow = []
    profile_flag = False
    features = None
    with open(PROFILE_FILENAME) as f:
        assert f.readline().strip().startswith('page-grow-init') # skip first line
        line_num = 1
        for line in f:
            line_num += 1
            line = line.strip()
            print('(line {}) {}'.format(line_num, line))
            line_vec = line.split()
            line_parts = parse_line(line_vec)
            print('sample_stack size: {}'.format(len(sample_stack)))
            print('sample_stack_shadow size: {}'.format(len(sample_stack_shadow)))
            print('samples size:      {}'.format(len(samples)))
            print('samples_shadow size:      {}'.format(len(samples_shadow)))
            print('line_parts deck_type: {}'.format(line_parts.deck_type))

            if line_parts.log_type == LogType.PROFILE:
                print('log type is PROFILE')
                s = Sample(features=line_parts.data_part)
                sample_stack.append(s)
                sample_stack_shadow.append(line)

            elif line_parts.log_type == LogType.RECORDED_FUNC_IDS:
                print('log type is RECORDED_FUNC_IDS')
                s = sample_stack[-1]
                s_shadow = sample_stack_shadow[-1]
                assert s.func_set_id == None
                s.func_set_id = get_func_set_id(line_parts.data_part, s.features[0])
                _ = sample_stack.pop()
                _ = sample_stack_shadow.pop()
                samples.append(s)
                samples_shadow.append(s_shadow)
            else:
                print('log type is DECKING')
                assert line_parts.log_type == LogType.DECKING
                # ignore single decks (nothing to predict)
                # TODO: We should also ignore the single-indirect case as well.
                # I think this probably means we would pop the last profile off
                # the stack. But double-check that we actually write a profile
                # log for that case first.
                if line_parts.deck_type == DeckType.SINGLE:
                    print('deck type is SINGLE')
                    continue
                if line_parts.deck_change == DeckChange.GROW:
                    print('deck change is GROW')
                    s = sample_stack[-1]
                    s.deck_type = line_parts.deck_type
                else:
                    assert line_parts.deck_change == DeckChange.SHRINK
                    print('deck change is SHRINK')
                    s = samples[-1]
                    s_shadow = samples_shadow[-1]
                    print('s deck_type: {}'.format(s.deck_type))
                    if s.deck_type != line_parts.deck_type:
                        print('s_shadow: {}'.format(s_shadow))
                        print('len of sample_stack_shadow: {}'.format(len(sample_stack_shadow)))
                        print()
                    #assert s.deck_type == line_parts.deck_type
                    # Note: indirect decks have no "shrink", but whenver we do
                    # see a shrink, it should match with whatever was last
                    # pushed into our samples.

    # Populate a map so we have all unique func-set-id, deck-root pairs.
    # The "deck root" is the function or loop ID where the deck occurs (i.e.
    # not the deck ID, which is just a unique identifier for a deck).
    # features[0] is the function or loop ID. features[1] is the deck ID.
    # We want features[0] for this.
    for sample in samples:
        if sample.func_set_id not in unique_func_set_id_deck_root_pairs:
            unique_func_set_id_deck_root_pairs[sample.func_set_id] = set()
        unique_func_set_id_deck_root_pairs[sample.func_set_id].add(sample.features[0])

    print('Finished with len of samples: {}'.format(len(samples)))
    print('Finished with len of sample_stack: {}'.format(len(sample_stack)))


# This function is a bit of a hack. The right thing to do in this function  is
# basically create the intersection between each prediction and its
# corresponding deck, and ensure that the intersection matches the prediction
# set. That is, the prediction should be a subset of the full deck. The assert
# would be something like:
#   assert intersect_set == pred_set
# But as of this writing, three benchmarks don't pass this assertion:
#   parest
#   omnetpp
#   xalancbmk
# The proper fix is to keep this assert and resolve this problem closer to
# wherever it is occurring. It could be in the compiler instrumentation
# for the profiling, the runtime support for the profiling, or in this parser
# script itself when parsing the profile log leading up to this function.
# This could be challenging, though. Instead, this function opts to identify
# the cases where the pred set is not a subset of the deck and then remove
# the extraneous functions from the pred set to force it to be a subset
# of the deck. This could impact prediction accuracy or performance downstream,
# but it at least ensures correctness (i.e. that the pred set is a subset of
# the deck).
def ensure_pred_sets_are_within_deck():

    def sanity_check_pred_sets_are_within_deck():
        for func_set_id in unique_func_set_id_deck_root_pairs:
            for deck_root in unique_func_set_id_deck_root_pairs[func_set_id]:
                deck_root_int = int(deck_root)
                if deck_root_int >= 0: # is a func id
                    # copy the set just in case, b/c we modify it.
                    full_deck = set(static_reachability[deck_root])
                    full_deck.add(deck_root)
                else: # is a loop id
                    deck_root_int = (deck_root_int * -1) - 1
                    # copy not needed (we dont modify), but doing it for consistency
                    full_deck = set(loop_static_reachability[str(deck_root_int)])

                # func-set-id-to-funcs stores its values as a comma separated string
                pred_set = set(func_set_id_to_funcs[func_set_id].split(','))
                pred_set.discard('') # remove empty string if present

                intersect_set = full_deck & pred_set
                assert intersect_set == pred_set

    print('Checking pred sets are within their respective decks')
    changes_to_make = {}
    problem_with_intersect_count = 0
    read_static_reachability()
    read_loop_static_reachability()
    for func_set_id in unique_func_set_id_deck_root_pairs:
        for deck_root in unique_func_set_id_deck_root_pairs[func_set_id]:
            deck_root_int = int(deck_root)
            if deck_root_int >= 0: # is a func id
                # copy the set just in case, b/c we modify it.
                full_deck = set(static_reachability[deck_root])
                full_deck.add(deck_root)
            else: # is a loop id
                deck_root_int = (deck_root_int * -1) - 1
                # copy not needed (we dont modify), but doing it for consistency
                full_deck = set(loop_static_reachability[str(deck_root_int)])

            # func-set-id-to-funcs stores its values as a comma separated string
            pred_set = set(func_set_id_to_funcs[func_set_id].split(','))
            pred_set.discard('') # remove empty string if present

            intersect_set = full_deck & pred_set
            if intersect_set != pred_set:
                assert (intersect_set & pred_set) == intersect_set
                assert len(intersect_set) < len(pred_set)
                # Note, the intersect_set may be empty here. I dont see a
                # problem with that. For example, this just implies that
                # the complement set will be everything, but build_RPs should
                # handle this correctly, I believe.
                print('failing where intersect-set and pred-set are not equal')
                print('full_deck (len {}) (sorted)'.format(len(full_deck)))
                print(sorted(full_deck))
                print('pred_set (len {}) (sorted)'.format(len(pred_set)))
                print(sorted(pred_set))
                print('intersect_set (len {}) (sorted)'.format(len(intersect_set)))
                print(sorted(intersect_set))
                set_outside_of_deck = pred_set - intersect_set
                print('elements not in intersect (i.e. in pred set but not the deck) (len {}) (sorted)'.format(len(set_outside_of_deck)))
                print(sorted(set_outside_of_deck))
                # get_func_set_id will generate a new func set id (or use an
                # old one, if there is one to use). (also, pass '-1' as a hack
                # so we dont insert anything extra into the intersect_set
                new_func_set_id = get_func_set_id(list(intersect_set), '-1')
                assert func_set_id != new_func_set_id
                if func_set_id not in changes_to_make:
                    changes_to_make[func_set_id] = {}
                changes_to_make[func_set_id][deck_root] = new_func_set_id
                problem_with_intersect_count += 1

    if problem_with_intersect_count > 0:
        print('WARNING: Found {} cases where functions in a pred set were ' \
              'outside of the associated deck. This has been remediated by ' \
              'removing functions from the pred set that were not in the ' \
              'deck. This is a workaround for now, but the logs and/or the ' \
              'parsing of those logs (this script) could be improved further, ' \
              'which could give a boost in prediction accuracy.'.format(problem_with_intersect_count))

        print('Fixing unique_func_set_id_deck_root_pairs and samples...')
        # Fix up unique-func-set-id-deck-root-pairs
        for old_func_set_id in changes_to_make:
            for deck_root in changes_to_make[old_func_set_id]:
                new_func_set_id = changes_to_make[old_func_set_id][deck_root]
                # Remove old pair
                assert old_func_set_id in unique_func_set_id_deck_root_pairs
                assert deck_root  in unique_func_set_id_deck_root_pairs[old_func_set_id]
                unique_func_set_id_deck_root_pairs[old_func_set_id].remove(deck_root)
                if len(unique_func_set_id_deck_root_pairs[old_func_set_id]) == 0:
                    del unique_func_set_id_deck_root_pairs[old_func_set_id]
                # Add new pair
                if new_func_set_id not in unique_func_set_id_deck_root_pairs:
                    unique_func_set_id_deck_root_pairs[new_func_set_id] = set()
                unique_func_set_id_deck_root_pairs[new_func_set_id].add(deck_root)

        # Fix up samples
        for sample in samples:
            if sample.func_set_id in changes_to_make:
                # if the func set id and the deck root are a hit in our changes-to-make
                if sample.features[0] in changes_to_make[sample.func_set_id]:
                    # ... then change the func set id to new the one (for a reduced pred set)
                    sample.func_set_id = changes_to_make[sample.func_set_id][sample.features[0]]

        print('Done with fixes')
        sanity_check_pred_sets_are_within_deck()
        print('Sanity check passes')

    else:
        print('Done checking (OK)')



def write_output():
    fp_train_out     = open(TRAIN_FILENAME, 'w')
    fp_func_set_ids  = open(FUNC_SET_IDS_FILENAME, 'w')
    fp_deck_root_out = open(DECK_ROOT_FILENAME, 'w')

    # Write the samples to file.
    fp_train_out.write('func_set_id,feature0,feature1,feature2,feature3,feature4,feature5,feature6,feature7,feature8,feature9\n')
    for sample in samples:
        fp_train_out.write(str(sample) + '\n')

    # Write all unique func-set-id, deck-root pairs to file
    fp_deck_root_out.write('func_set_id,deck_root\n')
    for func_set_id in unique_func_set_id_deck_root_pairs:
        for deck_root in unique_func_set_id_deck_root_pairs[func_set_id]:
            fp_deck_root_out.write('{},{}\n'.format(func_set_id, deck_root))


    # Write the func set IDs and their corresponding functions to file.
    # We sort by func-set-id (so we read it directly in order into a buffer later
    # and use the index for the ID).
    # Even though the func set ID should be equivalent to the index in this loop,
    # we write it to file in case of sanity check later.
    fp_func_set_ids.write('predicted_func_set_id,called_func_id1,called_func_id2,...\n')
    for func_set_id, called_funcs in sorted(func_set_id_to_funcs.items()):
        fp_func_set_ids.write('{},{}\n'.format(func_set_id, called_funcs))

    fp_train_out.close()
    fp_func_set_ids.close()
    fp_deck_root_out.close()


def read_static_reachability():
    with open(BASE_PATH + 'artd_static_reachability.txt') as f:
        for line in f:
            line = line.strip()
            line_vec = line.split()
            root_func_id = line_vec[0]
            static_reachability[root_func_id] = set()
            if len(line_vec) > 1:
                assert len(line_vec) == 2
                func_ids = line_vec[1].split(',')
                for fid in func_ids:
                    if fid != "":
                        static_reachability[root_func_id].add(fid)


def read_loop_static_reachability():
    with open(BASE_PATH + 'artd_loop_static_reachability.txt') as f:
        for line in f:
            line = line.strip()
            line_vec = line.split()
            loop_id = line_vec[0]
            loop_static_reachability[loop_id] = set()
            if len(line_vec) > 1:
                assert len(line_vec) == 2
                func_ids = line_vec[1].split(',')
                for fid in func_ids:
                    if fid != "":
                        loop_static_reachability[loop_id].add(fid)


def main():
    process_profile_log()
    ensure_pred_sets_are_within_deck()
    write_output()


if __name__ == '__main__':
    main()
