#!/bin/bash
#benches=( bzip2 )
benches=( bzip2 gzip tar grep chown date mkdir rm sort uniq )
# for i in "${!benches[@]}"
# do
#     bench="${benches[$i]}"
#     start=$(readelf -S /home/rudy/wo/security-bench/${bench}/${bench}_wpd_nostatic | grep .text | awk '{print $4}')
#     size=$(readelf -S /home/rudy/wo/security-bench/${bench}/${bench}_wpd_nostatic | grep .text -A 1 | awk '{getline; print $1}')
#     echo $bench
#     echo $start
#     echo $size
#     # echo /home/rudy/wo/spec/spec2017/benchspec/CPU/$bench/build/build_peak_mytest-m64.0000/debrt-mapped-rx-pages.out
#     rm -rf resultswpd/$bench
#     python3 GSA.py --text_only --binary_version wpd --result_folder_name ${bench} /home/rudy/wo/security-bench/$bench/$bench"_wpd_nostatic" /home/rudy/wo/whole-program-debloat/results/2021-07-03/security/$bench/debrt-mapped-rx-pages_1_wpd.out $start $size
# done

for i in "${!benches[@]}"
do
    bench="${benches[$i]}"
    start=$(readelf -S /home/rudy/wo/security-bench/${bench}/${bench}_wpd_custlink_ics_nostatic | grep .text | awk '{print $4}')
    size=$(readelf -S /home/rudy/wo/security-bench/${bench}/${bench}_wpd_custlink_ics_nostatic | grep .text -A 1 | awk '{getline; print $1}')
    echo $bench
    echo $start
    echo $size
    # echo /home/rudy/wo/spec/spec2017/benchspec/CPU/$bench/build/build_peak_mytest-m64.0000/debrt-mapped-rx-pages.out
    rm -rf resultswpd_cl_ics/$bench
    python3 GSA.py --text_only --binary_version wpd_cl_ics --result_folder_name ${bench} /home/rudy/wo/security-bench/$bench/$bench"_wpd_custlink_ics_nostatic" /home/rudy/wo/whole-program-debloat/results/2022-09-05/security/cl-ics/$bench/ $start $size
done

python3 separate.py --ics_linker
