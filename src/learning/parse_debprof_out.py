#!/usr/bin/env python3
import sys

#
# The purpose of this script is to massage the output of the debprof library
# during a logging run. The debprof.out file captures the callsite ids,
# the called function ids, and the arguments (and probably other values that
# we will add later). It does not, however, capture the function sets that we
# wish to predict. This script reads the debprof.out file and prefixes each
# line with the function set that we wish to predict. The func set (just
# like the functions) is actually an ID, so this script also outputs an
# extra file (*-func-set-ids-to-funcs.out); it maps the func set ID (which
# we prefixed to each line in debprof.out) to the ids of the functions in that
# set.  As of this writing, there isn't a file that maps the function IDs to
# the names of the functions, which might be useful for human readability and
# debugging.  That would have to be done from the DebloatProfile pass, which
# will probably be done eventually.
#

if len(sys.argv) != 3:
    print('check args. need to supply a filename prefix (train or test) ' \
          'and max-num-args (see debprof_pass_stats.txt)')
    sys.exit(1)

FILENAME_PREFIX = sys.argv[1]
if FILENAME_PREFIX not in {'train', 'test'}:
    print('check args. filename prefix should be train or test')
    sys.exit(1)

MAX_NUM_ARGS = int(sys.argv[2])

DEBPROF_INPUT_FILENAME = FILENAME_PREFIX + '-debprof.out'
DEBPROF_OUTPUT_FILENAME = 'final-' + DEBPROF_INPUT_FILENAME

FUNC_SET_IDS_FILENAME = FILENAME_PREFIX + '-func-set-ids-to-funcs.out'

DEBPROF_COLUMN_HEADERS = ''



PREDICTED_FUNCS_SET_SIZE = 5

# Indices of the fields from the input file.
# These shift up by 1 in our output file.
CALLSITE_ID_IDX    = 0
CALLED_FUNC_ID_IDX = 1

num_primed_lines = 0

curr_line_to_write = ''
line_buf = [None] * PREDICTED_FUNCS_SET_SIZE
buf_idx  = 0

buf_called_func_ids = [''] * PREDICTED_FUNCS_SET_SIZE

# Map a unique string of called func IDs to a unique integer ID
# This integer ID will be the target value of the predictor.
# An example of a string of called func IDs might be something like this:
#  '0.2.4.300'
# Its elements are dot-separated values from buf_called_func_ids, so it can
# have up to PREDICTED_FUNCS_SET_SIZE elements. But it's sorted and does not
# have duplicates. It's dot-separated to ensure uniqueness (e.g. IDs '10'
# and '1' versus just ID '110' should be distinguishable as '1.10' instead of
# '110').
called_funcs_to_id   = {}
called_funcs_counter = 0



def update_line_buf(line):
    global curr_line_to_write
    global line_buf
    global buf_idx 
    global buf_called_func_ids 
    curr_line_to_write = line_buf[buf_idx]
    line_buf[buf_idx] = line
    buf_called_func_ids[buf_idx] = ''
    if line:
        buf_called_func_ids[buf_idx] = line.split(',')[CALLED_FUNC_ID_IDX]
    buf_idx = (buf_idx + 1) % PREDICTED_FUNCS_SET_SIZE


def prime_line_buf(f):
    global num_primed_lines
    global DEBPROF_COLUMN_HEADERS
    DEBPROF_COLUMN_HEADERS = f.readline()
    for i in range(PREDICTED_FUNCS_SET_SIZE):
        line = f.readline().strip()
        if line:
            num_primed_lines += 1
            update_line_buf(line)


def empty_line_buf():
    global curr_line_to_write
    global line_buf
    global buf_idx 
    global buf_called_func_ids 
    global PREDICTED_FUNCS_SET_SIZE

    # Edge case when log is shorter than PREDICTED_FUNCS_SET_SIZE
    if num_primed_lines < PREDICTED_FUNCS_SET_SIZE:
        PREDICTED_FUNCS_SET_SIZE = num_primed_lines
        buf_idx = 0

    for i in range(PREDICTED_FUNCS_SET_SIZE):
        update_line_buf('')
        func_set_id = get_func_set_id()
        # XXX
        # This if-check has the effect of chopping off the last line of the
        # training log. This is not necessarily a bad thing. The last line is
        # the last function that was called. There's no need for a prediction
        # there. Thus, anything can go there. And if it's a function that
        # was already called multiple times, it's better to just train on
        # the other instances that actually led to future calls.
        if func_set_id >= 0:
            num_args = len(curr_line_to_write.split(','))
            columns_to_pad = MAX_NUM_ARGS - num_args
            for i in range(columns_to_pad):
                curr_line_to_write = curr_line_to_write+',0'
            line_to_write = '{},{}\n'.format(func_set_id, curr_line_to_write)
            fp_out.write(line_to_write)




def get_func_set_id():
    global called_funcs_counter
    global called_funcs_to_id
    called_funcs = ''
    tmp = ''
    for func_id in sorted(buf_called_func_ids):
        if func_id and func_id != tmp:
            called_funcs += func_id + ','
            tmp = func_id
    if called_funcs == '':
        return -1
    if called_funcs not in called_funcs_to_id:
        called_funcs_to_id[called_funcs] = called_funcs_counter
        called_funcs_counter += 1
    return called_funcs_to_id[called_funcs]




fp_out = open(DEBPROF_OUTPUT_FILENAME, 'w')
fp_func_set_ids = open(FUNC_SET_IDS_FILENAME, 'w')


print()
print('input log: {}'.format(DEBPROF_INPUT_FILENAME))
print('MAX_NUM_ARGS = {}'.format(MAX_NUM_ARGS))
print('PREDICTED_FUNCS_SET_SIZE = {}'.format(PREDICTED_FUNCS_SET_SIZE))
print()
print('Starting...')


with open(DEBPROF_INPUT_FILENAME) as f:
    prime_line_buf(f)
    fp_out.write('predicted_func_set_id,{}'.format(DEBPROF_COLUMN_HEADERS))
    for line in f:
        line = line.strip()
        update_line_buf(line)
        func_set_id = get_func_set_id()
        num_args = len(curr_line_to_write.split(','))
        columns_to_pad = MAX_NUM_ARGS - num_args
        for i in range(columns_to_pad):
            curr_line_to_write = curr_line_to_write+',0'
        line_to_write = '{},{}\n'.format(func_set_id, curr_line_to_write)
        fp_out.write(line_to_write)
    empty_line_buf()


fp_func_set_ids.write('predicted_func_set_id: called_func_id1,called_func_id2,...\n')
for called_funcs in called_funcs_to_id:
    fp_func_set_ids.write('{}: {}\n'.format(called_funcs_to_id[called_funcs],
                                            called_funcs))
                                            
    
fp_out.close()
fp_func_set_ids.close()

print('...Done')
print()
print('See {} for output log (prefixed predicted-func-set-id on each line, '
      'and uniform column lengths over all rows)'.format(DEBPROF_OUTPUT_FILENAME))
print()
print('See {} for the mapping of each predicted func set ID to the func IDs '
      'within it'.format(FUNC_SET_IDS_FILENAME))
print()
