#!/bin/bash

COREUTILS_BASE=/home/rudy/wo/security-bench

BMARKS=(
    bzip2
    chown
    date
    grep
    gzip
    mkdir
    rm
    sort
    tar
    uniq
)

pushd ${COREUTILS_BASE} &> /dev/null

for BMARK in ${BMARKS[@]}; do
    pushd $BMARK &> /dev/null
    wc -l wpd_disjoint_sets_ics_nostatic.txt
    popd &> /dev/null
done

popd &> /dev/null
