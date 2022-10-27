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

BIN=544.nab_r_${WHICH}

source ${PROJ_DIR}/src/spec/2017/run_aux_preprocess.sh


if [ "${INPUT}" == "small" ]; then
    { time ./${BIN} hkrdenq 1930344093 1000; } &> small-${WHICH}.out
elif [ "${INPUT}" == "medium" ]; then
    { time ./${BIN} aminos 391519156 1000; } &> medium-${WHICH}.out
    # 2nd medium input if i want to try:
    #{ time ./${BIN} gcn4dna 1850041461 300; } &> medium2-${WHICH}.out
elif [ "${INPUT}" == "large" ]; then
    { time ./${BIN} 1am0 1122214447 122; } &> large-${WHICH}.out
else
    usage_exit
fi

source ${PROJ_DIR}/src/spec/2017/run_aux_postprocess.sh
