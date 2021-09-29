#!/bin/bash
set -euxo pipefail

# cporter 2021.09.28
# Fetch the input for the gadget-chain scripts/drivers.
# May need to do this more than once. It's fine to update this
# script if needed.

SECURITY_BENCH_PATH=/home/rudy/wo/security-bench
BMARK_SUFFIX=_wpd_custlink_ics_nostatic
RESULTS_PATH=/home/rudy/wo/whole-program-debloat/results/2021-09-24/security
RESULTS_PREFIX=debrt-mapped-rx-pages

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

for BMARK in "${BMARKS[@]}"; do
    mkdir -p ${BMARK}
    cp ${SECURITY_BENCH_PATH}/${BMARK}/${BMARK}${BMARK_SUFFIX} ${BMARK}/
    cp ${RESULTS_PATH}/${BMARK}/${RESULTS_PREFIX}* ${BMARK}/
done
