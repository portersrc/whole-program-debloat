#!/bin/bash

#set -euxo pipefail

source env-vars-2017

for BMARK in "${BMARKS[@]}"; do
    echo "benchmark: $BMARK"
    FOLDER=${BMARK_TO_FOLDER[$BMARK]}
    echo "folder:    ${BASE_PATH}/${FOLDER}"
    cat ${BASE_PATH}/${FOLDER}/wpd_stats.txt
    echo
done
