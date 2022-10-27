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

BIN=538.imagick_r_${WHICH}

source ${PROJ_DIR}/src/spec/2017/run_aux_preprocess.sh


if [ "${INPUT}" == "small" ]; then
    { time ./${BIN} -limit disk 0 test_input.tga -shear 25 -resize 640x480 -negate -alpha Off test_output.tga; } &> small-${WHICH}.out
elif [ "${INPUT}" == "medium" ]; then
    { time ./${BIN} -limit disk 0 train_input.tga -resize 320x240 -shear 31 -edge 140 -negate -flop -resize 900x900 -edge 10 train_output.tga; } &> medium-${WHICH}.out
elif [ "${INPUT}" == "large" ]; then
    { time ./${BIN} -limit disk 0 refrate_input.tga -edge 41 -resample 181% -emboss 31 -colorspace YUV -mean-shift 19x19+15% -resize 30% refrate_output.tga; } &> large-${WHICH}.out
else
    usage_exit
fi

source ${PROJ_DIR}/src/spec/2017/run_aux_postprocess.sh
