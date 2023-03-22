#!/usr/bin/env python3
from os.path import isfile
import sys


#
# TODO
# The purpose of this script....
#

funcs_to_func_set_id = {}
func_set_id_to_funcs = {}
func_set_id_counter = 0

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



def get_func_set_id(funcs):
    global func_set_id_counter
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


def process_profile_log(input_filename):
    uniq_func_set_cnt = 0
    samples = []
    samples_shadow = []
    sample_stack = []
    sample_stack_shadow = []
    profile_flag = False
    features = None
    with open(input_filename) as f:
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
                s.func_set_id = get_func_set_id(line_parts.data_part)
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


            #if line_parts.log_type == LogType.PROFILE:
            #    profile_flag = True
            #    features = line_parts.data_part

            #elif profile_flag:
            #    assert line_parts.log_type == LogType.DECKING
            #    assert line_parts.deck_change == DeckChange.GROW
            #    sample = Sample(features=features,
            #                    deck_type=line_parts.deck_type)
            #    # push onto stack
            #    print('push')
            #    sample_stack.append(sample)
            #    profile_flag = False

            #elif line_parts.deck_change == DeckChange.SHRINK:
            #    # ignore single decks (nothing to predict)
            #    if line_parts.deck_type == DeckType.SINGLE:
            #        continue
            #    print('pop')
            #    s = sample_stack.pop()
            #    samples.append(s)


    # FIXME ? I think I blew over some old code that used to precede
    # this block. May be needed for func ID sets, etc.
    # See also the FIXME near the end of this script (where we write this stuff to file)
    #key = ','.join(sorted(recorded_func_ids))
    #if key not in funcs_to_func_set_id:
    #    funcs_to_func_set_id[key] = func_set_id_counter
    #    func_set_id_to_funcs[func_set_id_counter] = key
    #    func_set_id_counter += 1


    print('Finished with len of samples: {}'.format(len(samples)))
    print('Finished with len of sample_stack: {}'.format(len(sample_stack)))

    # Write the samples to file.
    # Also populate a map so we have all unique func-set-id, deck-root pairs
    unique_func_set_id_deck_root_pairs = {}
    fp_train_out.write('func_set_id,feature0,feature1,feature2,feature3,feature4,feature5,feature6,feature7,feature8,feature9\n')
    for sample in samples:
        fp_train_out.write(str(sample) + '\n')

        if sample.func_set_id not in unique_func_set_id_deck_root_pairs:
            unique_func_set_id_deck_root_pairs[sample.func_set_id] = set()
        unique_func_set_id_deck_root_pairs[sample.func_set_id].add(sample.features[0])

    # Write all unique func-set-id, deck-root pairs to file
    fp_deck_root_out.write('func_set_id,deck_root\n')
    for func_set_id in unique_func_set_id_deck_root_pairs:
        for deck_root in unique_func_set_id_deck_root_pairs[func_set_id]:
            fp_deck_root_out.write('{},{}\n'.format(func_set_id, deck_root))





BASE_PATH='./'
if len(sys.argv) > 1:
    BASE_PATH = sys.argv[1] + '/'

# example test:
#BASE_PATH = '/home/rudy/wo/advanced-rtd/whole-program-debloat/test/07_test/'

PROFILE_FILENAME      = BASE_PATH + 'debrt-mapped-rx-pages-artd_profile.out'
TRAIN_FILENAME        = BASE_PATH + 'training-data.out'
FUNC_SET_IDS_FILENAME = BASE_PATH + 'func-set-id-to-funcs.out'
DECK_ROOT_FILENAME    = BASE_PATH + 'func-set-id-deck-root-pairs.out'


if not isfile(PROFILE_FILENAME):
    print('ERROR: Profile filename does not exist ({}).'.format(PROFILE_FILENAME))
    print('Exiting')
    sys.exit(1)

fp_train_out     = open(TRAIN_FILENAME, 'w')
fp_func_set_ids  = open(FUNC_SET_IDS_FILENAME, 'w')
fp_deck_root_out = open(DECK_ROOT_FILENAME, 'w')

process_profile_log(PROFILE_FILENAME)


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
