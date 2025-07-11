#!/bin/bash
set -euxo pipefail
source env-vars




function post_process_bmark() {
    BMARK=$1
    echo "benchmark: $BMARK"
    FOLDER=${BMARK_TO_FOLDER[$BMARK]}
    echo "folder:    ${BASE_PATH}/${FOLDER}"
    #${PARSE_DEBPROF_PY} ${BASE_PATH}/${FOLDER}
    #${PARSE_DEBPROF_PY} ${BASE_PATH}/${FOLDER} "process-test-data"
    ${PARSE_CGPPROF_PY} ${BASE_PATH}/${FOLDER}
}




if [ $# == 1 ]; then
    post_process_bmark $1
else
    for BMARK in "${BMARKS[@]}"; do
        post_process_bmark $BMARK
    done
fi
