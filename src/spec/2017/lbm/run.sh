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

WHICH=$1
INPUT=$2

BIN=519.lbm_r_${WHICH}


if [ "$2" == "small" ]; then
    { time ./${BIN} 20 reference.dat 0 1 100_100_130_cf_a.of; } &> small-${WHICH}.out
elif [ "$2" == "medium" ]; then
    { time ./${BIN} 300 reference.dat 0 1 100_100_130_cf_b.of; } &> medium-${WHICH}.out
elif [ "$2" == "large" ]; then
    { time ./${BIN} 3000 reference.dat 0 0 100_100_130_ldc.of; } &> large-${WHICH}.out
else
    usage_exit
fi
