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
    #505.mcf_r
    #508.namd_r
    510.parest_r
    #511.povray_r
    #519.lbm_r
    520.omnetpp_r
    523.xalancbmk_r
    #525.x264_r
    526.blender_r
    #531.deepsjeng_r
    #538.imagick_r
    #541.leela_r
    544.nab_r
    #557.xz_r
)

BMARKS_EASY=(
    505.mcf_r
    508.namd_r
    511.povray_r
    519.lbm_r
    525.x264_r
    531.deepsjeng_r
    538.imagick_r
    541.leela_r
    557.xz_r
)

BMARKS_MEDIUM=(
    500.perlbench_r
    544.nab_r
)

BMARKS_HARD=(
    502.gcc_r
    510.parest_r
    520.omnetpp_r
    523.xalancbmk_r
    526.blender_r
)


for BMARK in "${BMARKS[@]}"; do
#for BMARK in "${BMARKS_EASY[@]}"; do
#for BMARK in "${BMARKS_MEDIUM[@]}"; do
#for BMARK in "${BMARKS_HARD[@]}"; do

    BMARK_PATH=${SPEC_BASE_PATH}/${BMARK}/build/*peak*0
    BMARK_SHORT="${BMARK:4}"
    BMARK_SHORT="${BMARK_SHORT::-2}"

    #echo ${BMARK}
    #echo ${BMARK_SHORT}
    #echo ${BMARK_PATH}
    #echo

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
    #echo "TARGET EQUALS VAR IS: ${TARGET_EQUALS}"

    # Build and run profile
    pushd ${BMARK_PATH} &> /dev/null
    printf '%(%Y-%m-%d %H:%M:%S)T ' && echo "hack-log ${BMARK} build-profile"
    make artd_profile ${TARGET_EQUALS}; echo $?
    printf '%(%Y-%m-%d %H:%M:%S)T ' && echo "hack-log ${BMARK} run-profile"
    DEBRT_ENABLE_STATS=1 DEBRT_ENABLE_PROFILING=1 ./run.sh artd_profile small; echo $?
    popd &> /dev/null
    

    # Parse profile and train
    pushd ${PARSER_BASE_PATH} &> /dev/null
    printf '%(%Y-%m-%d %H:%M:%S)T ' && echo "hack-log ${BMARK} parse-profile"
    ./parse_artd_profile_log.py ${BMARK_PATH}; echo $?
    popd &> /dev/null
    pushd ${DT_BASE_PATH}/${BMARK_SHORT} &> /dev/null
    printf '%(%Y-%m-%d %H:%M:%S)T ' && echo "hack-log ${BMARK} train"
    ./learn_dt.py -csv_file_name training-data.out; echo $?
    popd &> /dev/null

    # Switch the DT header file and rebuild the project
    pushd ${RT_BASE_PATH} &> /dev/null
    printf '%(%Y-%m-%d %H:%M:%S)T ' && echo "hack-log ${BMARK} switch-dt"
    ./switch_dt.sh ${BMARK_SHORT}
    touch debloat_rt.cpp
    popd &> /dev/null
    pushd ${PROJ_BASE_PATH}/build &> /dev/null
    printf '%(%Y-%m-%d %H:%M:%S)T ' && echo "hack-log ${BMARK} rebuild-pasture"
    make
    popd &> /dev/null

    # Build and run test-predict
    #pushd ${BMARK_PATH} &> /dev/null
    #make artd_test_predict ${TARGET_EQUALS}; echo $?
    #DEBRT_ENABLE_TEST_PREDICTION=1 ./run.sh artd_test_predict small; echo $?
    #popd &> /dev/null

    # Build and run release
    pushd ${BMARK_PATH} &> /dev/null
    printf '%(%Y-%m-%d %H:%M:%S)T ' && echo "hack-log ${BMARK} build-release"
    make artd_release ${TARGET_EQUALS}; echo $?
    printf '%(%Y-%m-%d %H:%M:%S)T ' && echo "hack-log ${BMARK} run-release"
    DEBRT_ENABLE_RELEASE=1 ./run.sh artd_release large; echo $?
    popd &> /dev/null

    printf '%(%Y-%m-%d %H:%M:%S)T ' && echo "hack-log ${BMARK} successfully-completed"

done
