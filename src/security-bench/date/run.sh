#!/bin/bash
set -euox pipefail

function usage_exit() {
    echo
    echo "Usage: ./run.sh <which-binary> <which-input>"
    echo
    exit 1
}

if [ $# != 2 ]; then
    usage_exit
fi

if [ "$1" == "base_ls" ]; then
    BIN=date
    WHICH=base_ls
elif [ "$1" == "wpd" ]; then
    BIN=date_wpd
    WHICH=wpd
    cp readelf-wpd.out readelf.out
    cp readelf-sections-wpd.out readelf-sections.out
    cp wpd_disjoint_sets.txt wpd_disjoint_sets.txt 
    cp wpd_encompassed_funcs.txt wpd_encompassed_funcs.txt
    cp wpd_static_reachability.txt wpd_static_reachability.txt
    cp wpd_loop_static_reachability.txt wpd_loop_static_reachability.txt
    cp wpd_loop_to_func.txt wpd_loop_to_func.txt
    cp wpd_static_reachability.txt wpd_static_reachability.txt
    cp wpd_loop_static_reachability.txt wpd_loop_static_reachability.txt
    cp wpd_stats.txt wpd_stats.txt
    cp wpd_func_name_to_id.txt wpd_func_name_to_id.txt
    cp wpd_func_name_has_addr_taken.txt wpd_func_name_has_addr_taken.txt
elif [ "$1" == "wpd_cl" ]; then
    BIN=date_wpd_custlink
    WHICH=wpd_cl
    cp readelf-wpd-custlink.out readelf.out
    cp readelf-sections-wpd-custlink.out readelf-sections.out
    cp wpd_disjoint_sets.txt wpd_disjoint_sets.txt 
    cp wpd_encompassed_funcs.txt wpd_encompassed_funcs.txt
    cp wpd_static_reachability.txt wpd_static_reachability.txt
    cp wpd_loop_static_reachability.txt wpd_loop_static_reachability.txt
    cp wpd_loop_to_func.txt wpd_loop_to_func.txt
    cp wpd_static_reachability.txt wpd_static_reachability.txt
    cp wpd_loop_static_reachability.txt wpd_loop_static_reachability.txt
    cp wpd_stats.txt wpd_stats.txt
    cp wpd_func_name_to_id.txt wpd_func_name_to_id.txt
    cp wpd_func_name_has_addr_taken.txt wpd_func_name_has_addr_taken.txt
elif [ "$1" == "wpd_ics" ]; then
    BIN=date_wpd_ics
    WHICH=wpd_ics
    cp readelf-ics.out readelf.out
    cp readelf-sections-ics.out readelf-sections.out
    cp wpd_disjoint_sets_ics.txt wpd_disjoint_sets.txt 
    cp wpd_encompassed_funcs_ics.txt wpd_encompassed_funcs.txt
    cp wpd_static_reachability_ics.txt wpd_static_reachability.txt
    cp wpd_loop_static_reachability_ics.txt wpd_loop_static_reachability.txt
    cp wpd_loop_to_func_ics.txt wpd_loop_to_func.txt
    cp wpd_loop_static_reachability_ics.txt wpd_loop_static_reachability.txt
    cp wpd_stats_ics.txt wpd_stats.txt
    cp wpd_func_name_to_id.txt wpd_func_name_to_id.txt
    cp wpd_func_name_has_addr_taken.txt wpd_func_name_has_addr_taken.txt
elif [ "$1" == "wpd_cl_ics" ]; then
    BIN=date_wpd_custlink_ics
    WHICH=wpd_cl_ics
    cp readelf-custlink-ics.out readelf.out
    cp readelf-sections-custlink-ics.out readelf-sections.out
    cp wpd_disjoint_sets_ics.txt wpd_disjoint_sets.txt 
    cp wpd_encompassed_funcs_ics.txt wpd_encompassed_funcs.txt
    cp wpd_static_reachability_ics.txt wpd_static_reachability.txt
    cp wpd_loop_static_reachability_ics.txt wpd_loop_static_reachability.txt
    cp wpd_loop_to_func_ics.txt wpd_loop_to_func.txt
    cp wpd_loop_static_reachability_ics.txt wpd_loop_static_reachability.txt
    cp wpd_stats_ics.txt wpd_stats.txt
    cp wpd_func_name_to_id.txt wpd_func_name_to_id.txt
    cp wpd_func_name_has_addr_taken.txt wpd_func_name_has_addr_taken.txt
elif [ "$1" == "artd_profile" ]; then
    BIN=date_artd_profile
    WHICH=artd_profile
elif [ "$1" == "artd_test_predict" ]; then
    BIN=date_artd_test_predict
    WHICH=artd_test_predict
elif [ "$1" == "artd_release" ]; then
    BIN=date_artd_release
    WHICH=artd_release
else
    usage_exit
fi


source ${PROJ_DIR}/src/spec/2017/run_aux_preprocess.sh

# 2021.09.23 cporter:
# This first test case returns 1 for the baseline.
# The others are fine.
{ time ./${BIN} --date '02/29/1997 1 year' "+%Y-%m-%d"; } &> 1-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_1_$1.out
cp debrt.out debrt_1_$1.out
#
#{ time ./${BIN} --date '1995-1-7' +%U; } &> 2-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_2_$1.out
#cp debrt.out debrt_2_$1.out
#
#{ time ./${BIN} --date '1995-1-8' +%U; } &> 3-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_3_$1.out
#cp debrt.out debrt_3_$1.out
#
#{ time ./${BIN} --date '1992-1-1' +%U; } &> 4-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_4_$1.out
#cp debrt.out debrt_4_$1.out
#
#{ time ./${BIN} --date '1992-1-4' +%U; } &> 5-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_5_$1.out
#cp debrt.out debrt_5_$1.out
#
#{ time ./${BIN} --date '1992-1-5' +%U; } &> 6-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_6_$1.out
#cp debrt.out debrt_6_$1.out
#
#{ time ./${BIN} --date '1992-1-5' +%V; } &> 7-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_7_$1.out
#cp debrt.out debrt_7_$1.out
#
#{ time ./${BIN} --date '1992-1-6' +%V; } &> 8-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_8_$1.out
#cp debrt.out debrt_8_$1.out
#
#{ time ./${BIN} --date '1992-1-5' +%W; } &> 9-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_9_$1.out
#cp debrt.out debrt_9_$1.out
#
#{ time ./${BIN} --date '1992-1-6' +%W; } &> 10-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_10_$1.out
#cp debrt.out debrt_10_$1.out
#
#{ time ./${BIN} --date '1999-1-1 4 years' +%Y; } &> 11-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_11_$1.out
#cp debrt.out debrt_11_$1.out
#
#{ time ./${BIN} -d 'TZ="America/New_York" 9:00 next Fri'; } &> 12-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_12_$1.out
#cp debrt.out debrt_12_$1.out
#
#{ time ./${BIN} -d "1990-11-08 08:17:48 +0 now" "+%Y-%m-%d %T"; } &> 13-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_13_$1.out
#cp debrt.out debrt_13_$1.out
#
#{ time ./${BIN} -d "1990-11-08 08:17:48 +0 yesterday" "+%Y-%m-%d %T"; } &> 14-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_14_$1.out
#cp debrt.out debrt_14_$1.out
#
#{ time ./${BIN} -d "1990-11-08 08:17:48 +0 tomorrow" "+%Y-%m-%d %T"; } &> 15-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_15_$1.out
#cp debrt.out debrt_15_$1.out
#
#{ time ./${BIN} -d "1990-11-08 08:17:48 +0 10 years ago" "+%Y-%m-%d %T"; } &> 16-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_16_$1.out
#cp debrt.out debrt_16_$1.out
#
#{ time ./${BIN} -d "1990-11-08 08:17:48 +0 8 months ago" "+%Y-%m-%d %T"; } &> 17-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_17_$1.out
#cp debrt.out debrt_17_$1.out
#
#{ time ./${BIN} -d "1990-11-08 08:17:48 +0 80 weeks ago" "+%Y-%m-%d %T"; } &> 18-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_18_$1.out
#cp debrt.out debrt_18_$1.out
#
#{ time ./${BIN} -d '2005-03-27 +4 months' '+%Y'; } &> 19-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_19_$1.out
#cp debrt.out debrt_19_$1.out
#
#{ time ./${BIN} -d @-22 +%10s; } &> 20-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_20_$1.out
#cp debrt.out debrt_20_$1.out
#
#{ time ./${BIN} -d 1999-12-08 +%08d; } &> 21-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_21_$1.out
#cp debrt.out debrt_21_$1.out
#
#{ time ./${BIN} --rfc-3339=ns -d "1969-12-31 13:00:00.00000001-1100"; } &> 22-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_22_$1.out
#cp debrt.out debrt_22_$1.out
#
#{ time ./${BIN} --rfc-3339=sec -d @31536000; } &> 23-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_23_$1.out
#cp debrt.out debrt_23_$1.out
#
#{ time ./${BIN} --utc -d '1970-01-01 00:00:00 UTC +961062237 sec' "+%Y-%m-%d %T"; } &> 24-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_24_$1.out
#cp debrt.out debrt_24_$1.out
#
#{ time ./${BIN} -d 'Nov 10 1996' "+%Y-%m-%d %T"; } &> 25-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_25_$1.out
#cp debrt.out debrt_25_$1.out
#
#{ time ./${BIN} -u -d '1996-11-10 0:00:00 +0' "+%Y-%m-%d %T"; } &> 26-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_26_$1.out
#cp debrt.out debrt_26_$1.out
#
#{ time ./${BIN} -d "1997-01-19 08:17:48 +0 4 seconds ago" "+%Y-%m-%d %T"; } &> 27-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_27_$1.out
#cp debrt.out debrt_27_$1.out
#
#{ time ./${BIN} -d '20050101  1 day' +%F; } &> 28-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_28_$1.out
#cp debrt.out debrt_28_$1.out
#
#{ time ./${BIN} -d '20050101 +1 day' +%F; } &> 29-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_29_$1.out
#cp debrt.out debrt_29_$1.out
#
#{ time ./${BIN} -d "1997-01-19 08:17:48 +0 next second" '+%Y-%m-%d %T'; } &> 30-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_30_$1.out
#cp debrt.out debrt_30_$1.out
#
#{ time ./${BIN} -d "1997-01-19 08:17:48 +0 next minute" '+%Y-%m-%d %T'; } &> 31-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_31_$1.out
#cp debrt.out debrt_31_$1.out
#
#{ time ./${BIN} -d "1997-01-19 08:17:48 +0 next hour" '+%Y-%m-%d %T'; } &> 32-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_32_$1.out
#cp debrt.out debrt_32_$1.out
#
#{ time ./${BIN} -d "1997-01-19 08:17:48 +0 next day" '+%Y-%m-%d %T'; } &> 33-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_33_$1.out
#cp debrt.out debrt_33_$1.out

source ${PROJ_DIR}/src/spec/2017/run_aux_postprocess.sh