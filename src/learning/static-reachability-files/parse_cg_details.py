#!/usr/bin/env python3
import sys

benchmarks = [
    "500.perlbench_r",
    "502.gcc_r",
    "505.mcf_r",
    "508.namd_r",
    "510.parest_r",
    "511.povray_r",
    "519.lbm_r",
    "520.omnetpp_r",
    "523.xalancbmk_r",
    "525.x264_r",
    "526.blender_r",
    "531.deepsjeng_r",
    "538.imagick_r",
    "541.leela_r",
    "544.nab_r",
    "557.xz_r",
]

print('filename num_nodes num_edges')
for benchmark in benchmarks:
    filename = "{}-artd_static_reachability.txt".format(benchmark)
    print(filename, end=' ')
    num_nodes = 0
    num_edges = 0
    with open(filename) as f:
        for line in f:
            line = line.strip()
            line_vec = line.split(' ')
            num_nodes += 1
            if len(line_vec) == 1:
                pass
            elif len(line_vec) == 2:
                callees = line_vec[1].split(',')
                # trailing comma leaves an extra empty string, so need -1
                num_edges = num_edges + (len(callees)-1)
            else:
                assert False
    print('{}'.format(num_nodes), end=' ')
    print('{}'.format(num_edges))
