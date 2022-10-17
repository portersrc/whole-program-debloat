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
    BIN=chown_nostatic
    WHICH=base_ls
    cp chown_nostatic chown
elif [ "$1" == "base_ls_static" ]; then
    BIN=chown_static
    WHICH=base_ls_static
    cp chown_static chown
elif [ "$1" == "wpd" ]; then
    BIN=chown_wpd_nostatic
    WHICH=wpd
    cp readelf-wpd-nostatic.out readelf.out
    cp readelf-sections-wpd-nostatic.out readelf-sections.out
    cp wpd_disjoint_sets_nostatic.txt wpd_disjoint_sets.txt 
    cp wpd_encompassed_funcs_nostatic.txt wpd_encompassed_funcs.txt
    cp wpd_static_reachability_nostatic.txt wpd_static_reachability.txt
    cp wpd_loop_static_reachability_nostatic.txt wpd_loop_static_reachability.txt
    cp wpd_loop_to_func_nostatic.txt wpd_loop_to_func.txt
    cp wpd_static_reachability_nostatic.txt wpd_static_reachability.txt
    cp wpd_loop_static_reachability_nostatic.txt wpd_loop_static_reachability.txt
    cp wpd_stats_nostatic.txt wpd_stats.txt
    cp wpd_func_name_to_id_nostatic.txt wpd_func_name_to_id.txt
    cp wpd_func_name_has_addr_taken_nostatic.txt wpd_func_name_has_addr_taken.txt
    cp chown_wpd_nostatic chown_wpd
elif [ "$1" == "wpd_static" ]; then
    BIN=chown_wpd_static
    WHICH=wpd_static
    cp readelf-wpd-static.out readelf.out
    cp readelf-sections-wpd-static.out readelf-sections.out
    cp wpd_disjoint_sets_static.txt wpd_disjoint_sets.txt 
    cp wpd_encompassed_funcs_static.txt wpd_encompassed_funcs.txt
    cp wpd_static_reachability_static.txt wpd_static_reachability.txt
    cp wpd_loop_static_reachability_static.txt wpd_loop_static_reachability.txt
    cp wpd_loop_to_func_static.txt wpd_loop_to_func.txt
    cp wpd_static_reachability_static.txt wpd_static_reachability.txt
    cp wpd_loop_static_reachability_static.txt wpd_loop_static_reachability.txt
    cp wpd_stats_static.txt wpd_stats.txt
    cp wpd_func_name_to_id_static.txt wpd_func_name_to_id.txt
    cp wpd_func_name_has_addr_taken_static.txt wpd_func_name_has_addr_taken.txt
    cp chown_wpd_static chown_wpd
elif [ "$1" == "wpd_cl" ]; then
    BIN=chown_wpd_custlink_nostatic
    WHICH=wpd_cl
    cp readelf-wpd-custlink-nostatic.out readelf.out
    cp readelf-sections-wpd-custlink-nostatic.out readelf-sections.out
    cp wpd_disjoint_sets_nostatic.txt wpd_disjoint_sets.txt 
    cp wpd_encompassed_funcs_nostatic.txt wpd_encompassed_funcs.txt
    cp wpd_static_reachability_nostatic.txt wpd_static_reachability.txt
    cp wpd_loop_static_reachability_nostatic.txt wpd_loop_static_reachability.txt
    cp wpd_loop_to_func_nostatic.txt wpd_loop_to_func.txt
    cp wpd_static_reachability_nostatic.txt wpd_static_reachability.txt
    cp wpd_loop_static_reachability_nostatic.txt wpd_loop_static_reachability.txt
    cp wpd_stats_nostatic.txt wpd_stats.txt
    cp wpd_func_name_to_id_nostatic.txt wpd_func_name_to_id.txt
    cp wpd_func_name_has_addr_taken_nostatic.txt wpd_func_name_has_addr_taken.txt
    cp chown_wpd_custlink_nostatic chown_wpd_custlink
elif [ "$1" == "wpd_cl_static" ]; then
    BIN=chown_wpd_custlink_static
    WHICH=wpd_cl_static
    cp readelf-wpd-custlink-static.out readelf.out
    cp readelf-sections-wpd-custlink-static.out readelf-sections.out
    cp wpd_disjoint_sets_static.txt wpd_disjoint_sets.txt 
    cp wpd_encompassed_funcs_static.txt wpd_encompassed_funcs.txt
    cp wpd_static_reachability_static.txt wpd_static_reachability.txt
    cp wpd_loop_static_reachability_static.txt wpd_loop_static_reachability.txt
    cp wpd_loop_to_func_static.txt wpd_loop_to_func.txt
    cp wpd_static_reachability_static.txt wpd_static_reachability.txt
    cp wpd_loop_static_reachability_static.txt wpd_loop_static_reachability.txt
    cp wpd_stats_static.txt wpd_stats.txt
    cp wpd_func_name_to_id_static.txt wpd_func_name_to_id.txt
    cp wpd_func_name_has_addr_taken_static.txt wpd_func_name_has_addr_taken.txt
    cp chown_wpd_custlink_static chown_wpd_custlink
elif [ "$1" == "wpd_ics" ]; then
    BIN=chown_wpd_ics_nostatic
    WHICH=wpd_ics
    cp readelf-ics-nostatic.out readelf.out
    cp readelf-sections-ics-nostatic.out readelf-sections.out
    #cp wpd_disjoint_sets_ics_nostatic.txt wpd_disjoint_sets.txt 
    #cp wpd_encompassed_funcs_ics_nostatic.txt wpd_encompassed_funcs.txt
    #cp wpd_static_reachability_ics_nostatic.txt wpd_static_reachability.txt
    #cp wpd_loop_static_reachability_ics_nostatic.txt wpd_loop_static_reachability.txt
    #cp wpd_loop_to_func_ics_nostatic.txt wpd_loop_to_func.txt
    #cp wpd_loop_static_reachability_ics_nostatic.txt wpd_loop_static_reachability.txt
    #cp wpd_stats_ics_nostatic.txt wpd_stats.txt
    #cp wpd_func_name_to_id_nostatic.txt wpd_func_name_to_id.txt
    #cp wpd_func_name_has_addr_taken_nostatic.txt wpd_func_name_has_addr_taken.txt
    #cp chown_wpd_ics_nostatic chown_wpd
# elif [ "$1" == "wpd_ics_static" ]; then
#     BIN=chown_wpd_static
#     WHICH=wpd_static
#     cp readelf-wpd-static.out readelf.out
#     cp readelf-sections-wpd-static.out readelf-sections.out
#     cp wpd_disjoint_sets_static.txt wpd_disjoint_sets.txt 
#     cp wpd_encompassed_funcs_static.txt wpd_encompassed_funcs.txt
#     cp wpd_static_reachability_static.txt wpd_static_reachability.txt
#     cp wpd_loop_static_reachability_static.txt wpd_loop_static_reachability.txt
#     cp wpd_loop_to_func_static.txt wpd_loop_to_func.txt
#     cp wpd_static_reachability_static.txt wpd_static_reachability.txt
#     cp wpd_loop_static_reachability_static.txt wpd_loop_static_reachability.txt
#     cp wpd_stats_static.txt wpd_stats.txt
#     cp wpd_func_name_to_id_static.txt wpd_func_name_to_id.txt
#     cp wpd_func_name_has_addr_taken_static.txt wpd_func_name_has_addr_taken.txt
#     cp chown_wpd_static chown_wpd
elif [ "$1" == "wpd_cl_ics" ]; then
    BIN=chown_wpd_custlink_ics_nostatic
    WHICH=wpd_cl_ics
    cp readelf-custlink-ics-nostatic.out readelf.out
    cp readelf-sections-custlink-ics-nostatic.out readelf-sections.out
    #cp readelf-ics-nostatic.out readelf.out
    #cp readelf-sections-ics-nostatic.out readelf-sections.out
    #cp wpd_disjoint_sets_ics_nostatic.txt wpd_disjoint_sets.txt 
    #cp wpd_encompassed_funcs_ics_nostatic.txt wpd_encompassed_funcs.txt
    #cp wpd_static_reachability_ics_nostatic.txt wpd_static_reachability.txt
    #cp wpd_loop_static_reachability_ics_nostatic.txt wpd_loop_static_reachability.txt
    #cp wpd_loop_to_func_ics_nostatic.txt wpd_loop_to_func.txt
    #cp wpd_loop_static_reachability_ics_nostatic.txt wpd_loop_static_reachability.txt
    #cp wpd_stats_ics_nostatic.txt wpd_stats.txt
    #cp wpd_func_name_to_id_nostatic.txt wpd_func_name_to_id.txt
    #cp wpd_func_name_has_addr_taken_nostatic.txt wpd_func_name_has_addr_taken.txt
    #cp chown_wpd_custlink_ics_nostatic chown_wpd_custlink
# elif [ "$1" == "wpd_static" ]; then
#     BIN=chown_wpd_static
#     WHICH=wpd_static
#     cp readelf-wpd-static.out readelf.out
#     cp readelf-sections-wpd-static.out readelf-sections.out
#     cp wpd_disjoint_sets_static.txt wpd_disjoint_sets.txt 
#     cp wpd_encompassed_funcs_static.txt wpd_encompassed_funcs.txt
#     cp wpd_static_reachability_static.txt wpd_static_reachability.txt
#     cp wpd_loop_static_reachability_static.txt wpd_loop_static_reachability.txt
#     cp wpd_loop_to_func_static.txt wpd_loop_to_func.txt
#     cp wpd_static_reachability_static.txt wpd_static_reachability.txt
#     cp wpd_loop_static_reachability_static.txt wpd_loop_static_reachability.txt
#     cp wpd_stats_static.txt wpd_stats.txt
#     cp wpd_func_name_to_id_static.txt wpd_func_name_to_id.txt
#     cp wpd_func_name_has_addr_taken_static.txt wpd_func_name_has_addr_taken.txt
#     cp chown_wpd_static chown_wpd
else
    usage_exit
fi

touch .file1
{ time ./${BIN} root:root .file1; } &> 1-${WHICH}.out
rm -rf .file1
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_1_$1.out
cp debrt.out debrt_1_$1.out

mkdir -p d1/d1/d1/d1/d1/d1/d1/d1/d1
touch d1/d1/d1/d1/d1/d1/d1/d1/d1/file
touch d1/d1/d1/d1/d1/d1/d1/d1/d1/.file
{ time ./${BIN} root:root d1/d1/d1/d1/d1/d1/d1/d1/d1/file; } &> 2-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_2_$1.out
cp debrt.out debrt_2_$1.out
{ time ./${BIN} root:root d1/d1/d1/d1/d1/d1/d1/d1/d1/.file; } &> 3-${WHICH}.out
rm -rf d1
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_3_$1.out
cp debrt.out debrt_3_$1.out

mkdir -p d1/d1/d1/d1/d1/d1/d1/d1/d1
touch d1/d1/d1/d1/d1/d1/d1/d1/d1/file
{ time ./${BIN} root:root d1; } &> 4-${WHICH}.out
rm -rf d1
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_4_$1.out
cp debrt.out debrt_4_$1.out

mkdir -p d1/d1/d1/d1/d1/d1/d1/d1/d1
touch d1/d1/d1/d1/d1/d1/d1/d1/d1/file
touch d1/d1/d1/d1/d1/d1/d1/d1/d1/.file
{ time ./${BIN} -R root:root d1; } &> 5-${WHICH}.out
rm -rf d1
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_5_$1.out
cp debrt.out debrt_5_$1.out

mkdir -p d1/d1/d1/d1/d1/d1/d1/d1/d1
touch d1/d1/d1/d1/d1/d1/d1/d1/d1/file
touch d1/d1/d1/d1/d1/d1/d1/d1/d1/.file
{ time ./${BIN} -R root:root d1/d1; } &> 6-${WHICH}.out
rm -rf d1
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_6_$1.out
cp debrt.out debrt_6_$1.out

mkdir -p d1/d1/d1/d1/d1/d1/d1/d1/d1
touch d1/d1/d1/d1/d1/d1/d1/d1/d1/file
touch d1/d1/d1/d1/d1/d1/d1/d1/d1/.file
{ time ./${BIN} -R root:root d1/d1/d1; } &> 7-${WHICH}.out
rm -rf d1
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_7_$1.out
cp debrt.out debrt_7_$1.out

mkdir -p d1/d1/d1/d1/d1/d1/d1/d1/d1
touch d1/d1/d1/d1/d1/d1/d1/d1/d1/file
touch d1/d1/d1/d1/d1/d1/d1/d1/d1/.file
{ time ./${BIN} -R root:root d1/d1/d1/d1; } &> 8-${WHICH}.out
rm -rf d1
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_8_$1.out
cp debrt.out debrt_8_$1.out

mkdir -p d1/d1/d1/d1/d1/d1/d1/d1/d1
touch d1/d1/d1/d1/d1/d1/d1/d1/d1/file
touch d1/d1/d1/d1/d1/d1/d1/d1/d1/.file
{ time ./${BIN} -R root:root d1/d1/d1/d1/d1; } &> 9-${WHICH}.out
rm -rf d1
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_9_$1.out
cp debrt.out debrt_9_$1.out

mkdir -p d1/d1/d1/d1/d1/d1/d1/d1/d1
touch d1/d1/d1/d1/d1/d1/d1/d1/d1/file
touch d1/d1/d1/d1/d1/d1/d1/d1/d1/.file
{ time ./${BIN} -R root:root d1/d1/d1/d1/d1/d1; } &> 10-${WHICH}.out
rm -rf d1
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_10_$1.out
cp debrt.out debrt_10_$1.out

mkdir -p d1/d1/d1/d1/d1/d1/d1/d1/d1
touch d1/d1/d1/d1/d1/d1/d1/d1/d1/file
touch d1/d1/d1/d1/d1/d1/d1/d1/d1/.file
{ time ./${BIN} -R root:root d1/d1/d1/d1/d1/d1/d1; } &> 11-${WHICH}.out
rm -rf d1
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_11_$1.out
cp debrt.out debrt_11_$1.out

mkdir -p d1/d1/d1/d1/d1/d1/d1/d1/d1
touch d1/d1/d1/d1/d1/d1/d1/d1/d1/file
touch d1/d1/d1/d1/d1/d1/d1/d1/d1/.file
{ time ./${BIN} -R root:root d1/d1/d1/d1/d1/d1/d1/d1; } &> 12-${WHICH}.out
rm -rf d1
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_12_$1.out
cp debrt.out debrt_12_$1.out

mkdir -p d1/d1/d1/d1/d1/d1/d1/d1/d1
touch d1/d1/d1/d1/d1/d1/d1/d1/d1/file
touch d1/d1/d1/d1/d1/d1/d1/d1/d1/.file
{ time ./${BIN} -R root:root d1/d1/d1/d1/d1/d1/d1/d1/d1; } &> 13-${WHICH}.out
rm -rf d1
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_13_$1.out
cp debrt.out debrt_13_$1.out

touch file1
ln -s file1 symfile1
ln -s file1 symfile2
{ time ./${BIN} -h root:root file1; } &> 14-${WHICH}.out
rm -rf file1 symfile*
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_14_$1.out
cp debrt.out debrt_14_$1.out

touch file1
ln -s file1 symfile1
ln -s file1 symfile2
{ time ./${BIN} -h root:root symfile1; } &> 15-${WHICH}.out
rm -rf file1 symfile*
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_15_$1.out
cp debrt.out debrt_15_$1.out

touch file1
ln -s file1 symfile1
ln -s file1 symfile2
{ time ./${BIN} -h root:root symfile2; } &> 16-${WHICH}.out
rm -rf file1 symfile*
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_16_$1.out
cp debrt.out debrt_16_$1.out

touch file1
ln -s file1 symfile1
ln -s file1 symfile2
{ time ./${BIN} -h root:root symfile*; } &> 17-${WHICH}.out
rm -rf file1 symfile*
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_17_$1.out
cp debrt.out debrt_17_$1.out
