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

if [ "$1" == "base" ]; then
    BIN=502.gcc_r_baseline
    WHICH=base
elif [ "$1" == "base_ls" ]; then
    BIN=502.gcc_r_baseline_ls
    WHICH=base_ls
elif [ "$1" == "wpd" ]; then
    BIN=502.gcc_r_wpd_base
    WHICH=wpd
elif [ "$1" == "wpd_sink" ]; then
    BIN=502.gcc_r_wpd_sink
    WHICH=wpd_sink
elif [ "$1" == "wpd_ics" ]; then
    BIN=502.gcc_r_wpd_ics
    WHICH=wpd_ics
elif [ "$1" == "wpd_bicsa" ]; then
    BIN=502.gcc_r_wpd_bicsa
    WHICH=wpd_bicsa
elif [ "$1" == "wpd_cl" ]; then
    BIN=502.gcc_r_wpd_custlink
    WHICH=wpd_cl
elif [ "$1" == "wpd_cl_sink" ]; then
    BIN=502.gcc_r_wpd_custlink_sink
    WHICH=wpd_cl_sink
elif [ "$1" == "wpd_cl_ics" ]; then
    BIN=502.gcc_r_wpd_custlink_ics
    WHICH=wpd_cl_ics
elif [ "$1" == "wpd_cl_bicsa" ]; then
    BIN=502.gcc_r_wpd_custlink_bicsa
    WHICH=wpd_cl_bicsa
elif [ "$1" == "wpd_ls" ]; then
    BIN=502.gcc_r_wpd_ls
    WHICH=wpd_ls
else
    usage_exit
fi

if [ "$2" == "small" ]; then
    { time ./${BIN} t1.c -O3 -finline-limit=50000; } &> small-${WHICH}.out
elif [ "$2" == "medium" ]; then
    { time ./${BIN} 200.c -O3 -finline-limit=50000; } &> medium-${WHICH}.out
    #{ time ./${BIN} scilab.c -O3 -finline-limit=50000; } &> medium-${WHICH}.out
    #{ time ./${BIN} train01.c -O3 -finline-limit=50000; } &> medium-${WHICH}.out
elif [ "$2" == "large" ]; then
    { time ./${BIN} gcc-pp.c -O3 -finline-limit=0 -fif-conversion -fif-conversion2; } &> large-${WHICH}.out
    #{ time ./${BIN} gcc-pp.c -O2 -finline-limit=36000 -fpic; } &> large-${WHICH}.out
    #{ time ./${BIN} gcc-smaller.c -O3 -fipa-pta; } &> large-${WHICH}.out
    #{ time ./${BIN} ref32.c -O5; } &> large-${WHICH}.out
    #{ time ./${BIN} ref32.c -O3 -fselective-scheduling -fselective-scheduling2; } &> large-${WHICH}.out
else
    usage_exit
fi

cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_$1.out
cp debrt.out debrt_$1.out
