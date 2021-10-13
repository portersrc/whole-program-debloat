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
    du -sb ${BMARK}_wpd_custlink_ics_nostatic
    du -sb ${BMARK}_nostatic
    popd &> /dev/null
done

popd &> /dev/null
