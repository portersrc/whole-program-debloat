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

BIN=511.povray_r_${WHICH}

if [ "${INPUT}" == "small" ]; then
    { time ./${BIN} SPEC-benchmark-test.ini +L/root/decker/spec2017/benchspec/CPU/511.povray_r/data/all/input; } &> small-${WHICH}.out
elif [ "${INPUT}" == "medium" ]; then
    { time ./${BIN} SPEC-benchmark-train.ini +L/root/decker/spec2017/benchspec/CPU/511.povray_r/data/all/input; } &> medium-${WHICH}.out
elif [ "${INPUT}" == "large" ]; then
    { time ./${BIN} SPEC-benchmark-ref.ini +L/root/decker/spec2017/benchspec/CPU/511.povray_r/data/all/input; } &> large-${WHICH}.out
else
    usage_exit
fi
