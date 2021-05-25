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
    BIN=531.deepsjeng_r_wpd
    WHICH=wpd
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
