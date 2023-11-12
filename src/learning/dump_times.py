#!/usr/bin/env python3

import os
import sys
import re


RESULTS_BASE = '/home/rudy/wo/advanced-rtd/whole-program-debloat/src/learning'
SCRIPT_DIR = os.path.dirname(os.path.realpath(__file__))


BMARKS_SPEC = [
    '500.perlbench',
    '502.gcc',
    '505.mcf',
    '508.namd',
    '510.parest',
    '511.povray',
    '519.lbm',
    #'520.omnetpp',
    #'523.xalancbmk',
    '525.x264',
    '526.blender',
    '531.deepsjeng',
    '538.imagick',
    '541.leela',
    '544.nab',
    '557.xz',
]



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


def parse_runtime(filename):
    with open(filename) as f:
        for line in f:
            if "real\t" in line:
                line = line.strip()
                line_vec = line.split()
                return parse_time(line_vec[1])
    print('Unexpected: unable to parse runtime.')
    print('Returning a time of 0s and attempting to continue')
    return 0


def spec_performance():
    times = []
    for bmark in BMARKS_SPEC:
        filename = RESULTS_BASE + '/04/' + bmark + '_r-' + 'large-artd_release.out'
        t = parse_runtime(filename) 
        times.append((bmark, t))

    for bmark, t in times:
        print('{} {}'.format(bmark, t))
    print()


def main():
    spec_performance()


main()
