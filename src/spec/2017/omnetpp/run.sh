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
    BIN=520.omnetpp_r_baseline
    WHICH=base
elif [ "$1" == "base_ls" ]; then
    BIN=520.omnetpp_r_baseline_ls
    WHICH=base_ls
elif [ "$1" == "wpd" ]; then
    BIN=520.omnetpp_r_wpd
    WHICH=wpd
elif [ "$1" == "wpd_cl" ]; then
    BIN=520.omnetpp_r_wpd_custlink
    WHICH=wpd_cl
elif [ "$1" == "wpd_ls" ]; then
    BIN=520.omnetpp_r_wpd_ls
    WHICH=wpd_ls
else
    usage_exit
fi

if [ "$2" == "small" ]; then
    { time ./${BIN} -f small.ini -c General -r 0; } &> small-${WHICH}.out
elif [ "$2" == "medium" ]; then
    { time ./${BIN} -f medium.ini -c General -r 0; } &> medium-${WHICH}.out
elif [ "$2" == "large" ]; then
    { time ./${BIN} -f large.ini -c General -r 0; } &> large-${WHICH}.out
else
    usage_exit
fi
