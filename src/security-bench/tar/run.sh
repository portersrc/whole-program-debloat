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
    BIN=tar
    WHICH=base_ls
    cp tar_static tar
elif [ "$1" == "wpd" ]; then
    BIN=tar_wpd
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
    BIN=tar_wpd_custlink
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
    BIN=tar_wpd_ics
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
    BIN=tar_wpd_custlink_ics
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
    BIN=tar_artd_profile
    WHICH=artd_profile
elif [ "$1" == "artd_test_predict" ]; then
    BIN=tar_artd_test_predict
    WHICH=artd_test_predict
elif [ "$1" == "artd_release" ]; then
    BIN=tar_artd_release
    WHICH=artd_release
else
    usage_exit
fi

# 2021.09.24 cporter note:
# 30/32 inputs are used. (a.txt and grammar.lsp are unused.)

source ${PROJ_DIR}/src/spec/2017/run_aux_preprocess.sh

{ time ./${BIN} cf tmp.tar test/cp.html; } &> 1-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_1_$1.out
cp debrt.out debrt_1_$1.out
{ time ./${BIN} cf tmp.tar test/fields.c; } &> 2-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_2_$1.out
cp debrt.out debrt_2_$1.out
{ time ./${BIN} cf tmp.tar test/paper2; } &> 3-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_3_$1.out
cp debrt.out debrt_3_$1.out
{ time ./${BIN} cf tmp.tar test/paper3; } &> 4-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_4_$1.out
cp debrt.out debrt_4_$1.out
{ time ./${BIN} cf tmp.tar test/paper4; } &> 5-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_5_$1.out
cp debrt.out debrt_5_$1.out
{ time ./${BIN} cf tmp.tar test/paper5; } &> 6-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_6_$1.out
cp debrt.out debrt_6_$1.out
{ time ./${BIN} cf tmp.tar test/paper6; } &> 7-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_7_$1.out
cp debrt.out debrt_7_$1.out
{ time ./${BIN} cf tmp.tar test/progc; } &> 8-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_8_$1.out
cp debrt.out debrt_8_$1.out
{ time ./${BIN} cf tmp.tar test/progl; } &> 9-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_9_$1.out
cp debrt.out debrt_9_$1.out
{ time ./${BIN} cf tmp.tar test/progp; } &> 10-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_10_$1.out
cp debrt.out debrt_progp_$1.out
{ time ./${BIN} cf tmp.tar test/sum; } &> 11-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_11_$1.out
cp debrt.out debrt_11_$1.out
{ time ./${BIN} cf tmp.tar test/trans; } &> 12-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_12_$1.out
cp debrt.out debrt_12_$1.out
{ time ./${BIN} cf tmp.tar test/alice29.txt; } &> 13-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_13_$1.out
cp debrt.out debrt_13_$1.out
{ time ./${BIN} cf tmp.tar test/alphabet.txt; } &> 14-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_14_$1.out
cp debrt.out debrt_14_$1.out
{ time ./${BIN} cf tmp.tar test/asyoulik.txt; } &> 15-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_15_$1.out
cp debrt.out debrt_15_$1.out
{ time ./${BIN} cf tmp.tar test/book2; } &> 16-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_16_$1.out
cp debrt.out debrt_16_$1.out
{ time ./${BIN} cf tmp.tar test/geo; } &> 17-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_17_$1.out
cp debrt.out debrt_17_$1.out
{ time ./${BIN} cf tmp.tar test/lcet10.txt; } &> 18-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_18_$1.out
cp debrt.out debrt_18_$1.out
{ time ./${BIN} cf tmp.tar test/news; } &> 19-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_19_$1.out
cp debrt.out debrt_19_$1.out
{ time ./${BIN} cf tmp.tar test/obj2; } &> 20-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_20_$1.out
cp debrt.out debrt_20_$1.out
{ time ./${BIN} cf tmp.tar test/pic; } &> 21-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_21_$1.out
cp debrt.out debrt_21_$1.out
{ time ./${BIN} cf tmp.tar test/plrabn12.txt; } &> 22-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_22_$1.out
cp debrt.out debrt_22_$1.out
{ time ./${BIN} cf tmp.tar test/ptt5; } &> 23-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_23_$1.out
cp debrt.out debrt_23_$1.out
{ time ./${BIN} cf tmp.tar test/random.txt; } &> 24-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_24_$1.out
cp debrt.out debrt_24_$1.out
{ time ./${BIN} cf tmp.tar test/bible.txt; } &> 25-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_25_$1.out
cp debrt.out debrt_25_$1.out
{ time ./${BIN} cf tmp.tar test/E.coli; } &> 26-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_26_$1.out
cp debrt.out debrt_26_$1.out
{ time ./${BIN} cf tmp.tar test/kennedy.xls; } &> 27-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_27_$1.out
cp debrt.out debrt_27_$1.out
{ time ./${BIN} cf tmp.tar test/pi.txt; } &> 28-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_28_$1.out
cp debrt.out debrt_28_$1.out
{ time ./${BIN} cf tmp.tar test/world192.txt; } &> 29-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_29_$1.out
cp debrt.out debrt_29_$1.out
{ time ./${BIN} cf tmp.tar test/xargs.1; } &> 30-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_30_$1.out
cp debrt.out debrt_30_$1.out

source ${PROJ_DIR}/src/spec/2017/run_aux_postprocess.sh