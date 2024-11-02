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
    BIN=uniq
    WHICH=base_ls
elif [ "$1" == "wpd" ]; then
    BIN=uniq_wpd
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
    BIN=uniq_wpd_custlink
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
    BIN=uniq_wpd_ics
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
    BIN=uniq_wpd_custlink_ics
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
    BIN=uniq_artd_profile
    WHICH=artd_profile
elif [ "$1" == "artd_test_predict" ]; then
    BIN=uniq_artd_test_predict
    WHICH=artd_test_predict
elif [ "$1" == "artd_release" ]; then
    BIN=uniq_artd_release
    WHICH=artd_release
else
    usage_exit
fi


source ${PROJ_DIR}/src/spec/2017/run_aux_preprocess.sh

{ time ./${BIN} test/asyoulik.txt; } &> 1-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_1_$1.out
cp debrt.out debrt_1_$1.out
{ time ./${BIN} -c test/asyoulik.txt; } &> 2-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_2_$1.out
cp debrt.out debrt_2_$1.out
{ time ./${BIN} -d test/asyoulik.txt; } &> 3-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_3_$1.out
cp debrt.out debrt_3_$1.out
{ time ./${BIN} -u test/asyoulik.txt; } &> 4-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_4_$1.out
cp debrt.out debrt_4_$1.out
{ time ./${BIN} -i test/asyoulik.txt; } &> 5-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_5_$1.out
cp debrt.out debrt_5_$1.out
{ time ./${BIN} -f 5 test/asyoulik.txt; } &> 6-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_6_$1.out
cp debrt.out debrt_6_$1.out
{ time ./${BIN} -s 10 test/asyoulik.txt; } &> 7-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_7_$1.out
cp debrt.out debrt_7_$1.out
{ time ./${BIN} -w 10 test/asyoulik.txt; } &> 8-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_8_$1.out
cp debrt.out debrt_8_$1.out

{ time ./${BIN} test/bible.txt; } &> 9-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_9_$1.out
cp debrt.out debrt_9_$1.out
{ time ./${BIN} -c test/bible.txt; } &> 10-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_10_$1.out
cp debrt.out debrt_10_$1.out
{ time ./${BIN} -d test/bible.txt; } &> 11-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_11_$1.out
cp debrt.out debrt_11_$1.out
{ time ./${BIN} -u test/bible.txt; } &> 12-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_12_$1.out
cp debrt.out debrt_12_$1.out
{ time ./${BIN} -i test/bible.txt; } &> 13-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_13_$1.out
cp debrt.out debrt_13_$1.out
{ time ./${BIN} -f 5 test/bible.txt; } &> 14-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_14_$1.out
cp debrt.out debrt_14_$1.out
{ time ./${BIN} -s 10 test/bible.txt; } &> 15-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_15_$1.out
cp debrt.out debrt_15_$1.out
{ time ./${BIN} -w 10 test/bible.txt; } &> 16-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_16_$1.out
cp debrt.out debrt_16_$1.out

{ time ./${BIN} test/lcet10.txt; } &> 17-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_17_$1.out
cp debrt.out debrt_17_$1.out
{ time ./${BIN} -c test/lcet10.txt; } &> 18-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_18_$1.out
cp debrt.out debrt_18_$1.out
{ time ./${BIN} -d test/lcet10.txt; } &> 19-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_19_$1.out
cp debrt.out debrt_19_$1.out
{ time ./${BIN} -u test/lcet10.txt; } &> 20-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_20_$1.out
cp debrt.out debrt_20_$1.out
{ time ./${BIN} -i test/lcet10.txt; } &> 21-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_21_$1.out
cp debrt.out debrt_21_$1.out
{ time ./${BIN} -f 5 test/lcet10.txt; } &> 22-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_22_$1.out
cp debrt.out debrt_22_$1.out
{ time ./${BIN} -s 10 test/lcet10.txt; } &> 23-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_23_$1.out
cp debrt.out debrt_23_$1.out
{ time ./${BIN} -w 10 test/lcet10.txt; } &> 24-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_24_$1.out
cp debrt.out debrt_24_$1.out

{ time ./${BIN} test/random.txt; } &> 25-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_25_$1.out
cp debrt.out debrt_25_$1.out
{ time ./${BIN} -c test/random.txt; } &> 26-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_26_$1.out
cp debrt.out debrt_26_$1.out
{ time ./${BIN} -d test/random.txt; } &> 27-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_27_$1.out
cp debrt.out debrt_27_$1.out
{ time ./${BIN} -u test/random.txt; } &> 28-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_28_$1.out
cp debrt.out debrt_28_$1.out
{ time ./${BIN} -i test/random.txt; } &> 29-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_29_$1.out
cp debrt.out debrt_29_$1.out
{ time ./${BIN} -f 5 test/random.txt; } &> 30-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_30_$1.out
cp debrt.out debrt_30_$1.out
{ time ./${BIN} -s 10 test/random.txt; } &> 31-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_31_$1.out
cp debrt.out debrt_31_$1.out
{ time ./${BIN} -w 10 test/random.txt; } &> 32-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_32_$1.out
cp debrt.out debrt_32_$1.out

{ time ./${BIN} test/world192.txt; } &> 33-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_33_$1.out
cp debrt.out debrt_33_$1.out
{ time ./${BIN} -c test/world192.txt; } &> 34-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_34_$1.out
cp debrt.out debrt_34_$1.out
{ time ./${BIN} -d test/world192.txt; } &> 35-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_35_$1.out
cp debrt.out debrt_35_$1.out
{ time ./${BIN} -u test/world192.txt; } &> 36-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_36_$1.out
cp debrt.out debrt_36_$1.out
{ time ./${BIN} -i test/world192.txt; } &> 37-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_37_$1.out
cp debrt.out debrt_37_$1.out
{ time ./${BIN} -f 5 test/world192.txt; } &> 38-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_38_$1.out
cp debrt.out debrt_38_$1.out
{ time ./${BIN} -s 10 test/world192.txt; } &> 39-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_39_$1.out
cp debrt.out debrt_39_$1.out
{ time ./${BIN} -w 10 test/world192.txt; } &> 40-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_40_$1.out
cp debrt.out debrt_40_$1.out

source ${PROJ_DIR}/src/spec/2017/run_aux_postprocess.sh