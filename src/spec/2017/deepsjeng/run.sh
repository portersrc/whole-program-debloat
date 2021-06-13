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
    BIN=531.deepsjeng_r_baseline
    WHICH=base
elif [ "$1" == "base_ls" ]; then
    BIN=531.deepsjeng_r_baseline_ls
    WHICH=base_ls
elif [ "$1" == "wpd" ]; then
    BIN=531.deepsjeng_r_wpd_base
    WHICH=wpd
elif [ "$1" == "wpd_sink" ]; then
    BIN=531.deepsjeng_r_wpd_sink
    WHICH=wpd_sink
elif [ "$1" == "wpd_cl" ]; then
    BIN=531.deepsjeng_r_wpd_custlink
    WHICH=wpd_cl
elif [ "$1" == "wpd_cl_sink" ]; then
    BIN=531.deepsjeng_r_wpd_custlink_sink
    WHICH=wpd_cl_sink
elif [ "$1" == "wpd_ls" ]; then
    BIN=531.deepsjeng_r_wpd_ls
    WHICH=wpd_ls
else
    usage_exit
fi

if [ "$2" == "small" ]; then
    { time ./${BIN} test.txt; } &> small-${WHICH}.out
elif [ "$2" == "medium" ]; then
    { time ./${BIN} train.txt; } &> medium-${WHICH}.out
elif [ "$2" == "large" ]; then
    { time ./${BIN} ref.txt; } &> large-${WHICH}.out
else
    usage_exit
fi

cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_$1.out
cp debrt.out debrt_$1.out
