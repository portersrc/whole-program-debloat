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
    BIN=505.mcf_r_baseline
    WHICH=base
elif [ "$1" == "base_ls" ]; then
    BIN=505.mcf_r_baseline_ls
    WHICH=base_ls
elif [ "$1" == "wpd" ]; then
    BIN=505.mcf_r_wpd
    WHICH=wpd
else
    usage_exit
fi

if [ "$2" == "small" ]; then
    { time ./${BIN} small-inp.in; } &> small-${WHICH}.out
elif [ "$2" == "medium" ]; then
    { time ./${BIN} medium-inp.in; } &> medium-${WHICH}.out
elif [ "$2" == "large" ]; then
    { time ./${BIN} large-inp.in; } &> large-${WHICH}.out
else
    usage_exit
fi
