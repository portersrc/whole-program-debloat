#!/bin/bash



#CSV_FILENAME=train_data.csv
#TEST_CSV_FILENAME=test_data.csv

#SAVE_PLOTS=saved_dectree
#OUTPUT_FILE=outch


#CSV_FILENAME=/home/rudy/wo/whole-program-debloat/foo/ubench/mat_mult_ptr/train-final-debprof.out
#TEST_CSV_FILENAME=/home/rudy/wo/whole-program-debloat/foo/ubench/mat_mult_ptr/test-final-debprof.out

#CSV_FILENAME=/home/rudy/wo/whole-program-debloat/foo/ubench/mat_mult_ptr/train-final-debprof.out
#TEST_CSV_FILENAME=/home/rudy/wo/whole-program-debloat/foo/ubench/mat_mult_ptr/test-final-debprof.out



# bzip
#BMARK_NAME=bzip
#BASE_PATH=/home/rudy/wo/spec/spec2006/benchspec/CPU2006/401.bzip2/build/build_base_amd64-m64-gcc43-nn.0000

# gcc
#BASE_PATH=/home/rudy/wo/spec/spec2006/benchspec/CPU2006/403.gcc/build/build_base_amd64-m64-gcc43-nn.0000
#CSV_FILENAME=${BASE_PATH}/final-train-debprof.out
#TEST_CSV_FILENAME=${BASE_PATH}/final-test-debprof.out

# mcf
#BASE_PATH=/home/rudy/wo/spec/spec2006/benchspec/CPU2006/429.mcf/build/build_base_amd64-m64-gcc43-nn.0001
#CSV_FILENAME=${BASE_PATH}/final-train-debprof.out
#TEST_CSV_FILENAME=${BASE_PATH}/final-ref-debprof.out

# milc
#BASE_PATH=/home/rudy/wo/spec/spec2006/benchspec/CPU2006/433.milc/build/build_base_amd64-m64-gcc43-nn.0000
#CSV_FILENAME=${BASE_PATH}/final-train-debprof.out
#TEST_CSV_FILENAME=${BASE_PATH}/final-test-debprof.out

# namd
BMARK_NAME=namd
BASE_PATH=/home/rudy/wo/spec/spec2006/benchspec/CPU2006/444.namd/build/build_base_amd64-m64-gcc43-nn.0000

# gobmk
#BMARK_NAME=gobmk
#BASE_PATH=/home/rudy/wo/spec/spec2006/benchspec/CPU2006/445.gobmk/build/build_base_amd64-m64-gcc43-nn.0001

# soplex
#BMARK_NAME=soplex
#BASE_PATH=/home/rudy/wo/spec/spec2006/benchspec/CPU2006/450.soplex/build/build_base_amd64-m64-gcc43-nn.0001

# povray
#BMARK_NAME=povray
#BASE_PATH=/home/rudy/wo/spec/spec2006/benchspec/CPU2006/453.povray/build/build_base_amd64-m64-gcc43-nn.0001

# hmmer
#BMARK_NAME=hmmer
#BASE_PATH=/home/rudy/wo/spec/spec2006/benchspec/CPU2006/456.hmmer/build/build_base_amd64-m64-gcc43-nn.0000

# sjeng
#BMARK_NAME=sjeng
#BASE_PATH=/home/rudy/wo/spec/spec2006/benchspec/CPU2006/458.sjeng/build/build_base_amd64-m64-gcc43-nn.0000

# libquantum
#BMARK_NAME=libquantum
#BASE_PATH=/home/rudy/wo/spec/spec2006/benchspec/CPU2006/462.libquantum/build/build_base_amd64-m64-gcc43-nn.0000

# h264ref
#BMARK_NAME=h264ref
#BASE_PATH=/home/rudy/wo/spec/spec2006/benchspec/CPU2006/464.h264ref/build/build_base_amd64-m64-gcc43-nn.0000

# lbm
#BMARK_NAME=lbm
#BASE_PATH=/home/rudy/wo/spec/spec2006/benchspec/CPU2006/470.lbm/build/build_base_amd64-m64-gcc43-nn.0000

# omnetpp
#BMARK_NAME=omnetpp
#BASE_PATH=/home/rudy/wo/spec/spec2006/benchspec/CPU2006/471.omnetpp/build/build_base_amd64-m64-gcc43-nn.0000

# astar
#BMARK_NAME=astar
#BASE_PATH=/home/rudy/wo/spec/spec2006/benchspec/CPU2006/473.astar/build/build_base_amd64-m64-gcc43-nn.0000

# sphinx3
#BMARK_NAME=sphinx3
#BASE_PATH=/home/rudy/wo/spec/spec2006/benchspec/CPU2006/482.sphinx3/build/build_base_amd64-m64-gcc43-nn.0000










CSV_FILENAME=${BASE_PATH}/final-train-debprof.out
TEST_CSV_FILENAME=${BASE_PATH}/final-test-debprof.out
SAVE_PLOTS=${BMARK_NAME}-dt
OUTPUT_FILE=${BMARK_NAME}-accuracy.txt


mkdir -p $BMARK_NAME
pushd $BMARK_NAME &> /dev/null
python ../learn_dt.py \
      -csv_file_name ${CSV_FILENAME} \
      -test_csv_file_name ${TEST_CSV_FILENAME} \
      -save_plots ${SAVE_PLOTS} \
      &> ${OUTPUT_FILE}
echo
echo "Dumping ${OUTPUT_FILE} to stdout:"
echo "-------------"
cat $OUTPUT_FILE
echo "-------------"
popd &> /dev/null
echo
echo "See folder ${BMARK_NAME} for all results and files"
echo
