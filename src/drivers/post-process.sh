#!/bin/bash
set -euxo pipefail
source env-vars




function post_process_bmark() {
    BMARK=$1
    echo "benchmark: $BMARK"
    FOLDER=${BMARK_TO_FOLDER[$BMARK]}
    echo "folder:    ${BASE_PATH}/${FOLDER}"
    ${PARSE_DEBPROF_PY} ${BASE_PATH}/${FOLDER}
    #${PARSE_DEBPROF_PY} ${BASE_PATH}/${FOLDER} "process-test-data"
}




if [ $# == 1 ]; then
    echo "hit"
    post_process_bmark $1
else
    for BMARK in "${BMARKS[@]}"; do
        post_process_bmark $BMARK
    done
fi
