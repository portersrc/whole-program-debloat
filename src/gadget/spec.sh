#!/bin/bash

#benches=( 500.perlbench_r 505.mcf_r 508.namd_r 510.parest_r 511.povray_r 519.lbm_r 520.omnetpp_r 523.xalancbmk_r 525.x264_r 531.deepsjeng_r 538.imagick_r 541.leela_r 544.nab_r 557.xz_r 526.blender_r   )
#benches=( 519.lbm_r 505.mcf_r 531.deepsjeng_r 541.leela_r 557.xz_r 544.nab_r 525.x264_r 508.namd_r 511.povray_r 520.omnetpp_r 500.perlbench_r 538.imagick_r 523.xalancbmk_r 510.parest_r 526.blender_r )
 
#benches=( 519.lbm_r 505.mcf_r 531.deepsjeng_r 541.leela_r 544.nab_r 557.xz_r )
#benches=( 500.perlbench_r 508.namd_r 511.povray_r 520.omnetpp_r 523.xalancbmk_r 525.x264_r )
benches=( 508.namd_r 557.xz_r 519.lbm_r )
# for i in "${!benches[@]}"
# do
#     bench="${benches[$i]}"
#     start=$(readelf -S /home/rudy/wo/spec/spec2017/benchspec/CPU/${bench}/build/build_peak_mytest-m64.0000/${bench}_wpd_base | grep .text | awk '{print $4}')
#     size=$(readelf -S /home/rudy/wo/spec/spec2017/benchspec/CPU/${bench}/build/build_peak_mytest-m64.0000/${bench}_wpd_base | grep .text -A 1 | awk '{getline; print $1}')
#     echo $bench
#     echo $start
#     echo $size
#     # echo /home/rudy/wo/spec/spec2017/benchspec/CPU/$bench/build/build_peak_mytest-m64.0000/debrt-mapped-rx-pages.out
#     rm -rf resultswpd/$bench
#     python3 GSA.py --text_only --binary_version wpd --result_folder_name ${bench} /home/rudy/wo/spec/spec2017/benchspec/CPU/$bench/build/build_peak_mytest-m64.0000/$bench"_wpd_base" /home/rudy/wo/whole-program-debloat/results/2021-07-01/security/$bench/debrt-mapped-rx-pages_wpd.out $start $size
# done

# for i in "${!benches[@]}"
# do
#     bench="${benches[$i]}"
#     start=$(readelf -S /home/rudy/wo/spec/spec2017/benchspec/CPU/${bench}/build/build_peak_mytest-m64.0000/${bench}_wpd_custlink | grep .text | awk '{print $4}')
#     size=$(readelf -S /home/rudy/wo/spec/spec2017/benchspec/CPU/${bench}/build/build_peak_mytest-m64.0000/${bench}_wpd_custlink | grep .text -A 1 | awk '{getline; print $1}')
#     echo $bench
#     echo $start
#     echo $size
#     # echo /home/rudy/wo/spec/spec2017/benchspec/CPU/$bench/build/build_peak_mytest-m64.0000/debrt-mapped-rx-pages.out
#     rm -rf resultswpd_cl/$bench
#     python3 GSA.py --text_only --binary_version wpd_cl --result_folder_name ${bench} /home/rudy/wo/spec/spec2017/benchspec/CPU/$bench/build/build_peak_mytest-m64.0000/$bench"_wpd_custlink" /home/rudy/wo/whole-program-debloat/results/2021-07-01/security/$bench/debrt-mapped-rx-pages_wpd_cl.out $start $size
# done

# for i in "${!benches[@]}"
# do
#     bench="${benches[$i]}"
#     start=$(readelf -S /home/rudy/wo/spec/spec2017/benchspec/CPU/${bench}/build/build_peak_mytest-m64.0000/${bench}_wpd_ics | grep .text | awk '{print $4}')
#     size=$(readelf -S /home/rudy/wo/spec/spec2017/benchspec/CPU/${bench}/build/build_peak_mytest-m64.0000/${bench}_wpd_ics | grep .text -A 1 | awk '{getline; print $1}')
#     echo $bench
#     echo $start
#     echo $size
#     # echo /home/rudy/wo/spec/spec2017/benchspec/CPU/$bench/build/build_peak_mytest-m64.0000/debrt-mapped-rx-pages.out
#     rm -rf resultswpd_ics/$bench
#     python3 GSA.py --text_only --binary_version wpd_ics --result_folder_name ${bench} /home/rudy/wo/spec/spec2017/benchspec/CPU/$bench/build/build_peak_mytest-m64.0000/$bench"_wpd_ics" /home/rudy/wo/whole-program-debloat/results/2021-07-01/security/$bench/debrt-mapped-rx-pages_wpd_ics.out $start $size
# done

# for i in "${!benches[@]}"
# do
#     bench="${benches[$i]}"
#     start=$(readelf -S /home/rudy/wo/spec/spec2017/benchspec/CPU/${bench}/build/build_peak_mytest-m64.0000/${bench}_wpd_custlink_ics | grep .text | awk '{print $4}')
#     size=$(readelf -S /home/rudy/wo/spec/spec2017/benchspec/CPU/${bench}/build/build_peak_mytest-m64.0000/${bench}_wpd_custlink_ics | grep .text -A 1 | awk '{getline; print $1}')
#     echo $bench
#     echo $start
#     echo $size
#     # echo /home/rudy/wo/spec/spec2017/benchspec/CPU/$bench/build/build_peak_mytest-m64.0000/debrt-mapped-rx-pages.out
#     rm -rf resultswpd_cl_ics/$bench
#     python3 GSA.py --text_only --binary_version wpd_cl_ics --result_folder_name ${bench} /home/rudy/wo/spec/spec2017/benchspec/CPU/$bench/build/build_peak_mytest-m64.0000/$bench"_wpd_custlink_ics" /home/rudy/wo/whole-program-debloat/results/2021-07-01/security/$bench/debrt-mapped-rx-pages_wpd_cl_ics.out $start $size
# done

for i in "${!benches[@]}"
do
    bench="${benches[$i]}"
    start=$(readelf -S /home/rudy/wo/spec/spec2017/benchspec/CPU/${bench}/build/build_peak_mytest-m64.0000/${bench}_wpd_bicsa | grep .text | awk '{print $4}')
    size=$(readelf -S /home/rudy/wo/spec/spec2017/benchspec/CPU/${bench}/build/build_peak_mytest-m64.0000/${bench}_wpd_bicsa | grep .text -A 1 | awk '{getline; print $1}')
    echo $bench
    echo $start
    echo $size
    # echo /home/rudy/wo/spec/spec2017/benchspec/CPU/$bench/build/build_peak_mytest-m64.0000/debrt-mapped-rx-pages.out
    rm -rf resultswpd_bicsa/$bench
    python3 GSA.py --text_only --binary_version wpd_bicsa --result_folder_name ${bench} /home/rudy/wo/spec/spec2017/benchspec/CPU/$bench/build/build_peak_mytest-m64.0000/$bench"_wpd_bicsa" /home/rudy/wo/whole-program-debloat/results/2021-07-02/security/$bench/debrt-mapped-rx-pages_wpd_bicsa.out $start $size
done

for i in "${!benches[@]}"
do
    bench="${benches[$i]}"
    start=$(readelf -S /home/rudy/wo/spec/spec2017/benchspec/CPU/${bench}/build/build_peak_mytest-m64.0000/${bench}_wpd_custlink_bicsa | grep .text | awk '{print $4}')
    size=$(readelf -S /home/rudy/wo/spec/spec2017/benchspec/CPU/${bench}/build/build_peak_mytest-m64.0000/${bench}_wpd_custlink_bicsa | grep .text -A 1 | awk '{getline; print $1}')
    echo $bench
    echo $start
    echo $size
    # echo /home/rudy/wo/spec/spec2017/benchspec/CPU/$bench/build/build_peak_mytest-m64.0000/debrt-mapped-rx-pages.out
    rm -rf resultswpd_cl_bicsa/$bench
    python3 GSA.py --text_only --binary_version wpd_cl_bicsa --result_folder_name ${bench} /home/rudy/wo/spec/spec2017/benchspec/CPU/$bench/build/build_peak_mytest-m64.0000/$bench"_wpd_custlink_bicsa" /home/rudy/wo/whole-program-debloat/results/2021-07-02/security/$bench/debrt-mapped-rx-pages_wpd_cl_bicsa.out $start $size
done

# for i in "${!benches[@]}"
# do
#     bench="${benches[$i]}"
#     start=$(readelf -S /home/rudy/wo/spec/spec2017/benchspec/CPU/${bench}/build/build_peak_mytest-m64.0000/${bench}_wpd_sink | grep .text | awk '{print $4}')
#     size=$(readelf -S /home/rudy/wo/spec/spec2017/benchspec/CPU/${bench}/build/build_peak_mytest-m64.0000/${bench}_wpd_sink | grep .text -A 1 | awk '{getline; print $1}')
#     echo $bench
#     echo $start
#     echo $size
#     # echo /home/rudy/wo/spec/spec2017/benchspec/CPU/$bench/build/build_peak_mytest-m64.0000/debrt-mapped-rx-pages.out
#     rm -rf resultswpd_sink/$bench
#     python3 GSA.py --text_only --binary_version wpd_sink --result_folder_name ${bench} /home/rudy/wo/spec/spec2017/benchspec/CPU/$bench/build/build_peak_mytest-m64.0000/$bench"_wpd_sink" /home/rudy/wo/whole-program-debloat/results/2021-06-24/security/$bench/debrt-mapped-rx-pages_wpd_sink.out $start $size
# done

# for i in "${!benches[@]}"
# do
#     bench="${benches[$i]}"
#     start=$(readelf -S /home/rudy/wo/spec/spec2017/benchspec/CPU/${bench}/build/build_peak_mytest-m64.0000/${bench}_wpd_custlink_sink | grep .text | awk '{print $4}')
#     size=$(readelf -S /home/rudy/wo/spec/spec2017/benchspec/CPU/${bench}/build/build_peak_mytest-m64.0000/${bench}_wpd_custlink_sink | grep .text -A 1 | awk '{getline; print $1}')
#     echo $bench
#     echo $start
#     echo $size
#     # echo /home/rudy/wo/spec/spec2017/benchspec/CPU/$bench/build/build_peak_mytest-m64.0000/debrt-mapped-rx-pages.out
#     rm -rf resultswpd_cl_sink/$bench
#     python3 GSA.py --text_only --binary_version wpd_cl_sink --result_folder_name ${bench} /home/rudy/wo/spec/spec2017/benchspec/CPU/$bench/build/build_peak_mytest-m64.0000/$bench"_wpd_custlink_sink" /home/rudy/wo/whole-program-debloat/results/2021-06-24/security/$bench/debrt-mapped-rx-pages_wpd_cl_sink.out $start $size
# done

# python3 calculate.py --A --B --base --linker --sink --sink_linker
# python3 calculate.py --A --B --base --linker 
python3 calculate.py --E --bicsa --bicsa_linker  