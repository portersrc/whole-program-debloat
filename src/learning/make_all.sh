#!/bin/bash
set -euxo pipefail

#
# Salt to taste...
#


SPEC_BASE_PATH=/home/rudy/wo/spec/spec2017/benchspec/CPU
PARSER_BASE_PATH=/home/rudy/wo/advanced-rtd/whole-program-debloat/src/learning
DT_BASE_PATH=/home/rudy/wo/advanced-rtd/whole-program-debloat/src/learning/decision_tree
RT_BASE_PATH=/home/rudy/wo/advanced-rtd/whole-program-debloat/src/debloat_rt
PROJ_BASE_PATH=/home/rudy/wo/advanced-rtd/whole-program-debloat

# all
BMARKS=(
    500.perlbench_r
    502.gcc_r
    505.mcf_r
    508.namd_r
    510.parest_r
    511.povray_r
    519.lbm_r
    520.omnetpp_r
    #523.xalancbmk_r
    525.x264_r
    526.blender_r
    531.deepsjeng_r
    538.imagick_r
    541.leela_r
    544.nab_r
    557.xz_r
)



for BMARK in "${BMARKS[@]}"; do

    BMARK_PATH=${SPEC_BASE_PATH}/${BMARK}/build/*peak*0
    BMARK_SHORT="${BMARK:4}"
    BMARK_SHORT="${BMARK_SHORT::-2}"

    # Quickly hack the TARGET= cases in...
    TARGET_EQUALS=""
    if [ "${BMARK_SHORT}" == "povray" ]; then
        TARGET_EQUALS="TARGET=povray_r"
    elif [ "${BMARK_SHORT}" == "x264" ]; then
        TARGET_EQUALS="TARGET=x264_r"
    elif [ "${BMARK_SHORT}" == "blender" ]; then
        TARGET_EQUALS="TARGET=blender_r"
    elif [ "${BMARK_SHORT}" == "imagick" ]; then
        TARGET_EQUALS="TARGET=imagick_r"
    fi

    # Build
    echo "Building $BMARK_SHORT"
    pushd ${BMARK_PATH} &> /dev/null
    #make artd_profile ${TARGET_EQUALS} &> /dev/null &
    make artd_release ${TARGET_EQUALS} &> /dev/null &
    popd &> /dev/null
    
done

date
echo "Waiting for jobs to complete. Should take ~17min (blender is slowest)"
wait
echo "Done. Exiting. Double-check the binaries' timestamps are good"
date
