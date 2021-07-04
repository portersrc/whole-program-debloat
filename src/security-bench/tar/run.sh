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
    BIN=tar_nostatic
    WHICH=base_ls
    cp tar_nostatic tar
elif [ "$1" == "base_ls_static" ]; then
    BIN=tar_static
    WHICH=base_ls_static
    cp tar_static tar
elif [ "$1" == "wpd" ]; then
    BIN=tar_wpd_nostatic
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
    cp tar_wpd_nostatic tar_wpd
elif [ "$1" == "wpd_static" ]; then
    BIN=tar_wpd_static
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
    cp tar_wpd_static tar_wpd
elif [ "$1" == "wpd_cl" ]; then
    BIN=tar_wpd_custlink_nostatic
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
    cp tar_wpd_custlink_nostatic tar_wpd_custlink
elif [ "$1" == "wpd_cl_static" ]; then
    BIN=tar_wpd_custlink_static
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
    cp tar_wpd_custlink_static tar_wpd_custlink
else
    usage_exit
fi

if [ "$2" == "small" ]; then
    # { time ./${BIN} cf tmp.tar test/cp.html; } &> small-${WHICH}.out
    # { time ./${BIN} cf tmp.tar test/fields.c; } &> small-${WHICH}.out
    # { time ./${BIN} cf tmp.tar test/paper2; } &> small-${WHICH}.out
    # { time ./${BIN} cf tmp.tar test/paper3; } &> small-${WHICH}.out
    # { time ./${BIN} cf tmp.tar test/paper4; } &> small-${WHICH}.out
    # { time ./${BIN} cf tmp.tar test/paper5; } &> small-${WHICH}.out
    # { time ./${BIN} cf tmp.tar test/paper6; } &> small-${WHICH}.out
    # { time ./${BIN} cf tmp.tar test/progc; } &> small-${WHICH}.out
    # { time ./${BIN} cf tmp.tar test/progl; } &> small-${WHICH}.out
    # { time ./${BIN} cf tmp.tar test/progp; } &> small-${WHICH}.out
    # { time ./${BIN} cf tmp.tar test/sum; } &> small-${WHICH}.out
    { time ./${BIN} cf tmp.tar test/trans; } &> small-${WHICH}.out
elif [ "$2" == "medium" ]; then
    # { time ./${BIN} cf tmp.tar test/alice29.txt; } &> medium-${WHICH}.out
    # { time ./${BIN} cf tmp.tar test/alphabet.txt; } &> medium-${WHICH}.out
    # { time ./${BIN} cf tmp.tar test/asyoulik.txt; } &> medium-${WHICH}.out
    # { time ./${BIN} cf tmp.tar test/book2; } &> medium-${WHICH}.out
    # { time ./${BIN} cf tmp.tar test/geo; } &> medium-${WHICH}.out
    # { time ./${BIN} cf tmp.tar test/lcet10.txt; } &> medium-${WHICH}.out
    # { time ./${BIN} cf tmp.tar test/news; } &> medium-${WHICH}.out
    # { time ./${BIN} cf tmp.tar test/obj2; } &> medium-${WHICH}.out
    { time ./${BIN} cf tmp.tar  test/pic; } &> medium-${WHICH}.out
    # { time ./${BIN} cf tmp.tar test/plrabn12.txt; } &> medium-${WHICH}.out
    # { time ./${BIN} cf tmp.tar test/ptt5; } &> medium-${WHICH}.out
    # { time ./${BIN} cf tmp.tar test/random.txt; } &> medium-${WHICH}.out
elif [ "$2" == "large" ]; then
    # { time ./${BIN} cf tmp.tar test/bible.txt; } &> large-${WHICH}.out
    { time ./${BIN} cf tmp.tar  test/E.coli; } &> large-${WHICH}.out
    # { time ./${BIN} cf tmp.tar test/kennedy.xls; } &> large-${WHICH}.out
    # { time ./${BIN} cf tmp.tar test/pi.txt; } &> large-${WHICH}.out
    # { time ./${BIN} cf tmp.tar test/world192.txt; } &> large-${WHICH}.out
else
    usage_exit
fi

cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_$1.out
cp debrt.out debrt_$1.out
