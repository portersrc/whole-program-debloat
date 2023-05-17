#!/bin/bash

a=( 505.mcf_r 519.lbm_r  531.deepsjeng_r 541.leela_r 544.nab_r 557.xz_r )
b=( 500.perlbench_r 508.namd_r 511.povray_r 520.omnetpp_r 523.xalancbmk_r 525.x264_r )
c=( 510.parest_r 538.imagick_r 526.blender_r )
d=( 502.gcc_r )
benches=( ${a[@]} ${b[@]} ${c[@]} ${d[@]} )

echo "Gathering gadget results for spec" &> spec.log
for i in "${!benches[@]}"
do
    bench="${benches[$i]}"

    start=$(readelf -S /root/decker/spec2017/benchspec/CPU/${bench}/build/build_peak_mytest-m64.0000/${bench}_wpd_custlink_ics | grep .text | awk '{print $4}')
    size=$(readelf -S /root/decker/spec2017/benchspec/CPU/${bench}/build/build_peak_mytest-m64.0000/${bench}_wpd_custlink_ics | grep .text -A 1 | awk '{getline; print $1}')
    echo $bench &>> spec.log
    echo $start &>> spec.log
    echo $size  &>> spec.log
    rm -rf resultswpd_cl_ics/$bench
    python3 GSA.py --text_only --binary_version wpd_cl_ics --result_folder_name ${bench} /root/decker/spec2017/benchspec/CPU/$bench/build/build_peak_mytest-m64.0000/$bench"_wpd_custlink_ics" /root/decker/spec2017/benchspec/CPU/$bench/build/build_peak_mytest-m64.0000/debrt-mapped-rx-pages_wpd_cl_ics-security.out $start $size &>> spec.log

done

echo "Running calculate.py (which i hacked slightly so it had gcc)" &>> spec.log
python3 calculate.py --A --B --C --D --ics_linker &>> spec.log

tail -n16 ics_linker.csv | awk -F',' '{print $1" "$4" "$6" "$8 }'
