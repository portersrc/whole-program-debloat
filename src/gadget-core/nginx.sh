#!/bin/bash

echo "Gathering gadget results for nginx" &> nginx.log
start=$(readelf -S /root/decker/nginx/objs/nginx_wpd_custlink_ics | grep .text | awk '{print $4}')
size=$(readelf -S /root/decker/nginx/objs/nginx_wpd_custlink_ics | grep .text -A 1 | awk '{getline; print $1}')
echo $bench &>> nginx.log
echo $start &>> nginx.log
echo $size  &>> nginx.log
rm -rf resultswpd_cl_ics/nginx
python3 GSA.py --text_only --binary_version wpd_cl_ics --result_folder_name nginx /root/decker/nginx/objs/nginx_wpd_custlink_ics /root/decker/nginx/ $start $size &>> nginx.log

python3 separate.py --ics_linker --nginx &>> nginx.log

tail -n1 ics_linker.csv | awk -F',' '{print $4" "$6" "$8 }'
