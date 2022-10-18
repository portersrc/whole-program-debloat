#!/usr/bin/env python3

import os
import sys
import re
import subprocess


PROJ_BASE = '/root/decker/whole-program-debloat'
SPEC_BASE = '/root/decker/spec2017/benchspec/CPU'
COREUTILS_BASE = '/root/decker/security-bench'
NGINX_BASE = '/root/decker/nginx'
SCRIPT_DIR = os.path.dirname(os.path.realpath(__file__))


BMARK_TO_NUMBERED_NAME = {
    'perlbench': '500.perlbench',
    'gcc': '502.gcc',
    'mcf': '505.mcf',
    'namd': '508.namd',
    'parest': '510.parest',
    'povray': '511.povray',
    'lbm': '519.lbm',
    'omnetpp': '520.omnetpp',
    'xalancbmk': '523.xalancbmk',
    'x264': '525.x264',
    'blender': '526.blender',
    'deepsjeng': '531.deepsjeng',
    'imagick': '538.imagick',
    'leela': '541.leela',
    'nab': '544.nab',
    'xz': '557.xz',
}

BMARK_TO_TARGET_EQUALS = {
    '500.perlbench': '',
    '502.gcc': '',
    '505.mcf': '',
    '508.namd': '',
    '510.parest': '',
    '511.povray': 'TARGET=povray_r',
    '519.lbm': '',
    '520.omnetpp': '',
    '523.xalancbmk': '',
    '525.x264': 'TARGET=x264_r',
    '526.blender': 'TARGET=blender_r',
    '531.deepsjeng': '',
    '538.imagick': 'TARGET=imagick_r',
    '541.leela': '',
    '544.nab': '',
    '557.xz': '',
}

BMARKS_SPEC = [
    '500.perlbench',
    '502.gcc',
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


SPEC_BMARK_TO_FOLDER = {
    '500.perlbench': '500.perlbench_r/build/build_peak_mytest-m64.0000',
    '502.gcc': '502.gcc_r/build/build_peak_mytest-m64.0000',
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


BMARKS_COREUTILS = [
  'bzip2',
  'gzip',
  'tar',
  'grep',
  'chown',
  'date',
  'mkdir',
  'rm',
  'sort',
  'uniq',
]






def run_cmd(cmd):
    rc, rv = subprocess.getstatusoutput(cmd)
    if rc != 0:
        print('rc: {}'.format(rc))
        print('rv: {}'.format(rv))
        sys.exit(1)
    return (rc, rv)


def parse_time(val):
    m = re.match(r"(.*)(m)(.*)(s)", val)
    if m:
        minutes = int(m.group(1))
        seconds = float(m.group(3))
        runtime = minutes * 60 + seconds
    else:
        print('Unexpected input to parse_time: {}'.format(val))
        print('Returning a time of 0s and attempting to continue')
        return(0)
    return runtime


def parse_runtime(bmark, which):
    filename = SPEC_BASE + '/' + SPEC_BMARK_TO_FOLDER[bmark] + '/' + which
    with open(filename) as f:
        for line in f:
            if "real\t" in line:
                line = line.strip()
                line_vec = line.split()
                return parse_time(line_vec[1])
    print('Unexpected: unable to parse runtime.')
    print('Returning a time of 0s and attempting to continue')
    return 0

def parse_du(du_output):
    du_output = du_output.strip()
    du_output = du_output.split()
    return int(du_output[0])


def section_5_1():
    #
    # Slowdown on SPEC 2017
    #
    slowdowns = []
    for bmark in BMARKS_SPEC:
        decker_time = parse_runtime(bmark, 'large-wpd_cl_ics.out')
        base_time = parse_runtime(bmark, 'large-base_ls.out')
        slowdown = decker_time / base_time
        slowdowns.append((bmark, slowdown))

    print('Normalized slowdown for SPEC 2017')
    print('---------------------------------')
    print('Benchmark Slowdown')
    some = 0
    for bmark, slowdown in slowdowns:
        print('{} {}'.format(bmark, slowdown))
        some += slowdown
    print('Avg-slowdown {}'.format(some / len(slowdowns)))



    #
    # Gadget reduction on SPEC 2017
    #
    os.chdir('/root/decker/whole-program-debloat/src/gadget-spec/')

    _, rv =run_cmd('./spec.sh')
    print('Total gadget reduction for SPEC 2017')
    print('------------------------------------')
    print('Application Min Max Avg')
    print(rv)

    some_min = 0
    some_max = 0
    some_avg = 0
    count = 0
    for line in rv.splitlines():
        line_vec = line.strip().split()
        some_min += float(line_vec[1])
        some_max += float(line_vec[2])
        some_avg += float(line_vec[3])
        count += 1
    print('AVERAGE {} {} {}'.format(round(some_min/count,1), round(some_max/count,1), round(some_avg/count,1)))

    os.chdir(SCRIPT_DIR)




def section_5_2():
    #
    # Gadget reduction on coreutils
    #
    os.chdir('/root/decker/whole-program-debloat/src/gadget-core/')

    _, rv =run_cmd('./security.sh')
    print('Total gadget reduction for GNU coreutils')
    print('----------------------------------------')
    print('Application Min Max Avg')
    print(rv)

    some_min = 0
    some_max = 0
    some_avg = 0
    count = 0
    for line in rv.splitlines():
        line_vec = line.strip().split()
        some_min += float(line_vec[1])
        some_max += float(line_vec[2])
        some_avg += float(line_vec[3])
        count += 1
    print('AVERAGE {} {} {}'.format(round(some_min/count,1), round(some_max/count,1), round(some_avg/count,1)))

    os.chdir(SCRIPT_DIR)






def section_5_3():
    #
    # Slowdown on nginx
    #
    print('Transfer/sec degradation for nginx')
    print('----------------------------------')
    print('Test-case Slowdown')
    os.chdir('/root/decker/whole-program-debloat/src/nginx/performance/size-variation')
    _, rv = run_cmd('./run_results.sh')
    print(rv)
    os.chdir('/root/decker/whole-program-debloat/src/nginx/performance/time-variation')
    _, rv = run_cmd('./run_results.sh')
    print(rv)
    print()


    #
    # Gadget reduction on nginx
    #
    os.chdir('/root/decker/whole-program-debloat/src/gadget-core/')

    _, rv = run_cmd('./nginx.sh')
    print('Total gadget reduction for nginx')
    print('--------------------------------')
    print('Min Max Avg')
    print(rv)
    print()



    os.chdir(SCRIPT_DIR)



def section_5_4():
    size_increases = []
    for bmark in BMARKS_SPEC:
        bin_name_prefix = SPEC_BASE + '/' + SPEC_BMARK_TO_FOLDER[bmark] + '/' + bmark
        bin_name_base   = bin_name_prefix + '_r_baseline_ls'
        bin_name_decker = bin_name_prefix + '_r_wpd_custlink_ics'
        _, rv = run_cmd('du -sb '+bin_name_base)
        base_size   = parse_du(rv)
        _, rv = run_cmd('du -sb '+bin_name_decker)
        decker_size = parse_du(rv)
        size_increase = decker_size / base_size
        size_increases.append((bmark, size_increase))
    print('Binary size increase for SPEC 2017')
    print('----------------------------------')
    some = 0
    for bmark, size_increase in size_increases:
        print('{} {}'.format(bmark, round(size_increase,1)))
        some += size_increase
    print('Avg-size-increase {}'.format(round(some / len(size_increases),1)))
    print()


    size_increases = []
    for bmark in BMARKS_COREUTILS:
        bin_name_prefix = COREUTILS_BASE + '/' + bmark + '/' + bmark
        bin_name_base   = bin_name_prefix + '_nostatic'
        bin_name_decker = bin_name_prefix + '_wpd_custlink_ics_nostatic'
        _, rv = run_cmd('du -sb '+bin_name_base)
        base_size   = parse_du(rv)
        _, rv = run_cmd('du -sb '+bin_name_decker)
        decker_size = parse_du(rv)
        size_increase = decker_size / base_size
        size_increases.append((bmark, size_increase))
    print('Binary size increase for GNU coreutils')
    print('--------------------------------------')
    some = 0
    for bmark, size_increase in size_increases:
        print('{} {}'.format(bmark, round(size_increase,1)))
        some += size_increase
    print('Avg-size-increase {}'.format(round(some / len(size_increases),1)))
    print()


    bmark = 'nginx'
    bin_name_prefix = NGINX_BASE + '/objs/' + bmark
    bin_name_base   = bin_name_prefix + '_baseline_ls'
    bin_name_decker = bin_name_prefix + '_wpd_custlink_ics'
    _, rv = run_cmd('du -sb '+bin_name_base)
    base_size   = parse_du(rv)
    _, rv = run_cmd('du -sb '+bin_name_decker)
    decker_size = parse_du(rv)
    size_increase = decker_size / base_size
    print('Binary size increase for nginx')
    print('------------------------------')
    print('{}'.format(round(size_increase,1)))






def main():
    section_5_1()
    section_5_2()
    section_5_3()
    section_5_4()

main()
