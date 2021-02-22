#!/bin/bash
set -euxo pipefail

source env-vars


for BMARK in "${BMARKS[@]}"; do
    echo "benchmark: $BMARK"
    FOLDER=${BMARK_TO_FOLDER[$BMARK]}
    echo "folder:    $FOLDER"
    make -C ${BASE_PATH}/${FOLDER} prof
  
    mkdir -p $BMARK
    cat ${BASE_PATH}/${FOLDER}/debprof_pass_stats.txt >> $BMARK/pass_stats.txt
    cat $BMARK/pass_stats.txt
done
