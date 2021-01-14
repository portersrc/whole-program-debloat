#!/bin/bash
set -euxo pipefail

source env-vars


for BMARK in "${BMARKS[@]}"; do
    echo "benchmark: $BMARK"
    FOLDER=${BMARK_TO_FOLDER[$BMARK]}
    echo "folder:    ${BASE_PATH}/${FOLDER}"

    FUNC_SETS_FILENAME=${BASE_PATH}/${FOLDER}/debprof-func-set-ids-to-funcs.out
    CSV_FILENAME=${BASE_PATH}/${FOLDER}/final-train-debprof.out
    TEST_CSV_FILENAME=${BASE_PATH}/${FOLDER}/final-test-debprof.out
    #CSV_FILENAME=${BASE_PATH}/${FOLDER}/final-train-debprof.outsmall
    #TEST_CSV_FILENAME=${BASE_PATH}/${FOLDER}/final-test-debprof.outsmall
    #CSV_FILENAME=${BASE_PATH}/${FOLDER}/train-debprof.outsmall
    #TEST_CSV_FILENAME=${BASE_PATH}/${FOLDER}/test-debprof.outsmall
    #CSV_FILENAME=${BASE_PATH}/${FOLDER}/train-debprof.outfull
    #TEST_CSV_FILENAME=${BASE_PATH}/${FOLDER}/test-debprof.outfull
    SAVE_PLOTS=${BMARK}-dt
    OUTPUT_FILE=${BMARK}-accuracy.txt

    mkdir -p $BMARK
    pushd $BMARK &> /dev/null
    ${LEARN_PY} \
      -csv_file_name ${CSV_FILENAME} \
      -test_csv_file_name ${TEST_CSV_FILENAME} \
      -func_sets_file_name ${FUNC_SETS_FILENAME} \
      -save_plots ${SAVE_PLOTS} \
      &> ${OUTPUT_FILE}
      #-do_accuracy True \
    echo
    echo "Dumping ${OUTPUT_FILE} to stdout:"
    cat $OUTPUT_FILE
    popd &> /dev/null
    echo
    echo "See folder ${BMARK} for all results and files"
    echo

done
