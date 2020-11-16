#!/bin/bash
set -euxo pipefail

source env-vars


for BMARK in "${BMARKS[@]}"; do
    echo "benchmark: $BMARK"
    FOLDER=${BMARK_TO_FOLDER[$BMARK]}
    echo "folder:    ${BASE_PATH}/${FOLDER}"
    ${PARSE_DEBPROF_PY} ${BASE_PATH}/${FOLDER}
done
