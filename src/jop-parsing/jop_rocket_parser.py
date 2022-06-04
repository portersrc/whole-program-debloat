#!/usr/bin/env python3

from jrp_aux import (gadget_types, gt_to_gf_arr, jop_metrics,
                    gt_to_parser, finalize_metrics)





GADGET_DELIMITER = '*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^'

gadget_files_path = 'C:\\Users\\rudy\\h\\wo\\decker\\whole-program-debloat\\src\\jop-parsing\\hashCracker_challenge-test'
base_filename = 'hashcracker_challenge_'
gadgets = []



class Gadget:
    def __init__(self, gadget_type):
        self.type = gadget_type
        self.lines = []
        self.insts = []
        self.header = ''
    
    def __str__(self):
        return 'num_insts: {}'.format(len(self.insts))

    def finalize(self):
        if len(self.lines) >= 2:
            self.header = self.lines[0]
            self.insts = self.lines[1:]
            gt_to_parser[self.type](self.insts)
            if len(self.insts) == 2:
                jop_metrics['num_len_two_gadgets'] += 1

    def is_valid(self):
        return len(self.insts) > 0 \
           and len(self.header) > 0 \
           and self.header[0] == '#'





def add_new_gadget(gadget):
    global gadgets
    gadget.finalize()
    if gadget.is_valid():
        gadgets.append(gadget)


def parse_gadgets(gadget_type, lines):
    gadget = Gadget(gadget_type)
    for line in lines:
        line = line.strip()
        if line == '':
            continue
        if line == GADGET_DELIMITER:
            add_new_gadget(gadget)
            gadget = Gadget(gadget_type)
        else:
            gadget.lines.append(line)
    add_new_gadget(gadget)


def read_gadget_file(filename):
    #print('Reading gadget file: {}'.format(filename))
    with open(filename) as f:
        lines = f.readlines()
    return lines


def dump_metrics():
    for key, val in jop_metrics.items():
        print('{} {}'.format(key, val))



def main():
    
    # for each group of gadget files
    for gt in gadget_types:
        gf_arr = gt_to_gf_arr[gt]
        # for each gadget file in that group
        for gf in gf_arr:
            filename = gadget_files_path + '\\' + base_filename + gf
            lines = read_gadget_file(filename)
            parse_gadgets(gt, lines)

    jop_metrics['num_uniq_gadgets'] = len(gadgets)

    #print('number of gadgets: {}'.format(len(gadgets)))
    #for gadget in gadgets:
    #    print(gadget)
    #    print()
    #    #for line in gadget.lines:
    #    #    print(line)
    #    #print()


    finalize_metrics()
    dump_metrics()


main()