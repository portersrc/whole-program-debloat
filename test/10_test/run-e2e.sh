#!/bin/bash
set -euxo pipefail

#
# Salt to taste...
#


DT_BASE_PATH=/home/rudy/wo/advanced-rtd/whole-program-debloat/src/learning/decision_tree
RT_BASE_PATH=/home/rudy/wo/advanced-rtd/whole-program-debloat/src/debloat_rt
PROJ_BASE_PATH=/home/rudy/wo/advanced-rtd/whole-program-debloat
BMARK_NAME=10-test

# Build and run profile
make artd_profile ; echo $?
DEBRT_ENABLE_STATS=1 DEBRT_ENABLE_PROFILING=1 ./run.sh artd_profile; echo $?

# Parse profile and train
./parse_artd_profile_log.py .; echo $?
pushd ${DT_BASE_PATH}/${BMARK_NAME} &> /dev/null
./learn_dt.py -csv_file_name training-data.out; echo $?
popd &> /dev/null

# Switch the DT header file and rebuild the project
pushd ${RT_BASE_PATH} &> /dev/null
./switch_dt.sh ${BMARK_NAME}
touch debloat_rt.cpp
popd &> /dev/null
pushd ${PROJ_BASE_PATH}/build &> /dev/null
make
popd &> /dev/null

# Build and run release
make artd_release; echo $?
DEBRT_ENABLE_RELEASE=1 ./run.sh artd_release; echo $?
