#!/bin/bash
#benches=( bzip2 gzip grep tar )
benches=( bzip2 gzip grep tar )
# benches=( bzip2 )
for i in "${!benches[@]}"
do
    bench="${benches[$i]}"
    start=$(readelf -S /home/rudy/wo/security-bench/${bench}/${bench}_wpd | grep .text | awk '{print $4}')
    size=$(readelf -S /home/rudy/wo/security-bench/${bench}/${bench}_wpd | grep .text -A 1 | awk '{getline; print $1}')
    echo $bench
    echo $start
    echo $size
    # echo /home/rudy/wo/spec/spec2017/benchspec/CPU/$bench/build/build_peak_mytest-m64.0000/debrt-mapped-rx-pages.out
    rm -rf resultswpd/$bench
    python3 GSA.py --text_only --binary_version wpd --result_folder_name ${bench} /home/rudy/wo/security-bench/$bench/$bench"_wpd" /home/rudy/wo/whole-program-debloat/results/2021-06-30/security/$bench/debrt-mapped-rx-pages_wpd.out $start $size
done

for i in "${!benches[@]}"
do
    bench="${benches[$i]}"
    start=$(readelf -S /home/rudy/wo/security-bench/${bench}/${bench}_wpd_custlink | grep .text | awk '{print $4}')
    size=$(readelf -S /home/rudy/wo/security-bench/${bench}/${bench}_wpd_custlink | grep .text -A 1 | awk '{getline; print $1}')
    echo $bench
    echo $start
    echo $size
    # echo /home/rudy/wo/spec/spec2017/benchspec/CPU/$bench/build/build_peak_mytest-m64.0000/debrt-mapped-rx-pages.out
    rm -rf resultswpd_cl/$bench
    python3 GSA.py --text_only --binary_version wpd_cl --result_folder_name ${bench} /home/rudy/wo/security-bench/$bench/$bench"_wpd_custlink" /home/rudy/wo/whole-program-debloat/results/2021-06-30/security/$bench/debrt-mapped-rx-pages_wpd_cl.out $start $size
done

python3 calculate.py --D --base --linker