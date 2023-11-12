#!/bin/bash
set -euox pipefail

function usage_exit() {
    echo
    echo "Usage: ./run.sh <which-binary>"
    echo
    exit 1
}


if [ $# != 1 ]; then
    usage_exit
fi

WHICH=$1

BIN=10.flagboy_${WHICH}

source ${PROJ_DIR}/src/spec/2017/run_aux_preprocess.sh


{ time ./${BIN}; } &> ${WHICH}.out

source ${PROJ_DIR}/src/spec/2017/run_aux_postprocess.sh
