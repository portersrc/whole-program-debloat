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

BIN=520.omnetpp_r_${WHICH}


if [ "${INPUT}" == "small" ]; then
    { time ./${BIN} -f small.ini -c General -r 0; } &> small-${WHICH}.out
elif [ "${INPUT}" == "medium" ]; then
    { time ./${BIN} -f medium.ini -c General -r 0; } &> medium-${WHICH}.out
elif [ "${INPUT}" == "large" ]; then
    { time ./${BIN} -f large.ini -c General -r 0; } &> large-${WHICH}.out
else
    usage_exit
fi
