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

BASE_PATH=''
if len(sys.argv) == 2:
    BASE_PATH = sys.argv[1] + '/'
if len(sys.argv) > 2:
    print('Unexpected command-line args. FIXME usage (pass input path or nothing (to use curdir)')


TRAIN_BASENAME = 'train-debprof.out'
TEST_BASENAME  = 'test-debprof.out'
TRAIN_DEBPROF_INPUT_FILENAME  = BASE_PATH + TRAIN_BASENAME
TEST_DEBPROF_INPUT_FILENAME   = BASE_PATH + TEST_BASENAME
TRAIN_DEBPROF_OUTPUT_FILENAME = BASE_PATH + 'final-' + TRAIN_BASENAME
TEST_DEBPROF_OUTPUT_FILENAME  = BASE_PATH + 'final-' + TEST_BASENAME

FUNC_SET_IDS_FILENAME = BASE_PATH + 'debprof-func-set-ids-to-funcs.out'

DEBPROF_COLUMN_HEADERS = ''



PREDICTED_FUNCS_SET_SIZE = 5

max_final_columns = 0


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


def count_max_columns(filename):
    print('Checking {} for max columns'.format(filename))
    max_cols = 0
    with open(filename) as f:
        _ = f.readline() # skip column headers
        for line in f:
            c = line.count(',') + 1 # 1 comma -> 2 cols. 2 commas -> 3 cols, etc
            if c > max_cols:
                max_cols = c
    return max_cols




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


def get_num_columns_to_pad():
    # Each line is comma-separated, and there's no trailing comma at the end
    # of the line. So the number of columns is count(',') + 1
    num_args = curr_line_to_write.count(',') + 1
    return max_final_columns - num_args


def empty_line_buf(fp_out):
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
            for i in range(get_num_columns_to_pad()):
                curr_line_to_write = curr_line_to_write+',0'
            line_to_write = '{},{}\n'.format(func_set_id, curr_line_to_write)
            fp_out.write(line_to_write)


def post_process(input_filename, fp_out):
    global curr_line_to_write
    with open(input_filename) as f:
        prime_line_buf(f)
        fp_out.write('predicted_func_set_id,{}'.format(DEBPROF_COLUMN_HEADERS))
        for line in f:
            line = line.strip()
            update_line_buf(line)
            func_set_id = get_func_set_id()
            for i in range(get_num_columns_to_pad()):
                curr_line_to_write = curr_line_to_write+',0'
            line_to_write = '{},{}\n'.format(func_set_id, curr_line_to_write)
            fp_out.write(line_to_write)
        empty_line_buf(fp_out)


def get_max_final_columns():
    a = count_max_columns(TRAIN_DEBPROF_INPUT_FILENAME)
    b = count_max_columns(TEST_DEBPROF_INPUT_FILENAME)
    # final-*-debprof.out will have a prefixed target value on each row,
    # so it will have 1 more column than the max of the train and test runs.
    return max(a, b) + 1

max_final_columns = get_max_final_columns()

fp_train_out = open(TRAIN_DEBPROF_OUTPUT_FILENAME, 'w')
fp_test_out  = open(TEST_DEBPROF_OUTPUT_FILENAME, 'w')
fp_func_set_ids = open(FUNC_SET_IDS_FILENAME, 'w')


print()
print('input logs:')
print('  {}'.format(TRAIN_DEBPROF_INPUT_FILENAME))
print('  {}'.format(TEST_DEBPROF_INPUT_FILENAME))
print('max_final_columns = {}'.format(max_final_columns))
print('PREDICTED_FUNCS_SET_SIZE = {}'.format(PREDICTED_FUNCS_SET_SIZE))
print()
print('Starting...')


post_process(TRAIN_DEBPROF_INPUT_FILENAME, fp_train_out)
post_process(TEST_DEBPROF_INPUT_FILENAME, fp_test_out)


fp_func_set_ids.write('predicted_func_set_id called_func_id1,called_func_id2,...\n')
for called_funcs in called_funcs_to_id:
    fp_func_set_ids.write('{} {}\n'.format(called_funcs_to_id[called_funcs],
                                            called_funcs))
                                            
    
fp_train_out.close()
fp_test_out.close()
fp_func_set_ids.close()

print('...Done')
print()
print('See {} and {} for output log (prefixed predicted-func-set-id on each line, '
      'and uniform column lengths over all rows)'.format(TRAIN_DEBPROF_OUTPUT_FILENAME, TEST_DEBPROF_OUTPUT_FILENAME))
print()
print('See {} for the mapping of each predicted func set ID to the func IDs '
      'within it'.format(FUNC_SET_IDS_FILENAME))
print()
