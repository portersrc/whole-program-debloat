#!/usr/bin/env python3
import sys
from os import listdir
from os.path import isfile, join
import statistics

# FIXME? This option turns out to be stupid? That file that you pass still
# has to start with "out-jop-pg_"
def usage_and_exit():
    print()
    print('Usage:')
    print('  {} [out-jop-pg_* file to parse]'.format(sys.argv[0]))
    print()
    print('If the file to parse is not provided, then the current directory is used.')
    print()
    print('NOTE: only files that begin with "out-jop-pg_" will be parsed')
    print()
    sys.exit(1)


reg_ids = {
    'rax': 0,
    'eax': 0,
    'ax': 0,
    'al': 0,

    'rcx': 1,
    'ecx': 1,
    'cx': 1,
    'cl': 1,

    'rdx': 2,
    'edx': 2,
    'dx': 2,
    'dl': 2,

    'rbx': 3,
    'ebx': 3,
    'bx': 3,
    'bl': 3,

    'rsi': 4,
    'esi': 4,
    'si': 4,
    'sil': 4,

    'rdi': 5,
    'edi': 5,
    'di': 5,
    'dil': 5,

    'rsp': 6,
    'esp': 6,
    'sp': 6,
    'spl': 6,

    'rbp': 7,
    'ebp': 7,
    'bp': 7,
    'bpl': 7,

    'r8': 8,
    'r8d': 8,
    'r8w': 8,
    'r8b': 8,

    'r9': 9,
    'r9d': 9,
    'r9w': 9,
    'r9b': 9,

    'r10': 10,
    'r10d': 10,
    'r10w': 10,
    'r10b': 10,

    'r11': 11,
    'r11d': 11,
    'r11w': 11,
    'r11b': 11,

    'r12': 12,
    'r12d': 12,
    'r12w': 12,
    'r12b': 12,

    'r13': 13,
    'r13d': 13,
    'r13w': 13,
    'r13b': 13,

    'r14': 14,
    'r14d': 14,
    'r14w': 14,
    'r14b': 14,

    'r15': 15,
    'r15d': 15,
    'r15w': 15,
    'r15b': 15,
}
regs = set()
for r in reg_ids:
    regs.add(r)


class Gadget:
    
    def __init__(self, insts, first_op, depth, regs_in_use):
        self.insts = insts
        self.first_op = first_op
        self.depth = depth
        self.is_dg = False
        self.dg_regs = None
        self.dg_reg_ids = None
        self.regs_in_use = regs_in_use
        if self.depth == 1 and first_op == 'add':
            first_inst = self.insts[0].strip()
            first_inst_vec = first_inst.split()
            if len(first_inst_vec) == 3:
                reg0 = first_inst_vec[1][:-1] # remove comma
                reg1 = first_inst_vec[2]
                if reg0 in regs and reg1 in regs:
                    # TODO need to check that 
                    jmp_inst = self.insts[1].strip()
                    jmp_inst_vec = jmp_inst.split()
                    assert jmp_inst_vec[0] == 'jmp'
                    jmp_reg = jmp_inst_vec[1]
                    if reg0 == jmp_reg:
                        self.is_dg = True
                        self.dg_regs = {reg0, reg1}
                        self.dg_reg_ids = {reg_ids[reg0], reg_ids[reg1]}

    def __str__(self):
        s = '{}\n'.format(self.insts)
        s += '  first_op: {}\n'.format(self.first_op)
        s += '  depth: {}\n'.format(self.depth)
        s += '  regs_in_use: {}\n'.format(self.regs_in_use)
        s += '  is_dg: {}\n'.format(self.is_dg)
        s += '  dg_regs: {}\n'.format(self.dg_regs)
        s += '  dg_reg_ids: {}\n'.format(self.dg_reg_ids)
        return s





def dump_metric(metric, arr):
    print('{}'.format(metric))
    print('min: {}'.format(min(arr)))
    print('max: {}'.format(max(arr)))
    print('avg: {}'.format(statistics.mean(arr)))
    print('stdev: {}'.format(statistics.stdev(arr)))
    print()



path = '.'
all_jop_files = [f for f in listdir(path) if isfile(join(path, f))]
if len(sys.argv) == 2:
    all_jop_files = [sys.argv[1]]
if len(sys.argv) > 2:
    usage_and_exit()



all_num_gadgets = []
all_num_dispatcher_gadgets = []
all_num_uniq_first_ops = []
all_usable_counts = []
all_not_usable_counts = []
all_uniq_first_op_usable_size_counts = []


final_avg_num_gadgets = []
jop_files_with_max_usable_first_op = set()

at_least_one_file_was_parsed = False
for jop_file in all_jop_files:
    if not jop_file.startswith('out-jop-pg_'):
        continue
    at_least_one_file_was_parsed = True
    print(jop_file)
    gadgets = []
    dispatcher_gadgets = []
    dispatcher_gadgets_set = set() # track unique strings. has no effect, possibly because ropgadget already filters those out.
    non_dispatcher_gadgets = []
    uniq_first_ops = set()
    with open(jop_file) as f:
        for line in f:
            line = line.strip()
            line_vec = line.split(':')
            gadget = line_vec[1]
            gadget_vec = gadget.split(';')
            if len(gadget_vec) == 1:
                continue

            regs_in_use = set()
            for idx, inst in enumerate(gadget_vec):
                inst = inst.strip()
                inst_vec = inst.split()
                if idx == 0:
                    first_op = inst_vec[0]
                for part in inst_vec[1:]:
                    if part[-1] == ',':
                        part = part[:-1]
                    if part[-1] == ']':
                        part = part[1:-1]
                    if part in regs:
                        regs_in_use.add(part)

            g = Gadget(gadget_vec, first_op, len(gadget_vec)-1, regs_in_use)
            if g.is_dg and gadget not in dispatcher_gadgets_set:
                dispatcher_gadgets.append(g)
                dispatcher_gadgets_set.add(gadget)
            else:
                non_dispatcher_gadgets.append(g)
                uniq_first_ops.add(g.first_op)
            gadgets.append(g)

    dg_to_usability = {}
    for dg in dispatcher_gadgets:
        dg_to_usability[dg] = {
            'usable': 0,
            'not_usable': 0,
            'uniq_first_op_usable': set(),
            'uniq_first_op_usable_size': 0,
        }
        assert dg.is_dg
        #print('working on dispatcher gadget: {}'.format(dg))
        for g in non_dispatcher_gadgets:
            usable = True
            for r in g.regs_in_use:
                reg_id = reg_ids[r]
                if reg_id in dg.dg_reg_ids:
                    usable = False
                    break
            if usable:
                #print('gadget is usable: {}'.format(g))
                dg_to_usability[dg]['usable'] += 1
                dg_to_usability[dg]['uniq_first_op_usable'].add(g.first_op)
                dg_to_usability[dg]['uniq_first_op_usable_size'] = len(dg_to_usability[dg]['uniq_first_op_usable'])
                # hard-coding this after already running the results and seeing
                # 23. I want to use this for analysis in the writing.
                if len(dg_to_usability[dg]['uniq_first_op_usable']) == 23:
                    jop_files_with_max_usable_first_op.add(jop_file)
            else:
                #print('gadget not usable: {}'.format(g))
                dg_to_usability[dg]['not_usable'] += 1

        #print()
        #print()
        #print()

    #for key, val in dg_to_usability.items():
    #    print(key)
    #    print(val)
    #    print()

    usable_counts = []
    not_usable_counts = []
    uniq_first_op_usable_size_counts = []
    for dg in dispatcher_gadgets:
        usable_counts.append(dg_to_usability[dg]['usable'])
        not_usable_counts.append(dg_to_usability[dg]['not_usable'])
        uniq_first_op_usable_size_counts.append(dg_to_usability[dg]['uniq_first_op_usable_size'])


    # dump gadgets
    #for g in gadgets:
    #    print(g)


    num_gadgets = len(gadgets)
    num_dispatcher_gadgets = len(dispatcher_gadgets)
    num_uniq_first_ops = len(uniq_first_ops)
    avg_usable_counts = statistics.mean(usable_counts)
    avg_not_usable_counts = statistics.mean(not_usable_counts)
    avg_uniq_first_op_usable_size_counts = statistics.mean(uniq_first_op_usable_size_counts)


    print('num_gadgets: {}'.format(num_gadgets))
    print('num_dispatcher_gadgets: {}'.format(num_dispatcher_gadgets))
    print('num_uniq_first_ops: {}'.format(num_uniq_first_ops))
    print('avg_usable_counts: {}'.format(avg_usable_counts))
    print('avg_not_usable_counts: {}'.format(avg_not_usable_counts))
    print('avg_uniq_first_opt_usable_size_counts: {}'.format(avg_uniq_first_op_usable_size_counts))
    print()

    # For a given jop file, these are just scalars (num_gadgets, num_uniq_first_ops)
    all_num_gadgets.append(num_gadgets)
    all_num_dispatcher_gadgets.append(num_dispatcher_gadgets)
    all_num_uniq_first_ops.append(num_uniq_first_ops)

    # For a given jop file, these are arrays (usable_counts, not_usable_counts,
    # uniq_first_op_usable_size_counts) because each dispatch gadget produces
    # some scalar value. We'll be calculating min/max/avg over them so we'll
    # just create one massive array of them.
    all_usable_counts.extend(usable_counts)
    all_not_usable_counts.extend(not_usable_counts)
    all_uniq_first_op_usable_size_counts.extend(uniq_first_op_usable_size_counts)



if not at_least_one_file_was_parsed:
    print()
    print('ERROR: No files were processed. Maybe check your args or the filenames begin with out-jop-pg_?')
    print('Dumping usage and then exiting')
    print()
    usage_and_exit()


dump_metric('all_num_gadgets', all_num_gadgets)
dump_metric('all_num_dispatcher_gadgets', all_num_dispatcher_gadgets)
dump_metric('all_num_uniq_first_ops', all_num_uniq_first_ops)
dump_metric('all_usable_counts', all_usable_counts)
dump_metric('all_not_usable_counts', all_not_usable_counts)
dump_metric('all_uniq_first_op_usable_size_counts', all_uniq_first_op_usable_size_counts)


print('jop_files_with_max_usable_first_op: {}'.format(jop_files_with_max_usable_first_op))
