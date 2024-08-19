#!/usr/bin/env python3
import os
import sys
import subprocess


if len(sys.argv) == 2:
    benchmarks = [
        sys.argv[1]
    ]
else:
    benchmarks_coreutils = [
        'bzip2',
        'chown',
        'date',
        'grep',
        'gzip',
        'mkdir',
        'rm',
        'sort',
        'tar',
        'uniq',
    ]
    benchmarks_spec = [
        #'500.perlbench',
        '502.gcc',
        #'505.mcf',
        #'508.namd',
        #'510.parest',
        #'511.povray',
        #'519.lbm',
        #'520.omnetpp',
        #'523.xalancbmk',
        #'525.x264',
        ##'526.blender',
        #'531.deepsjeng',
        #'538.imagick',
        #'541.leela',
        #'544.nab',
        #'557.xz',
    ]
    benchmarks_nginx = [
        'nginx',
    ]


BASE_FOLDER = '/home/rudy/wo/whole-program-debloat/src/gadget-chains'
INPUT_BASE = BASE_FOLDER + '/input'
OUTPUT_BASE = BASE_FOLDER + '/output'
MAPPED_PAGES_FILE_PREFIX = 'debrt-mapped-rx-pages'
VULN_PATH = '/home/rudy/wo/rop-benchmark/binaries/x86/reallife/vuln/debian-10-cloud'

BMARKS_TO_VEC = {
    'coreutils': benchmarks_coreutils,
    'spec': benchmarks_spec,
    'nginx': benchmarks_nginx,
}
BMARKS_TO_INPUT_PATH = {
    'coreutils': INPUT_BASE + '/coreutils',
    'spec': INPUT_BASE + '/spec',
    'nginx': INPUT_BASE + '/nginx',
}
BMARKS_TO_OUTPUT_PATH = {
    'coreutils': OUTPUT_BASE + '/coreutils',
    'spec': OUTPUT_BASE + '/spec',
    'nginx': OUTPUT_BASE + '/nginx',
}
BMARKS_TO_BASELINE_SUFFIX = {
    'coreutils': 'nostatic_onlytext',
    'spec': 'r_baseline_ls_onlytext',
    'nginx': 'baseline_ls_onlytext',
}







def parse_page_groups_file(benchmark, output_path):
    page_group_to_id = {}
    with open('{}/{}/{}_page_groups'.format(output_path, benchmark, benchmark)) as f:
        for line in f:
            line_vec = line.strip().split(':')
            assert len(line_vec) == 2
            page_group_id = line_vec[0]
            page_group = line_vec[1].strip()
            page_group_to_id[page_group] = page_group_id
    return page_group_to_id




def run_grep(findme, bmark, bmark_suffix):
    cmd = 'grep -q "{}" {}/{}_{}.bin.ropper.output'.format(findme, VULN_PATH, bmark, bmark_suffix)
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


def get_baseline_results(which_bmarks):
    bmarks_vec = BMARKS_TO_VEC[which_bmarks]
    bmarks_suffix = BMARKS_TO_BASELINE_SUFFIX[which_bmarks]
    print('bmark write-what-where syscall-args syscall')
    for b in bmarks_vec:
        www = has_write_what_where(b, bmarks_suffix)
        sysargs = can_build_syscall_args(b, bmarks_suffix)
        syscall = has_syscall(b, bmarks_suffix)
        print('{} {} {} {}'.format(b, www*100, sysargs*100, syscall*100))


def get_wpd_pg_result(benchmark, page_group_id):
    www = has_write_what_where(benchmark, 'pg_{}'.format(page_group_id))
    sysargs = can_build_syscall_args(benchmark, 'pg_{}'.format(page_group_id))
    syscall = has_syscall(benchmark, 'pg_{}'.format(page_group_id))
    return (www, sysargs, syscall)


def dump_wpd_results(bmarks_results):
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


def get_wpd_results(which_bmarks):

    bmarks_results = []
    bmarks_vec = BMARKS_TO_VEC[which_bmarks]
    input_path = BMARKS_TO_INPUT_PATH[which_bmarks]
    output_path = BMARKS_TO_OUTPUT_PATH[which_bmarks]
    for benchmark in bmarks_vec:

        print('Processing {}'.format(benchmark))
        bmark_results = []
        page_group_id_to_result = {}

        page_group_to_id = parse_page_groups_file(benchmark, output_path)
        rx_pages_files = ['{}/{}/{}'.format(input_path, benchmark, x)
                          for x in os.listdir(input_path+'/'+benchmark)
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
                        result = get_wpd_pg_result(benchmark, page_group_id)
                        bmark_results.append(result)
                        page_group_id_to_result[page_group_id] = result

        # each element of bmarks_results is a tuple: (bmark, bmark_results)
        # bmark is a string.
        # bmark_results is a vector. each element is a tuple of
        #   (www, sysargs, syscall).
        #   If a particular page group had a gadget, e.g. a write-what-where
        #   gadget, then the www value will be 1.
        bmarks_results.append((benchmark, bmark_results))
    dump_wpd_results(bmarks_results)



def main():
    #get_baseline_results('coreutils')
    #get_wpd_results('coreutils')
    #get_baseline_results('spec')
    get_wpd_results('spec')
    #get_baseline_results('nginx')
    #get_wpd_results('nginx')


main()
