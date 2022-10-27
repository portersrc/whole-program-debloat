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

BIN=505.mcf_r_${WHICH}


if [ "${INPUT}" == "small" ]; then
    { time ./${BIN} small-inp.in; } &> small-${WHICH}.out
elif [ "${INPUT}" == "medium" ]; then
    { time ./${BIN} medium-inp.in; } &> medium-${WHICH}.out
elif [ "${INPUT}" == "large" ]; then
    { time ./${BIN} large-inp.in; } &> large-${WHICH}.out
else
    usage_exit
fi
