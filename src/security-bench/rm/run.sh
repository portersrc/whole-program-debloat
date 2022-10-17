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
    BIN=rm_nostatic
    WHICH=base_ls
    cp rm_nostatic rm
elif [ "$1" == "base_ls_static" ]; then
    BIN=rm_static
    WHICH=base_ls_static
    cp rm_static rm
elif [ "$1" == "wpd" ]; then
    BIN=rm_wpd_nostatic
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
    cp rm_wpd_nostatic rm_wpd
elif [ "$1" == "wpd_static" ]; then
    BIN=rm_wpd_static
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
    cp rm_wpd_static rm_wpd
elif [ "$1" == "wpd_cl" ]; then
    BIN=rm_wpd_custlink_nostatic
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
    cp rm_wpd_custlink_nostatic rm_wpd_custlink
elif [ "$1" == "wpd_cl_static" ]; then
    BIN=rm_wpd_custlink_static
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
    cp rm_wpd_custlink_static rm_wpd_custlink
elif [ "$1" == "wpd_ics" ]; then
    BIN=rm_wpd_ics_nostatic
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
    #cp rm_wpd_ics_nostatic rm_wpd
# elif [ "$1" == "wpd_ics_static" ]; then
#     BIN=rm_wpd_static
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
#     cp rm_wpd_static rm_wpd
elif [ "$1" == "wpd_cl_ics" ]; then
    BIN=rm_wpd_custlink_ics_nostatic
    WHICH=wpd_cl_ics
    cp readelf-custlink-ics-nostatic.out readelf.out
    cp readelf-sections-custlink-ics-nostatic.out readelf-sections.out
    #cp wpd_disjoint_sets_ics_nostatic.txt wpd_disjoint_sets.txt 
    #cp wpd_encompassed_funcs_ics_nostatic.txt wpd_encompassed_funcs.txt
    #cp wpd_static_reachability_ics_nostatic.txt wpd_static_reachability.txt
    #cp wpd_loop_static_reachability_ics_nostatic.txt wpd_loop_static_reachability.txt
    #cp wpd_loop_to_func_ics_nostatic.txt wpd_loop_to_func.txt
    #cp wpd_loop_static_reachability_ics_nostatic.txt wpd_loop_static_reachability.txt
    #cp wpd_stats_ics_nostatic.txt wpd_stats.txt
    #cp wpd_func_name_to_id_nostatic.txt wpd_func_name_to_id.txt
    #cp wpd_func_name_has_addr_taken_nostatic.txt wpd_func_name_has_addr_taken.txt
    #cp rm_wpd_custlink_ics_nostatic rm_wpd_custlink
# elif [ "$1" == "wpd_static" ]; then
#     BIN=rm_wpd_static
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
#     cp rm_wpd_static rm_wpd
else
    usage_exit
fi


touch file1
{ time ./${BIN} file*; } &> 1-${WHICH}.out
rm -rf file*
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_1_$1.out
cp debrt.out debrt_1_$1.out

touch .file1
{ time ./${BIN} .file1; } &> 2-${WHICH}.out
rm -rf file*
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_2_$1.out
cp debrt.out debrt_2_$1.out

touch file file1 file2 file3
{ time ./${BIN} file1 file2 file3; } &> 3-${WHICH}.out
rm -rf file*
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_3_$1.out
cp debrt.out debrt_3_$1.out

touch file file1 file2 file3
{ time ./${BIN} file*; } &> 4-${WHICH}.out
rm -rf file*
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_4_$1.out
cp debrt.out debrt_4_$1.out

mkdir -p d1/d2
# 2021.09.24 cporter: This test returns 1.
#{ time ./${BIN} d1; } &> 5-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_5_$1.out
#cp debrt.out debrt_5_$1.out
# 2021.09.24 cporter: This test returns 1.
#{ time ./${BIN} d1/d2; } &> 6-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_6_$1.out
#cp debrt.out debrt_6_$1.out
{ time ./${BIN} -rf d1; } &> 7-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_7_$1.out
cp debrt.out debrt_7_$1.out
rm -rf d1

mkdir -p d1/d2
mkdir -p d1/d3
{ time ./${BIN} -rf d1; } &> 8-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_8_$1.out
cp debrt.out debrt_8_$1.out
rm -rf d1

mkdir -p d1/d2
mkdir -p d1/d3
{ time ./${BIN} -rf d1/*; } &> 9-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_9_$1.out
cp debrt.out debrt_9_$1.out
{ time ./${BIN} -rf d1; } &> 10-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_10_$1.out
cp debrt.out debrt_10_$1.out
rm -rf d1

mkdir d1
touch d1/file1
touch d1/file2
touch d1/file3
{ time ./${BIN} d1/file*; } &> 11-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_11_$1.out
cp debrt.out debrt_11_$1.out
{ time ./${BIN} -rf d1; } &> 12-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_12_$1.out
cp debrt.out debrt_12_$1.out
rm -rf d1

mkdir -p d1/d2/d3
touch d1/file1
touch d1/d2/file2
touch d1/d2/d3/file3
{ time ./${BIN} d1/file*; } &> 13-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_13_$1.out
cp debrt.out debrt_13_$1.out
{ time ./${BIN} d1/d2/file*; } &> 14-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_14_$1.out
cp debrt.out debrt_14_$1.out
{ time ./${BIN} d1/d2/d3/file*; } &> 15-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_15_$1.out
cp debrt.out debrt_15_$1.out
{ time ./${BIN} -rf d1; } &> 16-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_16_$1.out
cp debrt.out debrt_16_$1.out
rm -rf d1

mkdir -p d1/d2/d3
touch d1/file1
touch d1/d2/file2
touch d1/d2/d3/file3
{ time ./${BIN} -rf d1; } &> 17-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_17_$1.out
cp debrt.out debrt_17_$1.out
rm -rf d1

mkdir d1
touch d1/file d1/file2
# 2021.09.24 cporter: This test uses -i, which "prompts before every removal".
# In other words, need to press Enter twice when it runs.
#{ time ./${BIN} -i d1/file*; } &> 18-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_18_$1.out
#cp debrt.out debrt_18_$1.out
#rm -rf d1

mkdir -p d1
touch d1/file d1/file2
# 2021.09.24 cporter: This test returns 1.
#{ time ./${BIN} -i d1; } &> 19-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_19_$1.out
#cp debrt.out debrt_19_$1.out
{ time ./${BIN} -rf d1; } &> 20-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_20_$1.out
cp debrt.out debrt_20_$1.out
rm -rf d1
