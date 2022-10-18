#!/bin/bash
benches=( bzip2 gzip tar grep chown date mkdir rm sort uniq )

echo "Gathering gadget results for coreutils" &> security.log
for i in "${!benches[@]}"
do
    bench="${benches[$i]}"
    start=$(readelf -S /root/decker/security-bench/${bench}/${bench}_wpd_custlink_ics_nostatic | grep .text | awk '{print $4}')
    size=$(readelf -S /root/decker/security-bench/${bench}/${bench}_wpd_custlink_ics_nostatic | grep .text -A 1 | awk '{getline; print $1}')
    echo $bench &>> security.log
    echo $start &>> security.log
    echo $size  &>> security.log
    rm -rf resultswpd_cl_ics/$bench
    python3 GSA.py --text_only --binary_version wpd_cl_ics --result_folder_name ${bench} /root/decker/security-bench/$bench/$bench"_wpd_custlink_ics_nostatic" /root/decker/security-bench/$bench/ $start $size &>> security.log
done

python3 separate.py --ics_linker &>> security.log
tail -n10 ics_linker.csv | awk -F',' '{print $1" "$4" "$6" "$8 }'
