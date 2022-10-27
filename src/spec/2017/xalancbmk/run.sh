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

BIN=523.xalancbmk_${WHICH}

source ${PROJ_DIR}/src/spec/2017/run_aux_preprocess.sh


if [ "${INPUT}" == "small" ]; then
    { time ./${BIN} -v test.xml small.xsl; } &> small-${WHICH}.out
elif [ "${INPUT}" == "medium" ]; then
    { time ./${BIN} -v allbooks.xml medium.xsl; } &> medium-${WHICH}.out
elif [ "${INPUT}" == "large" ]; then
    { time ./${BIN} -v t5.xml large.xsl; } &> large-${WHICH}.out
else
    usage_exit
fi

source ${PROJ_DIR}/src/spec/2017/run_aux_postprocess.sh
