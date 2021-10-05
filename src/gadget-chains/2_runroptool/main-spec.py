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
        #'500.perlbench',
        '510.parest',
        #'538.imagick',
        #'541.leela',
        #'519.lbm',
        #'505.mcf',
        #'520.omnetpp',
        #'523.xalancbmk',
        #'508.namd',
        '511.povray',
        ##'526.blender',
        #'531.deepsjeng',
        #'544.nab',
        #'557.xz',
        #'525.x264',
    ]


BASE_FOLDER = '/home/rudy/wo/whole-program-debloat/src/gadget-chains'
INPUT_PATH = BASE_FOLDER + '/input'
OUTPUT_PATH = BASE_FOLDER + '/output'
MAPPED_PAGES_FILE_PREFIX = 'debrt-mapped-rx-pages'
ROP_BENCHMARK_PATH = '/home/rudy/wo/rop-benchmark'


def parse_result(result):
    print()
    print(result)
    print()
    if '(0, 0, 0, 1)' in result:
        return 'Err'
    elif '(1, 0, 0, 1)' in result:
        return 'Ok'
    elif '(0, 1, 0, 1)' in result:
        return 'F'
    print()
    print('Unexpected result')
    print()
    assert False

def run_rop_tool(benchmark, page_group_id):
    # rop-benchmark's run.sh seems to expect "normal" cwd
    os.chdir(ROP_BENCHMARK_PATH)
    #cmd = './run.sh -t ropium -b debian-10-cloud/{}_pg_{}.bin'.format(benchmark, page_group_id)
    cmd = './run.sh -t ropper -b debian-10-cloud/{}_pg_{}.bin'.format(benchmark, page_group_id)
    raw_result = subprocess.getoutput(cmd)
    result = parse_result(raw_result)
    return result



def parse_page_groups_file(benchmark):
    page_group_to_id = {}
    with open('{}/{}/{}_page_groups'.format(OUTPUT_PATH, benchmark, benchmark)) as f:
        for line in f:
            line_vec = line.strip().split(':')
            assert len(line_vec) == 2
            page_group_id = line_vec[0]
            page_group = line_vec[1].strip()
            page_group_to_id[page_group] = page_group_id
    return page_group_to_id



def dump_results(results, benchmark):
    count_chain_exists = results.count('Ok')
    count_no_chain_exists = results.count('F')
    count_err = results.count('Err')
    total =  count_chain_exists + count_no_chain_exists + count_err
    assert total == len(results)
    with open('{}/{}/{}_results'.format(OUTPUT_PATH, benchmark, benchmark), 'w') as f:
        result_str  = ''
        result_str += 'count_no_chain_exists: {}\n'.format(count_no_chain_exists)
        result_str += 'count_chain_exists: {}\n'.format(count_chain_exists)
        result_str += 'count_err: {}\n'.format(count_err)
        result_str += 'total: {}\n'.format(total)
        result_str += 'percent with no chain: {}\n'.format(100 * count_no_chain_exists / total)
        print(result_str)
        f.write('{}'.format(result_str))



def main():

    for benchmark in benchmarks:

        results = []
        page_group_id_to_result = {}

        page_group_to_id = parse_page_groups_file(benchmark)
        rx_pages_files = ['{}/{}/{}'.format(INPUT_PATH, benchmark, x)
                          for x in os.listdir(INPUT_PATH+'/'+benchmark)
                            if x.startswith(MAPPED_PAGES_FILE_PREFIX)]

        for rx_pages_file in rx_pages_files:
            with open(rx_pages_file) as f:
                for line in f:
                    page_indices = line.strip().split()
                    page_indices.sort()
                    page_group = ' '.join(page_indices)
                    page_group_id = page_group_to_id[page_group]
                    if page_group_id in page_group_id_to_result:
                        results.append(page_group_id_to_result[page_group_id])
                    else:
                        result = run_rop_tool(benchmark, page_group_id)
                        results.append(result)
                        page_group_id_to_result[page_group_id] = result

        dump_results(results, benchmark)


main()
