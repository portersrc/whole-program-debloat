#!/bin/bash
set -euo pipefail

RESULTS_PATH=/home/rudy/wo/whole-program-debloat/results/2021-10-10/nginx/security
RESULTS_PREFIX=debrt-mapped-rx-pages

BMARKS=(
    nginx
)

for BMARK in "${BMARKS[@]}"; do
    #mkdir -p ${BMARK}
    cp ${RESULTS_PATH}/${RESULTS_PREFIX}* ${BMARK}/
done
