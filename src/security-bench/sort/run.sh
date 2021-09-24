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
    BIN=sort_nostatic
    WHICH=base_ls
    cp sort_nostatic sort
elif [ "$1" == "base_ls_static" ]; then
    BIN=sort_static
    WHICH=base_ls_static
    cp sort_static sort
elif [ "$1" == "wpd" ]; then
    BIN=sort_wpd_nostatic
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
    cp sort_wpd_nostatic sort_wpd
elif [ "$1" == "wpd_static" ]; then
    BIN=sort_wpd_static
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
    cp sort_wpd_static sort_wpd
elif [ "$1" == "wpd_cl" ]; then
    BIN=sort_wpd_custlink_nostatic
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
    cp sort_wpd_custlink_nostatic sort_wpd_custlink
elif [ "$1" == "wpd_cl_static" ]; then
    BIN=sort_wpd_custlink_static
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
    cp sort_wpd_custlink_static sort_wpd_custlink
elif [ "$1" == "wpd_ics" ]; then
    BIN=sort_wpd_ics_nostatic
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
    #cp sort_wpd_ics_nostatic sort_wpd
# elif [ "$1" == "wpd_ics_static" ]; then
#     BIN=sort_wpd_static
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
#     cp sort_wpd_static sort_wpd
elif [ "$1" == "wpd_cl_ics" ]; then
    BIN=sort_wpd_custlink_ics_nostatic
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
    #cp sort_wpd_custlink_ics_nostatic sort_wpd_custlink
# elif [ "$1" == "wpd_static" ]; then
#     BIN=sort_wpd_static
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
#     cp sort_wpd_static sort_wpd
else
    usage_exit
fi

{ time ./${BIN} -r test/aaa.txt; } &> 1-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_1_$1.out
cp debrt.out debrt_1_$1.out

{ time ./${BIN} -s test/aaa.txt; } &> 2-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_2_$1.out
cp debrt.out debrt_2_$1.out

{ time ./${BIN} -u test/aaa.txt; } &> 3-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_3_$1.out
cp debrt.out debrt_3_$1.out

{ time ./${BIN} -z test/aaa.txt; } &> 4-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_4_$1.out
cp debrt.out debrt_4_$1.out

{ time ./${BIN} -r test/alice29.txt; } &> 5-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_5_$1.out
cp debrt.out debrt_5_$1.out

{ time ./${BIN} -s test/alice29.txt; } &> 6-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_6_$1.out
cp debrt.out debrt_6_$1.out

{ time ./${BIN} -u test/alice29.txt; } &> 7-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_7_$1.out
cp debrt.out debrt_7_$1.out

{ time ./${BIN} -z test/alice29.txt; } &> 8-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_8_$1.out
cp debrt.out debrt_8_$1.out

{ time ./${BIN} -r test/asyoulik.txt; } &> 9-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_9_$1.out
cp debrt.out debrt_9_$1.out

{ time ./${BIN} -s test/asyoulik.txt; } &> 10-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_10_$1.out
cp debrt.out debrt_10_$1.out

{ time ./${BIN} -u test/asyoulik.txt; } &> 11-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_11_$1.out
cp debrt.out debrt_11_$1.out

{ time ./${BIN} -z test/asyoulik.txt; } &> 12-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_12_$1.out
cp debrt.out debrt_12_$1.out

{ time ./${BIN} -r test/lcet10.txt; } &> 13-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_13_$1.out
cp debrt.out debrt_13_$1.out

{ time ./${BIN} -s test/lcet10.txt; } &> 14-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_14_$1.out
cp debrt.out debrt_14_$1.out

{ time ./${BIN} -u test/lcet10.txt; } &> 15-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_15_$1.out
cp debrt.out debrt_15_$1.out

{ time ./${BIN} -z test/lcet10.txt; } &> 16-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_16_$1.out
cp debrt.out debrt_16_$1.out

{ time ./${BIN} -r test/pi.txt; } &> 17-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_17_$1.out
cp debrt.out debrt_17_$1.out

{ time ./${BIN} -s test/pi.txt; } &> 18-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_18_$1.out
cp debrt.out debrt_18_$1.out

{ time ./${BIN} -u test/pi.txt; } &> 19-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_19_$1.out
cp debrt.out debrt_19_$1.out

{ time ./${BIN} -z test/pi.txt; } &> 20-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_20_$1.out
cp debrt.out debrt_20_$1.out

{ time ./${BIN} -r test/random.txt; } &> 21-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_21_$1.out
cp debrt.out debrt_21_$1.out

{ time ./${BIN} -s test/random.txt; } &> 22-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_22_$1.out
cp debrt.out debrt_22_$1.out

{ time ./${BIN} -u test/random.txt; } &> 23-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_23_$1.out
cp debrt.out debrt_23_$1.out

{ time ./${BIN} -z test/random.txt; } &> 24-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_24_$1.out
cp debrt.out debrt_24_$1.out

{ time ./${BIN} -r test/world192.txt; } &> 25-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_25_$1.out
cp debrt.out debrt_25_$1.out

{ time ./${BIN} -s test/world192.txt; } &> 26-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_26_$1.out
cp debrt.out debrt_26_$1.out

{ time ./${BIN} -u test/world192.txt; } &> 27-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_27_$1.out
cp debrt.out debrt_27_$1.out

{ time ./${BIN} -z test/world192.txt; } &> 28-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_28_$1.out
cp debrt.out debrt_28_$1.out
