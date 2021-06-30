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
    BIN=544.nab_r_baseline
    WHICH=base
elif [ "$1" == "base_ls" ]; then
    BIN=544.nab_r_baseline_ls
    WHICH=base_ls
elif [ "$1" == "wpd" ]; then
    BIN=544.nab_r_wpd_base
    WHICH=wpd
elif [ "$1" == "wpd_sink" ]; then
    BIN=544.nab_r_wpd_sink
    WHICH=wpd_sink
elif [ "$1" == "wpd_ics" ]; then
    BIN=544.nab_r_wpd_ics
    WHICH=wpd_ics
elif [ "$1" == "wpd_cl" ]; then
    BIN=544.nab_r_wpd_custlink
    WHICH=wpd_cl
elif [ "$1" == "wpd_cl_sink" ]; then
    BIN=544.nab_r_wpd_custlink_sink
    WHICH=wpd_cl_sink
elif [ "$1" == "wpd_cl_ics" ]; then
    BIN=544.nab_r_wpd_custlink_ics
    WHICH=wpd_cl_ics
elif [ "$1" == "wpd_ls" ]; then
    BIN=544.nab_r_wpd_ls
    WHICH=wpd_ls
else
    usage_exit
fi

if [ "$2" == "small" ]; then
    { time ./${BIN} hkrdenq 1930344093 1000; } &> small-${WHICH}.out
elif [ "$2" == "medium" ]; then
    { time ./${BIN} aminos 391519156 1000; } &> medium-${WHICH}.out
    # 2nd medium input if i want to try:
    #{ time ./${BIN} gcn4dna 1850041461 300; } &> medium2-${WHICH}.out
elif [ "$2" == "large" ]; then
    { time ./${BIN} 1am0 1122214447 122; } &> large-${WHICH}.out
else
    usage_exit
fi
cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_$1.out
cp debrt.out debrt_$1.out
