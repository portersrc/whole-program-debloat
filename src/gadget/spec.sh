#!/bin/bash

#benches=( 500.perlbench_r 505.mcf_r 508.namd_r 510.parest_r 511.povray_r 519.lbm_r 520.omnetpp_r 523.xalancbmk_r 525.x264_r 531.deepsjeng_r 538.imagick_r 541.leela_r 544.nab_r 557.xz_r 526.blender_r   )
benches=( 519.lbm_r 505.mcf_r 531.deepsjeng_r 541.leela_r 557.xz_r 544.nab_r 525.x264_r 508.namd_r 511.povray_r 520.omnetpp_r 500.perlbench_r 538.imagick_r 523.xalancbmk_r 510.parest_r 526.blender_r )
 
#benches=( 505.mcf_r )
for i in "${!benches[@]}"
do
    bench="${benches[$i]}"
    start=$(readelf -S /home/rudy/wo/spec/spec2017/benchspec/CPU/${bench}/build/build_peak_mytest-m64.0000/${bench}_wpd | grep .text | awk '{print $4}')
    size=$(readelf -S /home/rudy/wo/spec/spec2017/benchspec/CPU/${bench}/build/build_peak_mytest-m64.0000/${bench}_wpd | grep .text -A 1 | awk '{getline; print $1}')
    echo $bench
    echo $start
    echo $size
    # echo /home/rudy/wo/spec/spec2017/benchspec/CPU/$bench/build/build_peak_mytest-m64.0000/debrt-mapped-rx-pages.out
    rm -rf results/$bench
    python3 GSA.py --output_metrics --output_tables original --result_folder_name ${bench} /home/rudy/wo/spec/spec2017/benchspec/CPU/$bench/build/build_peak_mytest-m64.0000/$bench"_wpd" /home/rudy/wo/spec/spec2017/benchspec/CPU/$bench/build/build_peak_mytest-m64.0000/debrt-mapped-rx-pages.out $start $size
done