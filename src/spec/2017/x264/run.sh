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

if [ "$1" == "base" ]; then
    BIN=525.x264_r_baseline
    WHICH=base
elif [ "$1" == "base_ls" ]; then
    BIN=525.x264_r_baseline_ls
    WHICH=base_ls
elif [ "$1" == "wpd" ]; then
    BIN=525.x264_r_wpd_base
    WHICH=wpd
elif [ "$1" == "wpd_sink" ]; then
    BIN=525.x264_r_wpd_sink
    WHICH=wpd_sink
elif [ "$1" == "wpd_ics" ]; then
    BIN=525.x264_r_wpd_ics
    WHICH=wpd_ics
elif [ "$1" == "wpd_cl" ]; then
    BIN=525.x264_r_wpd_custlink
    WHICH=wpd_cl
elif [ "$1" == "wpd_cl_sink" ]; then
    BIN=525.x264_r_wpd_custlink_sink
    WHICH=wpd_cl_sink
elif [ "$1" == "wpd_cl_ics" ]; then
    BIN=525.x264_r_wpd_custlink_ics
    WHICH=wpd_cl_ics
elif [ "$1" == "wpd_ls" ]; then
    BIN=525.x264_r_wpd_ls
    WHICH=wpd_ls
else
    usage_exit
fi

if [ "$2" == "small" ]; then
    { time ./${BIN} --dumpyuv 50 --frames 156 -o BuckBunny_New.264 small.yuv 1280x720; } &> small-${WHICH}.out
elif [ "$2" == "medium" ]; then
    { time ./${BIN} --dumpyuv 50 --frames 142 -o BuckBunny_New.264 medium.yuv 1280x720; } &> medium-${WHICH}.out
elif [ "$2" == "large" ]; then
    # 2nd input has the longest runtime, which even then is only ~3s
    #{ time ./${BIN} --pass 1 --stats x264_stats.log --bitrate 1000 --frames 1000 -o BuckBunny_New.264 large.yuv 1280x720; } &> large-${WHICH}.out
    # more large inputs if i want to try:
    { time ./${BIN} --pass 2 --stats x264_stats.log --bitrate 1000 --dumpyuv 200 --frames 1000 -o BuckBunny_New.264 large.yuv 1280x720; } &> large2-${WHICH}.out
    #{ time ./${BIN} --seek 500 --dumpyuv 200 --frames 1250 -o BuckBunny_New.264 large.yuv 1280x720; } &> large3-${WHICH}.out
else
    usage_exit
fi

cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_$1.out
cp debrt.out debrt_$1.out
