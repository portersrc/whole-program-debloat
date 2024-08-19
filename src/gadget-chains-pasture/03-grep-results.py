#!/usr/bin/env python3
import os
import sys
import subprocess


if len(sys.argv) == 2:
    benchmarks = [
        sys.argv[1]
    ]
else:
    benchmarks = [
        'decker',
        #'pasture',
    ]


BASE_FOLDER = '/home/rudy/wo/advanced-rtd/whole-program-debloat/src/gadget-chains-pasture'
INPUT_BASE = BASE_FOLDER + '/input'
OUTPUT_BASE = BASE_FOLDER + '/output'
MAPPED_PAGES_FILE_PREFIX = 'debrt-mapped-rx-pages'
VULN_PATH = '/home/rudy/wo/rop-benchmark/binaries/x86/reallife/vuln/debian-10-cloud'




def parse_page_groups_file(benchmark):
    page_group_to_id = {}
    with open('{}/{}/{}_page_groups'.format(OUTPUT_BASE, benchmark, benchmark)) as f:
        for line in f:
            line_vec = line.strip().split(':')
            assert len(line_vec) == 2
            page_group_id = line_vec[0]
            page_group = line_vec[1].strip()
            page_group_to_id[page_group] = page_group_id
    return page_group_to_id


def run_grep(findme, bmark, bmark_suffix):
    cmd = 'grep -q "{}" {}/{}_{}.bin.ropper.output'.format(findme, VULN_PATH, bmark, bmark_suffix)
    #print(cmd)
    rc, _ = subprocess.getstatusoutput(cmd)
    return rc


def has_write_what_where(bmark, bmark_suffix):
    findme = 'Cannot create gadget: writewhatwhere'
    rc = run_grep(findme, bmark, bmark_suffix)
    if rc == 0:
        # grep found the string, meaning the gadget does not exist
        return 0 # false, i.e. does not have the gadget
    return 1


def can_build_syscall_args(bmark, bmark_suffix):
    findme = 'Cannot create chain which fills all registers\|Try permuation 1 / 1'
    rc = run_grep(findme, bmark, bmark_suffix)
    if rc == 0:
        # grep found the string, meaning the gadget does not exist
        return 0 # false, i.e. does not have the gadget
    return 1


def has_syscall(bmark, bmark_suffix):
    findme = 'No syscall gadget found!'
    rc = run_grep(findme, bmark, bmark_suffix)
    if rc == 0:
        # grep found the string, meaning the gadget does not exist
        # now check for the syscall opcode
        findme = 'syscall opcode not found'
        rc = run_grep(findme, bmark, bmark_suffix)
        if rc == 0:
            # grep found the string, meaning the gadget does not exist
            # We've checked for both syscall gadget and opcode, so return 0
            return 0
        else:
            # sycall opcode should exist; double-check that ropper reported it
            findme = 'syscall opcode found'
            rc = run_grep(findme, bmark, bmark_suffix)
            assert rc == 0
            # ... then return 1, meaning has-syscall
            return 1
    else:
        # I have never seen this gadget in our experiments. If this assert ever
        # hits, I'd be curious. The fix would be to probably take a look
        # at the ropper output, figure out if ropper reports 'syscall gadget
        # found' or something similar to the 'syscall opcode found' string
        # like I'm checking for and asserting in the other return 1 case
        # above. And then if that all checks out, remove the assert and
        # return 1, meaning it has the syscall.
        assert rc == 0
        #return 1


def get_pg_result(benchmark, page_group_id):
    www = has_write_what_where(benchmark, 'pg_{}'.format(page_group_id))
    sysargs = can_build_syscall_args(benchmark, 'pg_{}'.format(page_group_id))
    syscall = has_syscall(benchmark, 'pg_{}'.format(page_group_id))
    return (www, sysargs, syscall)


def dump_results(bmarks_results):
    print('bmark write-what-where syscall-args syscall')
    for bmark, bmark_results in bmarks_results:
        www_count = 0
        sysargs_count = 0
        syscall_count = 0
        num_results = len(bmark_results)
        for result in bmark_results:
            www, sysargs, syscall = result
            www_count += www
            sysargs_count += sysargs
            syscall_count += syscall
        #print('num_results: {}'.format(num_results))
        #print('www_count: {}'.format(www_count))
        #print('sysargs_count: {}'.format(sysargs_count))
        #print('syscall_count: {}'.format(syscall_count))
        www_res     = 100.0 * www_count / num_results
        sysargs_res = 100.0 * sysargs_count / num_results
        syscall_res = 100.0 * syscall_count / num_results
        print('{} {} {} {}'.format(bmark, www_res, sysargs_res, syscall_res))


def main():

    bmarks_results = []

    for benchmark in benchmarks:

        print('Processing {}'.format(benchmark))
        bmark_results = []
        page_group_id_to_result = {}

        page_group_to_id = parse_page_groups_file(benchmark)
        rx_pages_files = ['{}/{}/{}'.format(INPUT_BASE, benchmark, x)
                          for x in os.listdir(INPUT_BASE+'/'+benchmark)
                            if x.startswith(MAPPED_PAGES_FILE_PREFIX)]

        for rx_pages_file in rx_pages_files:
            with open(rx_pages_file) as f:
                for line in f:
                    page_indices = line.strip().split()
                    page_indices.sort()
                    page_group = ' '.join(page_indices)
                    page_group_id = page_group_to_id[page_group]
                    if page_group_id in page_group_id_to_result:
                        bmark_results.append(page_group_id_to_result[page_group_id])
                    else:
                        result = get_pg_result(benchmark, page_group_id)
                        bmark_results.append(result)
                        page_group_id_to_result[page_group_id] = result

        # each element of bmarks_results is a tuple: (bmark, bmark_results)
        # bmark is a string.
        # bmark_results is a vector. each element is a tuple of
        #   (www, sysargs, syscall).
        #   If a particular page group had a gadget, e.g. a write-what-where
        #   gadget, then the www value will be 1.
        bmarks_results.append((benchmark, bmark_results))
    dump_results(bmarks_results)




main()
