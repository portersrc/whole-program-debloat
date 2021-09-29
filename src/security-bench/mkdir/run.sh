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
    BIN=mkdir_nostatic
    WHICH=base_ls
    cp mkdir_nostatic mkdir
elif [ "$1" == "base_ls_static" ]; then
    BIN=mkdir_static
    WHICH=base_ls_static
    cp mkdir_static mkdir
elif [ "$1" == "wpd" ]; then
    BIN=mkdir_wpd_nostatic
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
    cp mkdir_wpd_nostatic mkdir_wpd
elif [ "$1" == "wpd_static" ]; then
    BIN=mkdir_wpd_static
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
    cp mkdir_wpd_static mkdir_wpd
elif [ "$1" == "wpd_cl" ]; then
    BIN=mkdir_wpd_custlink_nostatic
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
    cp mkdir_wpd_custlink_nostatic mkdir_wpd_custlink
elif [ "$1" == "wpd_cl_static" ]; then
    BIN=mkdir_wpd_custlink_static
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
    cp mkdir_wpd_custlink_static mkdir_wpd_custlink
elif [ "$1" == "wpd_ics" ]; then
    BIN=mkdir_wpd_ics_nostatic
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
    #cp mkdir_wpd_ics_nostatic mkdir_wpd
# elif [ "$1" == "wpd_ics_static" ]; then
#     BIN=mkdir_wpd_static
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
#     cp mkdir_wpd_static mkdir_wpd
elif [ "$1" == "wpd_cl_ics" ]; then
    BIN=mkdir_wpd_custlink_ics_nostatic
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
    #cp mkdir_wpd_custlink_ics_nostatic mkdir_wpd_custlink
# elif [ "$1" == "wpd_static" ]; then
#     BIN=mkdir_wpd_static
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
#     cp mkdir_wpd_static mkdir_wpd
else
    usage_exit
fi

# 2021.09.24 cporter: razor paper reports 24 tests, but the run-razor.py
# script has 25 tests. We replicate all 25 tests.
# Also, the original tests don't `rm -rf d1` between each test. We replicate
# whatever they did. This makes testing pretty manual, at the moment, because
# if a test fails, I sometimes have to `rm -rf d1` or whatever and rerun a
# prior test to get back to the proper state before kicking off the next test.

# 2021.09.24 cporter: This test returns 1
#{ time ./${BIN} d1/d2/d3; } &> 1-${WHICH}.out
#rm -rf d1
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_1_$1.out
#cp debrt.out debrt_1_$1.out

#{ time ./${BIN} -p d1/d2/d3; } &> 2-${WHICH}.out
#rm -rf d1
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_2_$1.out
#cp debrt.out debrt_2_$1.out

#{ time ./${BIN} -p -m 567 d1/d2/d3; } &> 3-${WHICH}.out
#rm -rf d1
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_3_$1.out
#cp debrt.out debrt_3_$1.out

# 2021.09.24 cporter: This test returns 1
#{ time ./${BIN} -m 777 d1/d2; } &> 4-${WHICH}.out
#rm -rf d1
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_4_$1.out
#cp debrt.out debrt_4_$1.out

#{ time ./${BIN} -p -m 777 d1/d2/d3; } &> 5-${WHICH}.out
#rm -rf d1
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_5_$1.out
#cp debrt.out debrt_5_$1.out

#{ time ./${BIN} -p -m 777 d1/d2/d3; } &> 6-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_6_$1.out
#cp debrt.out debrt_6_$1.out
#{ time ./${BIN} -p -m 500 d1/d2/d3/d4; } &> 7-${WHICH}.out
#rm -rf d1
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_7_$1.out
#cp debrt.out debrt_7_$1.out

#{ time ./${BIN} -p -m 555 d1/d2/d3/d4; } &> 8-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_8_$1.out
#cp debrt.out debrt_8_$1.out
#{ time ./${BIN} -m 644 d1/d2/d3/d5; } &> 9-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_9_$1.out
#cp debrt.out debrt_9_$1.out
#{ time ./${BIN} -m 610 d1/d6; } &> 10-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_10_$1.out
#cp debrt.out debrt_10_$1.out
# 2021.09.24 cporter: This test returns 1
#{ time ./${BIN} -m 777 d1/d6/d7; } &> 11-${WHICH}.out
#rm -rf d1
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_11_$1.out
#cp debrt.out debrt_11_$1.out

#{ time ./${BIN} -p -m 777 d1/d2/d3; } &> 12-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_12_$1.out
#cp debrt.out debrt_12_$1.out
# 2021.09.24 cporter: This test returns 1
#{ time ./${BIN} -m 555 d1/d2/d3; } &> 13-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_13_$1.out
#cp debrt.out debrt_13_$1.out
#{ time ./${BIN} -m 644 d1/d2/d3/d4; } &> 14-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_14_$1.out
#cp debrt.out debrt_14_$1.out
# 2021.09.24 cporter: This test returns 1
#{ time ./${BIN} -m 610 d1/d2/d3/d4/d5; } &> 15-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_15_$1.out
#cp debrt.out debrt_15_$1.out
# 2021.09.24 cporter: This test returns 1
#{ time ./${BIN} -m 777 d1/d2/d3/d4/d5/d6; } &> 16-${WHICH}.out
#rm -rf d1
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_16_$1.out
#cp debrt.out debrt_16_$1.out

#{ time ./${BIN} -p -m 777 d1/d2/d3; } &> 17-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_17_$1.out
#cp debrt.out debrt_17_$1.out
#{ time ./${BIN} -m 555 d1/d2/d4; } &> 18-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_18_$1.out
#cp debrt.out debrt_18_$1.out
#{ time ./${BIN} -m 644 d1/d2/d5; } &> 19-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_19_$1.out
#cp debrt.out debrt_19_$1.out
#{ time ./${BIN} -m 610 d1/d2/d6; } &> 20-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_20_$1.out
#cp debrt.out debrt_20_$1.out
#{ time ./${BIN} -m 777 d1/d2/d7; } &> 21-${WHICH}.out
#rm -rf d1
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_21_$1.out
#cp debrt.out debrt_21_$1.out

#{ time ./${BIN} -p d1/d2/d3; } &> 22-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_22_$1.out
#cp debrt.out debrt_22_$1.out
#{ time ./${BIN} -p d1/d2/d3/d4; } &> 23-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_23_$1.out
#cp debrt.out debrt_23_$1.out
#{ time ./${BIN} -p d1/d2/d3/d5; } &> 24-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_24_$1.out
#cp debrt.out debrt_24_$1.out
#{ time ./${BIN} -p d1/d2/d3/d5/d6; } &> 25-${WHICH}.out
#rm -rf d1
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_25_$1.out
#cp debrt.out debrt_25_$1.out
