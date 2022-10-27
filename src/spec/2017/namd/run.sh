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

BIN=508.namd_r_${WHICH}


if [ "${INPUT}" == "small" ]; then
    { time ./${BIN} --input apoa1.input --iterations 1 --output apoa1.test.output; } &> small-${WHICH}.out
elif [ "${INPUT}" == "medium" ]; then
    { time ./${BIN} --input apoa1.input --iterations 7 --output apoa1.train.output; } &> medium-${WHICH}.out
elif [ "${INPUT}" == "large" ]; then
    { time ./${BIN} --input apoa1.input --iterations 65 --output apoa1.ref.output; } &> large-${WHICH}.out
else
    usage_exit
fi
