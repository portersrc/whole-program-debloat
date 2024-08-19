#!/bin/bash
#set -x
#set -eo pipefail


SPEC_ROOT=/root/decker/spec2017
SPEC_BMARKS_PATH=${SPEC_ROOT}/benchspec/CPU
SPEC_BUILD_FOLDER_SUFFIX=build/build_peak_mytest-m64.0000

BMARKS=(
    500.perlbench_r
    502.gcc_r
    505.mcf_r
    508.namd_r
    510.parest_r
    511.povray_r
    519.lbm_r
    520.omnetpp_r
    523.xalancbmk_r
    525.x264_r
    526.blender_r
    531.deepsjeng_r
    538.imagick_r
    541.leela_r
    544.nab_r
    557.xz_r
)


function copy_results() {
    echo "Copying results..."
    mkdir tmp_result
    pushd tmp_result
    for BMARK in ${BMARKS[@]}; do
        mkdir $BMARK
        cp -p $SPEC_BMARKS_PATH/$BMARK/$SPEC_BUILD_FOLDER_SUFFIX/large*.out $BMARK
        cp -p $SPEC_BMARKS_PATH/$BMARK/$SPEC_BUILD_FOLDER_SUFFIX/debrt*.out $BMARK
        cp -p $SPEC_BMARKS_PATH/$BMARK/$SPEC_BUILD_FOLDER_SUFFIX/wpd_stats*.txt $BMARK
    done
    popd
}

copy_results
