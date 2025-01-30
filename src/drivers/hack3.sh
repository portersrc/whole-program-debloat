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
    #500.perlbench_r
    ##502.gcc_r
    505.mcf_r
    508.namd_r
    510.parest_r
    511.povray_r
    519.lbm_r
    ##520.omnetpp_r
    523.xalancbmk_r
    525.x264_r
    526.blender_r
    531.deepsjeng_r
    538.imagick_r
    541.leela_r
    544.nab_r
    557.xz_r
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

    # Switch the DT header file and rebuild the project
    pushd ${RT_BASE_PATH} &> /dev/null
    ./switch_dt.sh ${BMARK_SHORT}
    touch debloat_rt.cpp
    popd &> /dev/null
    pushd ${PROJ_BASE_PATH}/build &> /dev/null
    make
    popd &> /dev/null


    # Run test-predict
    #pushd ${BMARK_PATH} &> /dev/null
    #DEBRT_ENABLE_TEST_PREDICTION=1 ./run.sh artd_test_predict medium; echo $?
    #popd &> /dev/null


    # Run release
    pushd ${BMARK_PATH} &> /dev/null
    # debugging  with small input
    #DEBRT_ENABLE_RELEASE=1 ./run.sh artd_release small; echo $?

    # debugging  with medium input
    #DEBRT_ENABLE_RELEASE=1 ./run.sh artd_release medium; echo $?

    # performance
    #./run.sh base large; echo $?
    DEBRT_ENABLE_RELEASE=1 ./run.sh artd_release large; echo $?

    # security
    #DEBRT_ENABLE_STATS=1 DEBRT_ENABLE_RELEASE=1 ./run.sh artd_release large; echo $?
    popd &> /dev/null

done
