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
    BIN=bzip2_nostatic
    WHICH=base_ls
    cp bzip2_nostatic bzip2
elif [ "$1" == "base_ls_static" ]; then
    BIN=bzip2_static
    WHICH=base_ls_static
    cp bzip2_static bzip2
elif [ "$1" == "wpd" ]; then
    BIN=bzip2_wpd_nostatic
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
    cp bzip2_wpd_nostatic bzip2_wpd
elif [ "$1" == "wpd_static" ]; then
    BIN=bzip2_wpd_static
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
    cp bzip2_wpd_static bzip2_wpd
elif [ "$1" == "wpd_cl" ]; then
    BIN=bzip2_wpd_custlink_nostatic
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
    cp bzip2_wpd_custlink_nostatic bzip2_wpd_custlink
elif [ "$1" == "wpd_cl_static" ]; then
    BIN=bzip2_wpd_custlink_static
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
    cp bzip2_wpd_custlink_static bzip2_wpd_custlink
elif [ "$1" == "wpd_ics" ]; then
    BIN=bzip2_wpd_ics_nostatic
    WHICH=wpd_ics
    cp readelf-ics-nostatic.out readelf.out
    cp readelf-sections-ics-nostatic.out readelf-sections.out
    cp wpd_disjoint_sets_ics_nostatic.txt wpd_disjoint_sets.txt 
    cp wpd_encompassed_funcs_ics_nostatic.txt wpd_encompassed_funcs.txt
    cp wpd_static_reachability_ics_nostatic.txt wpd_static_reachability.txt
    cp wpd_loop_static_reachability_ics_nostatic.txt wpd_loop_static_reachability.txt
    cp wpd_loop_to_func_ics_nostatic.txt wpd_loop_to_func.txt
    cp wpd_loop_static_reachability_ics_nostatic.txt wpd_loop_static_reachability.txt
    cp wpd_stats_ics_nostatic.txt wpd_stats.txt
    cp wpd_func_name_to_id_nostatic.txt wpd_func_name_to_id.txt
    cp wpd_func_name_has_addr_taken_nostatic.txt wpd_func_name_has_addr_taken.txt
    cp bzip2_wpd_ics_nostatic bzip2_wpd
# elif [ "$1" == "wpd_ics_static" ]; then
#     BIN=bzip2_wpd_static
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
#     cp bzip2_wpd_static bzip2_wpd
elif [ "$1" == "wpd_cl_ics" ]; then
    BIN=bzip2_wpd_custlink_ics_nostatic
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
    #cp bzip2_wpd_custlink_ics_nostatic bzip2_wpd_custlink
# elif [ "$1" == "wpd_static" ]; then
#     BIN=bzip2_wpd_static
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
#     cp bzip2_wpd_static bzip2_wpd
else
    usage_exit
fi


# 2021.09.23 cporter note:
# 30/32 inputs are used. (a.txt and grammar.lsp are unused.)

{ time ./${BIN} -c < test/cp.html; } &> 1-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_1_$1.out
cp debrt.out debrt_1_$1.out

{ time ./${BIN} -c < test/fields.c; } &> 2-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_2_$1.out
cp debrt.out debrt_2_$1.out

{ time ./${BIN} -c < test/paper2; } &> 3-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_3_$1.out
cp debrt.out debrt_3_$1.out
{ time ./${BIN} -c < test/paper3; } &> 4-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_4_$1.out
cp debrt.out debrt_4_$1.out
{ time ./${BIN} -c < test/paper4; } &> 5-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_5_$1.out
cp debrt.out debrt_5_$1.out
{ time ./${BIN} -c < test/paper5; } &> 6-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_6_$1.out
cp debrt.out debrt_6_$1.out
{ time ./${BIN} -c < test/paper6; } &> 7-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_7_$1.out
cp debrt.out debrt_7_$1.out

{ time ./${BIN} -c < test/progc; } &> 8-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_8_$1.out
cp debrt.out debrt_8_$1.out
{ time ./${BIN} -c < test/progl; } &> 9-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_9_$1.out
cp debrt.out debrt_9_$1.out
{ time ./${BIN} -c < test/progp; } &> 10-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_10_$1.out
cp debrt.out debrt_progp_$1.out

{ time ./${BIN} -c < test/sum; } &> 11-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_11_$1.out
cp debrt.out debrt_11_$1.out
{ time ./${BIN} -c < test/trans; } &> 12-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_12_$1.out
cp debrt.out debrt_12_$1.out

{ time ./${BIN} -c < test/alice29.txt; } &> 13-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_13_$1.out
cp debrt.out debrt_13_$1.out
{ time ./${BIN} -c < test/alphabet.txt; } &> 14-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_14_$1.out
cp debrt.out debrt_14_$1.out
{ time ./${BIN} -c < test/asyoulik.txt; } &> 15-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_15_$1.out
cp debrt.out debrt_15_$1.out
{ time ./${BIN} -c < test/book2; } &> 16-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_16_$1.out
cp debrt.out debrt_16_$1.out

{ time ./${BIN} -c < test/geo; } &> 17-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_17_$1.out
cp debrt.out debrt_17_$1.out
{ time ./${BIN} -c < test/lcet10.txt; } &> 18-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_18_$1.out
cp debrt.out debrt_18_$1.out
{ time ./${BIN} -c < test/news; } &> 19-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_19_$1.out
cp debrt.out debrt_19_$1.out
{ time ./${BIN} -c < test/obj2; } &> 20-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_20_$1.out
cp debrt.out debrt_20_$1.out

{ time ./${BIN} -c < test/pic; } &> 21-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_21_$1.out
cp debrt.out debrt_21_$1.out
{ time ./${BIN} -c < test/plrabn12.txt; } &> 22-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_22_$1.out
cp debrt.out debrt_22_$1.out

{ time ./${BIN} -c < test/ptt5; } &> 23-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_23_$1.out
cp debrt.out debrt_23_$1.out

{ time ./${BIN} -c < test/random.txt; } &> 24-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_24_$1.out
cp debrt.out debrt_24_$1.out

{ time ./${BIN} -c < test/bible.txt; } &> 25-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_25_$1.out
cp debrt.out debrt_25_$1.out

{ time ./${BIN} -c < test/E.coli; } &> 26-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_26_$1.out
cp debrt.out debrt_26_$1.out

{ time ./${BIN} -c < test/kennedy.xls; } &> 27-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_27_$1.out
cp debrt.out debrt_27_$1.out

{ time ./${BIN} -c < test/pi.txt; } &> 28-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_28_$1.out
cp debrt.out debrt_28_$1.out

{ time ./${BIN} -c < test/world192.txt; } &> 29-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_29_$1.out
cp debrt.out debrt_29_$1.out

{ time ./${BIN} -c < test/xargs.1; } &> 30-${WHICH}.out
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_30_$1.out
cp debrt.out debrt_30_$1.out

