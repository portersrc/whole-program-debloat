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
    BIN=chown
    WHICH=base_ls
elif [ "$1" == "wpd" ]; then
    BIN=chown_wpd
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
    BIN=chown_wpd_custlink
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
    BIN=chown_wpd_ics
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
    BIN=chown_wpd_custlink_ics
    WHICH=wpd_cl_ics
    cp readelf-custlink-ics.out readelf.out
    cp readelf-sections-custlink-ics.out readelf-sections.out
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
elif [ "$1" == "artd_profile" ]; then
    BIN=chown_artd_profile
    WHICH=artd_profile
elif [ "$1" == "artd_test_predict" ]; then
    BIN=chown_artd_test_predict
    WHICH=artd_test_predict
elif [ "$1" == "artd_release" ]; then
    BIN=chown_artd_release
    WHICH=artd_release
else
    usage_exit
fi


source ${PROJ_DIR}/src/spec/2017/run_aux_preprocess.sh

touch .file1
{ time ./${BIN} rudy:rudy .file1; } &> 1-${WHICH}.out
rm -rf .file1
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_1_$1.out
cp debrt.out debrt_1_$1.out

mkdir -p d1/d1/d1/d1/d1/d1/d1/d1/d1
touch d1/d1/d1/d1/d1/d1/d1/d1/d1/file
touch d1/d1/d1/d1/d1/d1/d1/d1/d1/.file
{ time ./${BIN} rudy:rudy d1/d1/d1/d1/d1/d1/d1/d1/d1/file; } &> 2-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_2_$1.out
cp debrt.out debrt_2_$1.out
{ time ./${BIN} rudy:rudy d1/d1/d1/d1/d1/d1/d1/d1/d1/.file; } &> 3-${WHICH}.out
rm -rf d1
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_3_$1.out
cp debrt.out debrt_3_$1.out

mkdir -p d1/d1/d1/d1/d1/d1/d1/d1/d1
touch d1/d1/d1/d1/d1/d1/d1/d1/d1/file
{ time ./${BIN} rudy:rudy d1; } &> 4-${WHICH}.out
rm -rf d1
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_4_$1.out
cp debrt.out debrt_4_$1.out

mkdir -p d1/d1/d1/d1/d1/d1/d1/d1/d1
touch d1/d1/d1/d1/d1/d1/d1/d1/d1/file
touch d1/d1/d1/d1/d1/d1/d1/d1/d1/.file
{ time ./${BIN} -R rudy:rudy d1; } &> 5-${WHICH}.out
rm -rf d1
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_5_$1.out
cp debrt.out debrt_5_$1.out

mkdir -p d1/d1/d1/d1/d1/d1/d1/d1/d1
touch d1/d1/d1/d1/d1/d1/d1/d1/d1/file
touch d1/d1/d1/d1/d1/d1/d1/d1/d1/.file
{ time ./${BIN} -R rudy:rudy d1/d1; } &> 6-${WHICH}.out
rm -rf d1
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_6_$1.out
cp debrt.out debrt_6_$1.out

mkdir -p d1/d1/d1/d1/d1/d1/d1/d1/d1
touch d1/d1/d1/d1/d1/d1/d1/d1/d1/file
touch d1/d1/d1/d1/d1/d1/d1/d1/d1/.file
{ time ./${BIN} -R rudy:rudy d1/d1/d1; } &> 7-${WHICH}.out
rm -rf d1
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_7_$1.out
cp debrt.out debrt_7_$1.out

mkdir -p d1/d1/d1/d1/d1/d1/d1/d1/d1
touch d1/d1/d1/d1/d1/d1/d1/d1/d1/file
touch d1/d1/d1/d1/d1/d1/d1/d1/d1/.file
{ time ./${BIN} -R rudy:rudy d1/d1/d1/d1; } &> 8-${WHICH}.out
rm -rf d1
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_8_$1.out
cp debrt.out debrt_8_$1.out

mkdir -p d1/d1/d1/d1/d1/d1/d1/d1/d1
touch d1/d1/d1/d1/d1/d1/d1/d1/d1/file
touch d1/d1/d1/d1/d1/d1/d1/d1/d1/.file
{ time ./${BIN} -R rudy:rudy d1/d1/d1/d1/d1; } &> 9-${WHICH}.out
rm -rf d1
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_9_$1.out
cp debrt.out debrt_9_$1.out

mkdir -p d1/d1/d1/d1/d1/d1/d1/d1/d1
touch d1/d1/d1/d1/d1/d1/d1/d1/d1/file
touch d1/d1/d1/d1/d1/d1/d1/d1/d1/.file
{ time ./${BIN} -R rudy:rudy d1/d1/d1/d1/d1/d1; } &> 10-${WHICH}.out
rm -rf d1
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_10_$1.out
cp debrt.out debrt_10_$1.out

mkdir -p d1/d1/d1/d1/d1/d1/d1/d1/d1
touch d1/d1/d1/d1/d1/d1/d1/d1/d1/file
touch d1/d1/d1/d1/d1/d1/d1/d1/d1/.file
{ time ./${BIN} -R rudy:rudy d1/d1/d1/d1/d1/d1/d1; } &> 11-${WHICH}.out
rm -rf d1
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_11_$1.out
cp debrt.out debrt_11_$1.out

mkdir -p d1/d1/d1/d1/d1/d1/d1/d1/d1
touch d1/d1/d1/d1/d1/d1/d1/d1/d1/file
touch d1/d1/d1/d1/d1/d1/d1/d1/d1/.file
{ time ./${BIN} -R rudy:rudy d1/d1/d1/d1/d1/d1/d1/d1; } &> 12-${WHICH}.out
rm -rf d1
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_12_$1.out
cp debrt.out debrt_12_$1.out

mkdir -p d1/d1/d1/d1/d1/d1/d1/d1/d1
touch d1/d1/d1/d1/d1/d1/d1/d1/d1/file
touch d1/d1/d1/d1/d1/d1/d1/d1/d1/.file
{ time ./${BIN} -R rudy:rudy d1/d1/d1/d1/d1/d1/d1/d1/d1; } &> 13-${WHICH}.out
rm -rf d1
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_13_$1.out
cp debrt.out debrt_13_$1.out

touch file1
ln -s file1 symfile1
ln -s file1 symfile2
{ time ./${BIN} -h rudy:rudy file1; } &> 14-${WHICH}.out
rm -rf file1 symfile*
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_14_$1.out
cp debrt.out debrt_14_$1.out

touch file1
ln -s file1 symfile1
ln -s file1 symfile2
{ time ./${BIN} -h rudy:rudy symfile1; } &> 15-${WHICH}.out
rm -rf file1 symfile*
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_15_$1.out
cp debrt.out debrt_15_$1.out

touch file1
ln -s file1 symfile1
ln -s file1 symfile2
{ time ./${BIN} -h rudy:rudy symfile2; } &> 16-${WHICH}.out
rm -rf file1 symfile*
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_16_$1.out
cp debrt.out debrt_16_$1.out

touch file1
ln -s file1 symfile1
ln -s file1 symfile2
{ time ./${BIN} -h rudy:rudy symfile*; } &> 17-${WHICH}.out
rm -rf file1 symfile*
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_17_$1.out
cp debrt.out debrt_17_$1.out

source ${PROJ_DIR}/src/spec/2017/run_aux_postprocess.sh