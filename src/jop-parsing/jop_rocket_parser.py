#!/usr/bin/env python3

import sys
import json
from os.path import exists

from jrp_aux import (gadget_types, gt_to_gf_arr, jop_metrics,
                     gt_to_parser, finalize_metrics, reset_jop_metrics)



def usage_and_exit():
    print()
    print('Usage:')
    print('  {} <test-or-nginx-or-nginx_baseline>'.format(sys.argv[0]))
    print()
    sys.exit(1)



GADGET_DELIMITER = '*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^'




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





def add_new_gadget(gadgets, gadget):
    gadget.finalize()
    if gadget.is_valid():
        gadgets.append(gadget)


def parse_gadgets(gadgets, gadget_type, lines):
    gadget = Gadget(gadget_type)
    for line in lines:
        line = line.strip()
        if line == '':
            continue
        if line == GADGET_DELIMITER:
            add_new_gadget(gadgets, gadget)
            gadget = Gadget(gadget_type)
        else:
            gadget.lines.append(line)
    add_new_gadget(gadgets, gadget)


def read_gadget_file(filename):
    #print('Reading gadget file: {}'.format(filename))
    with open(filename) as f:
        lines = f.readlines()
    return lines


def dump_metrics(metrics):
    for key in sorted(metrics):
        print('{} {}'.format(key, metrics[key]))


def write_metrics(output_file):
    with open(output_file, 'w') as f:
        json.dump(jop_metrics, f)


def parse_test():
    gadget_files_path = 'C:\\Users\\rudy\\h\\wo\\decker\\whole-program-debloat\\src\\jop-parsing\\hashCracker_challenge-test'
    base_filename = 'hashcracker_challenge_'
    gadgets = []
    
    # for each group of gadget files
    for gt in gadget_types:
        gf_arr = gt_to_gf_arr[gt]
        # for each gadget file in that group
        for gf in gf_arr:
            filename = gadget_files_path + '\\' + base_filename + gf
            lines = read_gadget_file(filename)
            parse_gadgets(gadgets, gt, lines)

    jop_metrics['num_uniq_gadgets'] = len(gadgets)

    #print('number of gadgets: {}'.format(len(gadgets)))
    #for gadget in gadgets:
    #    print(gadget)
    #    print()
    #    #for line in gadget.lines:
    #    #    print(line)
    #    #print()

    finalize_metrics()
    dump_metrics(jop_metrics)


def parse_nginx_baseline():
    gadget_files_path = 'C:/Users/rudy/h/wo/decker/JOP_ROCKET/nginx_baseline_ls'
    base_filename = 'nginx_baseline_ls_'
    gadgets = []
    
    # for each group of gadget files
    for gt in gadget_types:
        gf_arr = gt_to_gf_arr[gt]
        # for each gadget file in that group
        for gf in gf_arr:
            filename = gadget_files_path + '/' + base_filename + gf
            if exists(filename):
                lines = read_gadget_file(filename)
                parse_gadgets(gadgets, gt, lines)
            else:
                # TODO: look at these cases
                # same for parse_nginx()
                pass

    jop_metrics['num_uniq_gadgets'] = len(gadgets)

    finalize_metrics()
    dump_metrics(jop_metrics)


def parse_nginx():
    
    OUTPUT_FOLDER = 'nginx-parsed-metrics-output'
    pg_files_base_path = 'C:/Users/rudy/h/wo/decker/JOP_ROCKET'
    pg_folder_prefix = 'nginx_pg'

    for x in range(142):

        gadget_files_path = '{}/{}_{}'.format(pg_files_base_path, pg_folder_prefix, x)
        base_filename = 'nginx_pg_{}_'.format(x)
        #print('{}/{}'.format(gadget_files_path, base_filename))
        gadgets = []

        print('Parsing metrics for nginx page group {}'.format(x))

        # for each group of gadget files
        for gt in gadget_types:
            gf_arr = gt_to_gf_arr[gt]
            # for each gadget file in that group
            for gf in gf_arr:
                filename = gadget_files_path + '/' + base_filename + gf
                if exists(filename):
                    lines = read_gadget_file(filename)
                    parse_gadgets(gadgets, gt, lines)
                else:
                    # TODO: Look into these cases
                    # current gadget-types, etc. are based on hashcracker test
                    pass

        jop_metrics['num_uniq_gadgets'] = len(gadgets)

        finalize_metrics()
        #dump_metrics(jop_metrics)
        output_filename = OUTPUT_FOLDER + '/' + base_filename + 'metrics.json'
        write_metrics(output_filename)
        reset_jop_metrics()


def main():
    if len(sys.argv) != 2:
        usage_and_exit()
    if sys.argv[1] not in {'test', 'nginx', 'nginx_baseline'}:
        usage_and_exit()

    if sys.argv[1] == 'test':
        parse_test()
    elif sys.argv[1] == 'nginx_baseline':
        parse_nginx_baseline()
    else:
        assert sys.argv[1] == 'nginx'
        parse_nginx()


main()