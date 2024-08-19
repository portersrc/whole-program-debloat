#!/usr/bin/env python3

import os
import sys
import re


#RESULTS_BASE = '/home/rudy/wo/advanced-rtd/whole-program-debloat/results'

# gcc wasn't captured here, so be sure to comment it out from BMARKS_SPEC
# if regenreating these results.
#RESULTS_BASE = '/home/rudy/wo/advanced-rtd/whole-program-debloat/results/asplos25-summer/2024-06-19/no-tracing-no-path-checking'

# gcc and nab weren't captured here, so be sure to comment it out from
# BMARKS_SPEC if regenreating these results.
#RESULTS_BASE = '/home/rudy/wo/advanced-rtd/whole-program-debloat/results/asplos25-summer/2024-06-19/yes-tracing-yes-path-checking'

# Only easy bmarks are valid here
#RESULTS_BASE = '/home/rudy/wo/advanced-rtd/whole-program-debloat/results/2024-06-27/page-fault-no-clean'
#RESULTS_BASE = '/home/rudy/wo/advanced-rtd/whole-program-debloat/results/2024-06-27/page-fault-clean-after-loops'

# only medium and hard bmarks are valid here
# ... or maybe "all" of them would be, i guess? But perlbench, gcc, and blender
# all crashed and should be ignored
#RESULTS_BASE = '/home/rudy/wo/advanced-rtd/whole-program-debloat/results/2024-06-27/medhard-page-fault-clean-after-loops'
# ... similar. same 4 crashed here.
RESULTS_BASE = '/home/rudy/wo/advanced-rtd/whole-program-debloat/results/2024-06-27/medhard-page-fault-no-clean'


SCRIPT_DIR = os.path.dirname(os.path.realpath(__file__))


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
        filename = RESULTS_BASE + '/' + bmark + '_r-' + 'large-artd_release.out'
        t = parse_runtime(filename) 
        times.append((bmark, t))

    for bmark, t in times:
        print('{} {}'.format(bmark, t))
    print()


def main():
    spec_performance()


main()
