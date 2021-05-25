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
    BIN=526.blender_r_baseline
    WHICH=base
elif [ "$1" == "base_ls" ]; then
    BIN=526.blender_r_baseline_ls
    WHICH=base_ls
elif [ "$1" == "wpd" ]; then
    BIN=526.blender_r_wpd
    WHICH=wpd
else
    usage_exit
fi

if [ "$2" == "small" ]; then
    { time ./${BIN} cube.blend --render-output cube_ --threads 1 -b -F RAWTGA -s 1 -e 1 -a; } &> small-${WHICH}.out
elif [ "$2" == "medium" ]; then
    { time ./${BIN} sh5_reduced.blend --render-output sh5_reduced_ --threads 1 -b -F RAWTGA -s 234 -e 234 -a; } &> medium-${WHICH}.out
elif [ "$2" == "large" ]; then
    { time ./${BIN} sh3_no_char.blend --render-output sh3_no_char_ --threads 1 -b -F RAWTGA -s 849 -e 849 -a; } &> large-${WHICH}.out
else
    usage_exit
fi
