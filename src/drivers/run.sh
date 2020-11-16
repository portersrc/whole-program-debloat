#!/bin/bash
set -euxo pipefail

source env-vars


for BMARK in "${BMARKS[@]}"; do
    echo "benchmark: $BMARK"
    FOLDER=${BMARK_TO_FOLDER[$BMARK]}
    echo "folder:    $FOLDER"
    cd ${BASE_PATH}/${FOLDER}
    ./run.sh small
    ./run.sh medium
done
