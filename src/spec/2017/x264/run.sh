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

BIN=525.x264_r_${WHICH}

source ${PROJ_DIR}/src/spec/2017/run_aux_preprocess.sh


if [ "${INPUT}" == "small" ]; then
    { time ./${BIN} --dumpyuv 50 --frames 156 -o BuckBunny_New.264 small.yuv 1280x720; } &> small-${WHICH}.out
elif [ "${INPUT}" == "medium" ]; then
    { time ./${BIN} --dumpyuv 50 --frames 142 -o BuckBunny_New.264 medium.yuv 1280x720; } &> medium-${WHICH}.out
elif [ "${INPUT}" == "large" ]; then
    # 2nd input has the longest runtime, which even then is only ~3s
    #{ time ./${BIN} --pass 1 --stats x264_stats.log --bitrate 1000 --frames 1000 -o BuckBunny_New.264 large.yuv 1280x720; } &> large-${WHICH}.out
    # more large inputs if i want to try:
    { time ./${BIN} --pass 2 --stats x264_stats.log --bitrate 1000 --dumpyuv 200 --frames 1000 -o BuckBunny_New.264 large.yuv 1280x720; } &> large-${WHICH}.out
    #{ time ./${BIN} --seek 500 --dumpyuv 200 --frames 1250 -o BuckBunny_New.264 large.yuv 1280x720; } &> large-${WHICH}.out
else
    usage_exit
fi

source ${PROJ_DIR}/src/spec/2017/run_aux_postprocess.sh
