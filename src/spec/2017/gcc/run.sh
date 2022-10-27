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

BIN=502.gcc_r_${WHICH}


if [ "${INPUT}" == "small" ]; then
    { time ./${BIN} t1.c -O3 -finline-limit=50000; } &> small-${WHICH}.out
elif [ "${INPUT}" == "medium" ]; then
    { time ./${BIN} 200.c -O3 -finline-limit=50000; } &> medium-${WHICH}.out
    #{ time ./${BIN} scilab.c -O3 -finline-limit=50000; } &> medium-${WHICH}.out
    #{ time ./${BIN} train01.c -O3 -finline-limit=50000; } &> medium-${WHICH}.out
elif [ "${INPUT}" == "large" ]; then
    { time ./${BIN} gcc-pp.c -O3 -finline-limit=0 -fif-conversion -fif-conversion2; } &> large-${WHICH}.out
    #{ time ./${BIN} gcc-pp.c -O2 -finline-limit=36000 -fpic; } &> large-${WHICH}.out
    #{ time ./${BIN} gcc-smaller.c -O3 -fipa-pta; } &> large-${WHICH}.out
    #{ time ./${BIN} ref32.c -O5; } &> large-${WHICH}.out
    #{ time ./${BIN} ref32.c -O3 -fselective-scheduling -fselective-scheduling2; } &> large-${WHICH}.out
else
    usage_exit
fi
