#!/usr/bin/env python3
import sys




called_funcs_to_id = {}
called_funcs_counter = 1 # the 0th count is for predicting no future calls
callstack = []



class FCF:
    def __init__(self, func_id, call_set, features):
        self.func_id = func_id
        self.call_set = call_set
        self.features = features




def get_unique_call_set_id(called_funcs_vec):
    global called_funcs_to_id
    global called_funcs_counter
    called_funcs = ''

    # Case: the function called no other functions
    if len(called_funcs_vec) == 0:
        return 0

    for func_id in sorted(called_funcs_vec):
        called_funcs += func_id + ','

    if called_funcs not in called_funcs_to_id:
        called_funcs_to_id[called_funcs] = called_funcs_counter
        called_funcs_counter += 1

    return called_funcs_to_id[called_funcs]





def post_process(input_filename):
    with open(input_filename) as f:
        i = 1
        for line in f:
            line = line.strip()

            line_vec = line.split(',')
            assert(len(line_vec) == 2)
            #func_id = int(line_vec[1])
            func_id = line_vec[1]

            if '(' == line_vec[0]:

                for fcf in callstack:
                    fcf.call_set.add(func_id)

                callstack.append(FCF(func_id, set(), line_vec[1:]))

            else:
                assert(')' == line_vec[0])
                fcf = callstack.pop()
                assert(fcf.func_id == func_id)
                call_set_id = get_unique_call_set_id(fcf.call_set)
                fp_train_out.write('{},{}\n'.format(call_set_id, ','.join(fcf.features)))

    assert(len(callstack) == 0)




BASE_PATH=''
if len(sys.argv) > 1:
        BASE_PATH = sys.argv[1] + '/'
TRAIN_BASENAME = 'train-cgpprof.out'
TRAIN_CGPPROF_OUTPUT_FILENAME = BASE_PATH + 'final-' + TRAIN_BASENAME
fp_train_out = open(TRAIN_CGPPROF_OUTPUT_FILENAME, 'w')

# XXX using "cgpprof" here and not "debprof". The debrt library reads from
# one or the other, depending on #define CGPPROF in the library code. Not
# elegant and could be better.
FUNC_SET_IDS_FILENAME = BASE_PATH + 'cgpprof-func-set-ids-to-funcs.out'
fp_func_set_ids = open(FUNC_SET_IDS_FILENAME, 'w')


post_process(TRAIN_BASENAME)


# Write the func set IDs and their corresponding functions to file.
# We sort by func-set-id (so we read it directly in order into a buffer later
# and use the index for the ID.
# Even though the func set ID should be equivalent to the index in this loop,
# we write it to file in case of sanity check later.
fp_func_set_ids.write('predicted_func_set_id called_func_id1,called_func_id2,...\n')
for called_funcs, func_set_id in sorted(called_funcs_to_id.items(), key=lambda x: x[1]):
    fp_func_set_ids.write('{} {}\n'.format(func_set_id, called_funcs))

        
fp_train_out.close()
fp_func_set_ids.close()

