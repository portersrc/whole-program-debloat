#!/bin/bash
set -euxo pipefail
source env-vars




function run_bmark() {
    BMARK=$1
    echo "benchmark: $BMARK"
    FOLDER=${BMARK_TO_FOLDER[$BMARK]}
    echo "folder:    $FOLDER"
    pushd ${BASE_PATH}/${FOLDER}

    # XXX If/when we want to try improving accuracy for a benchmark, then try
    # medium and/or small + medium (concatenate). Just be sure to tidy up
    # the names, since each benchmmark's run.sh is cowboying it (debprof.out,
    # train-debprof.out, test-debprof.out, etc.
    ./run.sh small
    #./run.sh medium

    popd
}




if [ $# == 1 ]; then
    run_bmark $1
else
    for BMARK in "${BMARKS[@]}"; do
        run_bmark $BMARK
    done
fi
