#!/bin/bash
set -euxo pipefail

source env-vars


for BMARK in "${BMARKS[@]}"; do
    echo "benchmark: $BMARK"
    FOLDER=${BMARK_TO_FOLDER[$BMARK]}
    echo "folder:    ${BASE_PATH}/${FOLDER}"

    CSV_FILENAME=${BASE_PATH}/${FOLDER}/final-train-debprof.out
    TEST_CSV_FILENAME=${BASE_PATH}/${FOLDER}/final-test-debprof.out
    SAVE_PLOTS=${BMARK}-dt
    OUTPUT_FILE=${BMARK}-accuracy.txt

    mkdir -p $BMARK
    pushd $BMARK &> /dev/null
    python ${LEARN_DT_PY} \
          -csv_file_name ${CSV_FILENAME} \
          -test_csv_file_name ${TEST_CSV_FILENAME} \
          -save_plots ${SAVE_PLOTS} \
          &> ${OUTPUT_FILE}
    echo
    echo "Dumping ${OUTPUT_FILE} to stdout:"
    cat $OUTPUT_FILE
    popd &> /dev/null
    echo
    echo "See folder ${BMARK} for all results and files"
    echo

done
