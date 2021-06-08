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
    BIN=538.imagick_r_baseline
    WHICH=base
elif [ "$1" == "base_ls" ]; then
    BIN=538.imagick_r_baseline_ls
    WHICH=base_ls
elif [ "$1" == "wpd" ]; then
    BIN=538.imagick_r_wpd
    WHICH=wpd
elif [ "$1" == "wpd_cl" ]; then
    BIN=538.imagick_r_wpd_clustlink
    WHICH=wpd_cl
elif [ "$1" == "wpd_ls" ]; then
    BIN=538.imagick_r_wpd_ls
    WHICH=wpd_ls
else
    usage_exit
fi

if [ "$2" == "small" ]; then
    { time ./${BIN} -limit disk 0 test_input.tga -shear 25 -resize 640x480 -negate -alpha Off test_output.tga; } &> small-${WHICH}.out
elif [ "$2" == "medium" ]; then
    { time ./${BIN} -limit disk 0 train_input.tga -resize 320x240 -shear 31 -edge 140 -negate -flop -resize 900x900 -edge 10 train_output.tga; } &> medium-${WHICH}.out
elif [ "$2" == "large" ]; then
    { time ./${BIN} -limit disk 0 refrate_input.tga -edge 41 -resample 181% -emboss 31 -colorspace YUV -mean-shift 19x19+15% -resize 30% refrate_output.tga; } &> large-${WHICH}.out
else
    usage_exit
fi
