#!/usr/bin/env python3

import sys
import json
from os import listdir
from os.path import exists

from jrp_aux import (gadget_types, gt_to_gf_arr, jop_metrics, jop_depth_metric,
                     gt_to_parser, finalize_metrics, reset_jop_metrics,
                     esp_stack_pivot_gadget_files)


# Should be exactly the number of files.
# IDs start at 0, so this is also equal to max ID - 1
#NUM_PG_FILES = 142
NUM_PG_FILES = 119



# Debug
meta_files_processed = set()



def usage_and_exit():
    print()
    print('Usage:')
    print('  {} <which_jop_rocket_output>'.format(sys.argv[0]))
    print()
    print('  --where <which_jop_rocket_output> is one of:')
    print('    {test, nginx_baseline, nginx_wpd_ics, nginx_pg}') 
    print()
    print('  Details:')
    print('    test - a hashcracker challenge test example')
    print('    nginx_baseline - the JOP Rocket output for the nginx_baseline binary')
    print('    nginx_wpd_ics - the JOP Rocket output for the nginx_wpd_ics binary')
    print('    nginx_pg - the JOP Rocket output for ALL the page group (pg) binaries based runtime logs of the nginx_wpd_ics binary')
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





def update_jop_depth_metric(gadget):
    if len(gadget.insts) > ( len(jop_depth_metric) - 1 ):
        print('Unexpected: gadget.insts > {}. Exiting...'.format( (len(jop_depth_metric) - 1) ) )
        print('{}'.format(gadget))
        sys.exit(1)
    jop_depth_metric[len(gadget.insts)] += 1

def add_new_gadget(gadgets, gadget):
    gadget.finalize()
    if gadget.is_valid():
        gadgets.append(gadget)
        update_jop_depth_metric(gadget)


def parse_gadgets(gf, gadgets, gadget_type, lines):
    len_gadgets_before = len(gadgets)
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
    if gf in esp_stack_pivot_gadget_files:
        jop_metrics['num_stack_pivot_gadgets'] += 1


def read_gadget_file(filename):
    #print('Reading gadget file: {}'.format(filename))
    with open(filename) as f:
        lines = f.readlines()
    return lines


def dump_metrics(metrics):
    for key in sorted(metrics):
        print('{} {}'.format(key, metrics[key]))
    print('jop_depth_metric:')
    for i, d in enumerate(jop_depth_metric):
        print('{} {}'.format(i, d))


def write_metrics(output_file):
    jop_metrics['depth'] = jop_depth_metric
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
            parse_gadgets(gf, gadgets, gt, lines)

    jop_metrics['num_uniq_gadgets'] = len(gadgets)

    finalize_metrics()
    dump_metrics(jop_metrics)


def dump_debug():
    for filename in sorted(meta_files_processed):
        print(filename)


# This is a hack to figure out what gadget types im missing
def hack_parse_nginx_single_bin(bin_name):
    gadget_files_path = 'C:/Users/rudy/h/wo/decker/JOP_ROCKET/' + bin_name
    base_filename = bin_name + '_'
    raw_filenames = listdir(gadget_files_path)
    gadget_files = set([gf.replace(base_filename, '') for gf in raw_filenames])

    #print(len(gadget_files))

    gadget_type_not_in_folder = set()

    # for each group of gadget files
    for gt in gadget_types:
        gf_arr = gt_to_gf_arr[gt]
        # for each gadget file in that group
        for gf in gf_arr:
            if gf in gadget_files:
                gadget_files.remove(gf)
            else:
                gadget_type_not_in_folder.add(gf)
    
    #print('gadget type not in folder: {}'.format(gadget_type_not_in_folder))
    #print('gadget type in folder (but not in jrp-aux): {}'.format(gadget_files))
    #print('len of gadget type not in folder: {}'.format(len(gadget_type_not_in_folder)))
    #print('len of gadget type in folder (but not in jrp-aux): {}'.format(len(gadget_files)))

    # print the gadget files that are in the folder but not captured by jrp-aux
    for gf in sorted(gadget_files):
        print(gf)
    


def parse_nginx_single_bin(bin_name):
    gadget_files_path = 'C:/Users/rudy/h/wo/decker/JOP_ROCKET/' + bin_name
    base_filename = bin_name + '_'
    gadgets = []
    
    # for each group of gadget files
    for gt in gadget_types:
        gf_arr = gt_to_gf_arr[gt]
        # for each gadget file in that group
        for gf in gf_arr:
            #print(gf)
            filename = gadget_files_path + '/' + base_filename + gf
            #filename_no_path = base_filename + gf
            if exists(filename):
                lines = read_gadget_file(filename)
                parse_gadgets(gf, gadgets, gt, lines)
                jop_metrics['meta_num_files_processed'] += 1
                meta_files_processed.add(gf)
            else:
                # TODO: look at these cases
                # same for parse_nginx()
                pass

    jop_metrics['num_uniq_gadgets'] = len(gadgets)

    finalize_metrics()
    dump_metrics(jop_metrics)
    #dump_debug()


# This is a bigger hack to figure out what gadget types im missing.
# it's same hack as before but for handling one pg file
def pg_hack_parse_nginx_single_bin(bin_name):
    gadget_files_path = 'C:/Users/rudy/h/wo/decker/JOP_ROCKET/' + bin_name
    base_filename = bin_name + '_'
    raw_filenames = listdir(gadget_files_path)
    gadget_files = set([gf.replace(base_filename, '') for gf in raw_filenames])

    gadget_type_not_in_folder = set()

    # for each group of gadget files
    for gt in gadget_types:
        gf_arr = gt_to_gf_arr[gt]
        # for each gadget file in that group
        for gf in gf_arr:
            if gf in gadget_files:
                gadget_files.remove(gf)
            else:
                gadget_type_not_in_folder.add(gf)

    # return the gadget files that are in the folder but not captured by jrp-aux
    return gadget_files


def hack_parse_nginx():
    pg_gadget_files = set()

    for x in range(NUM_PG_FILES):
        bin_filename = 'nginx_pg_{}'.format(x)
        gadget_files = pg_hack_parse_nginx_single_bin(bin_filename)
        pg_gadget_files |= gadget_files

    for pg_gf in sorted(pg_gadget_files):
        #if 'MITIGATIONS' not in pg_gf:
        #    print(pg_gf)
        print(pg_gf)


def parse_nginx():
    
    OUTPUT_FOLDER = 'nginx-parsed-metrics-output'
    pg_files_base_path = 'C:/Users/rudy/h/wo/decker/JOP_ROCKET'
    pg_folder_prefix = 'nginx_pg'

    for x in range(NUM_PG_FILES):

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
                    parse_gadgets(gf, gadgets, gt, lines)
                    jop_metrics['meta_num_files_processed'] += 1
                else:
                    # TODO: Look into these cases
                    # current gadget-types, etc. are based on hashcracker test
                    pass

        jop_metrics['num_uniq_gadgets'] = len(gadgets)

        finalize_metrics()
        #dump_metrics(jop_metrics)
        output_filename = OUTPUT_FOLDER + '/' + base_filename + 'metrics.json'
        write_metrics(output_filename)

        # debug...
        #if jop_metrics['num_uniq_dec_ops'] == 72:
        #    print('hit for page group: {}'.format(x))

        reset_jop_metrics()


def main():
    if len(sys.argv) != 2:
        usage_and_exit()
    if sys.argv[1] not in {'test', 'nginx_baseline', 'nginx_wpd_ics', 'nginx_pg'}:
        usage_and_exit()

    if sys.argv[1] == 'test':
        parse_test()
    elif sys.argv[1] == 'nginx_baseline':
        parse_nginx_single_bin('nginx_baseline_ls')
    elif sys.argv[1] == 'nginx_wpd_ics':
        parse_nginx_single_bin('nginx_wpd_ics')
    else:
        assert sys.argv[1] == 'nginx_pg'
        parse_nginx()


main()