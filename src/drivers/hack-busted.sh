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
    523.xalancbmk_r
    525.x264_r
    526.blender_r
    531.deepsjeng_r
    538.imagick_r
    541.leela_r
    544.nab_r
    557.xz_r
)

PIDS=()


# Build profile binaries in parallel, up to 8 at a time

echo "MY SHELL PID top: $$"


for BMARK in "${BMARKS[@]}"; do

    echo "MY SHELL PID for-loop: $$"
    BMARK_PATH=${SPEC_BASE_PATH}/${BMARK}/build/*peak*0
    BMARK_SHORT="${BMARK:4}"
    BMARK_SHORT="${BMARK_SHORT::-2}"

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

    ./a.out &
    PIDS+=($!)

    #NUM_JOBS=`jobs | wc -l`
    #echo "Number of jobs: ${NUM_JOBS}"
    #while [ $NUM_JOBS -eq 8 ]; do
    #    echo "Sleeping 3s b/c number of jobs is 8"
    #    sleep 3
    #    NUM_JOBS=`jobs | wc -l`
    #done
    #echo "Jobs count is not 8. Continuing."

    #while [ `jobs | wc -l` -eq 8 ]; do
    #    echo "Sleeping 3s b/c number of jobs is 8"
    #    sleep 3
    #done
    #echo "Jobs count is not 8. Continuing."

    
done

echo "MY SHELL PID outside for-loop: $$"

echo "Waiting for all jobs to complete (no error checking yet)"
wait


echo "MY SHELL PID before cycling: $$"

echo "All jobs completed."
echo "Cycling over PIDS with 'wait' to make sure there were no errors"
for P in "${PIDS[@]}"; do
    wait $P
done


echo "MY SHELL PID at exit: $$"
echo "Done"

