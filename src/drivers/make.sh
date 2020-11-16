#!/bin/bash
set -euxo pipefail

source env-vars


rm -f $ALL_PASS_STATS

for BMARK in "${BMARKS[@]}"; do
    echo "benchmark: $BMARK"
    FOLDER=${BMARK_TO_FOLDER[$BMARK]}
    echo "folder:    $FOLDER"
    cd ${BASE_PATH}/${FOLDER}
    make
  
    echo $BMARK >> $ALL_PASS_STATS
    cat debprof_pass_stats.txt
    cat debprof_pass_stats.txt >> $ALL_PASS_STATS
    echo "" >> $ALL_PASS_STATS
done
