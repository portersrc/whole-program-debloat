#!/usr/bin/env python3
import os
import sys
import subprocess


# algorithm sketch:
#   readelf --sections baseline-binary
#   get the .text size
# 
#   readelf --sections wpd-binary
#   get the .text size
# 
#   nm -S baseline-binary 
#   for each 't' or 'T' symbol, get its size.
#     page-up-align it
#     add it to a sum.
# 
#   dump baseline .text size
#   dump wpd .text size
#   dump worst-case .text size (every function is page aligned)



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
        '500.perlbench',
        '505.mcf',
        '508.namd',
        '510.parest',
        '511.povray',
        '519.lbm',
        '520.omnetpp',
        '523.xalancbmk',
        '525.x264',
        '526.blender',
        '531.deepsjeng',
        '538.imagick',
        '541.leela',
        '544.nab',
        '557.xz',
    ]
    benchmarks_nginx = [
        'nginx',
    ]


COREUTILS_BASE = '/home/rudy/wo/security-bench'
SPEC_BASE = '/home/rudy/wo/spec/spec2017/benchspec/CPU'
NGINX_BASE = '/home/rudy/wo/nginx'


SPEC_BMARK_TO_FOLDER = {
    '500.perlbench': '500.perlbench_r/build/build_peak_mytest-m64.0000',
    '505.mcf': '505.mcf_r/build/build_peak_mytest-m64.0000',
    '508.namd': '508.namd_r/build/build_peak_mytest-m64.0000',
    '510.parest': '510.parest_r/build/build_peak_mytest-m64.0000',
    '511.povray': '511.povray_r/build/build_peak_mytest-m64.0000',
    '519.lbm': '519.lbm_r/build/build_peak_mytest-m64.0000',
    '520.omnetpp': '520.omnetpp_r/build/build_peak_mytest-m64.0000',
    '523.xalancbmk': '523.xalancbmk_r/build/build_peak_mytest-m64.0000',
    '525.x264': '525.x264_r/build/build_peak_mytest-m64.0000',
    '526.blender': '526.blender_r/build/build_peak_mytest-m64.0000',
    '531.deepsjeng': '531.deepsjeng_r/build/build_peak_mytest-m64.0000',
    '538.imagick': '538.imagick_r/build/build_peak_mytest-m64.0000',
    '541.leela': '541.leela_r/build/build_peak_mytest-m64.0000',
    '544.nab': '544.nab_r/build/build_peak_mytest-m64.0000',
    '557.xz': '557.xz_r/build/build_peak_mytest-m64.0000',
}


BMARKS_TO_VEC = {
    'coreutils': benchmarks_coreutils,
    'spec': benchmarks_spec,
    'nginx': benchmarks_nginx,
}
BMARKS_TO_BASELINE_SUFFIX = {
    'coreutils': '_nostatic',
    'spec': '_r_baseline_ls',
    'nginx': '_baseline_ls',
}
BMARKS_TO_WPD_SUFFIX = {
    'coreutils': '_wpd_custlink_ics_nostatic',
    'spec': '_r_wpd_custlink_ics',
    'nginx': '_wpd_custlink_ics',
    
}





def run_nm(path_to, binary):
    #cmd = 'nm -S {}/{} &> nm-{}'.format(path_to, binary, binary)
    cmd = 'nm -S {}/{}'.format(path_to, binary)
    rc, rv = subprocess.getstatusoutput(cmd)
    assert rc == 0
    # hack... let's just write to file
    with open('nm-{}'.format(binary), 'w') as f:
        f.write(rv)

def run_readelf(path_to, binary):
    cmd = 'readelf --wide --sections {}/{}'.format(path_to, binary)
    rc, rv = subprocess.getstatusoutput(cmd)
    assert rc == 0
    # hack... let's just write to file
    with open('readelf-{}'.format(binary), 'w') as f:
        f.write(rv)


def parse_text_size(binary):
    # Parse the text size from the readelf out.
    # Need to handle one dumb case, which is that the first column can
    # be something like [14] or [ 9], depending on which section number .text
    # is. We split on spaces, so just handle this case as follows:
    #   if index 1 is .text
    #   assert vector size is 11, then we take index 5 for the .text's size
    #   if index 2 is .text,
    #   assert vector size is 12, then we take index 6 for the .text's size
    with open('readelf-{}'.format(binary)) as f:
        for line in f:
            line_vec = line.strip().split()
            if len(line_vec) > 1 and line_vec[1] == '.text':
                assert len(line_vec) == 11 
                text_size = int(line_vec[5], 16)
                #print('{}'.format(text_size))
                return text_size
            elif len(line_vec) > 2 and line_vec[2] == '.text':
                assert len(line_vec) == 12
                text_size = int(line_vec[6], 16)
                #print('{}'.format(text_size))
                return text_size
    assert False


def parse_worst_case_size(binary):
    sum_func_size = 0
    sum_func_size_aligned = 0
    with open('nm-{}'.format(binary)) as f:
        for line in f:
            line_vec = line.strip().split()
            if len(line_vec) != 4:
                continue
            #if line_vec[2].lower() == 't' or line_vec[2].lower() == 'w':
            if line_vec[2].lower() == 't':
                func_size = int(line_vec[1], 16)
                func_size_aligned = func_size & ~(0x1000-1)
                if func_size & (0x1000-1):
                    func_size_aligned += 0x1000
                sum_func_size         += func_size
                sum_func_size_aligned += func_size_aligned
    return (sum_func_size, sum_func_size_aligned)




def get_path_to_bmark(which_bmarks, bmark):
    if which_bmarks == 'coreutils':
        return COREUTILS_BASE + '/' + bmark
    elif which_bmarks == 'spec':
        return SPEC_BASE + '/' + SPEC_BMARK_TO_FOLDER[bmark]
    elif which_bmarks == 'nginx':
        return NGINX_BASE  + '/objs'
    else:
        assert False


def get_baseline_results(which_bmarks):
    bmarks_vec = BMARKS_TO_VEC[which_bmarks]
    bmark_suffix = BMARKS_TO_BASELINE_SUFFIX[which_bmarks]
    for b in bmarks_vec:
        path_to_bmark = get_path_to_bmark(which_bmarks, b)
        bmark_w_suffix = b + bmark_suffix
        run_readelf(path_to_bmark, bmark_w_suffix)
        text_size = parse_text_size(bmark_w_suffix)
        print('{} {}'.format(b, text_size))


def get_wpd_results(which_bmarks):
    bmarks_vec = BMARKS_TO_VEC[which_bmarks]
    bmark_suffix = BMARKS_TO_WPD_SUFFIX[which_bmarks]
    for b in bmarks_vec:
        path_to_bmark = get_path_to_bmark(which_bmarks, b)
        bmark_w_suffix = b + bmark_suffix
        run_readelf(path_to_bmark, bmark_w_suffix)
        text_size = parse_text_size(bmark_w_suffix)
        print('{} {}'.format(b, text_size))


def get_worst_case_results(which_bmarks):
    bmarks_vec = BMARKS_TO_VEC[which_bmarks]
    bmark_suffix = BMARKS_TO_BASELINE_SUFFIX[which_bmarks]
    #nm -S baseline-binary 
    #for each 't' or 'T' symbol, get its size.
    #  page-up-align it
    #  add it to a sum.
    for b in bmarks_vec:
        path_to_bmark = get_path_to_bmark(which_bmarks, b)
        bmark_w_suffix = b + bmark_suffix
        run_nm(path_to_bmark, bmark_w_suffix)
        sanity_size, wcs = parse_worst_case_size(bmark_w_suffix)
        print('{} {} {}'.format(b, wcs, sanity_size))



def main():
    #get_baseline_results('coreutils')
    #get_wpd_results('coreutils')
    #get_worst_case_results('coreutils')
    #get_baseline_results('spec')
    #get_wpd_results('spec')
    get_worst_case_results('spec')
    #get_baseline_results('nginx')
    #get_wpd_results('nginx')
    #get_worst_case_results('nginx')


main()
