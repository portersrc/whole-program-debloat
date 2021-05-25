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
    BIN=544.nab_r_wpd
    WHICH=wpd
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
