#!/bin/bash
set -euxo pipefail


INPUT_PATH=/home/rudy/wo/whole-program-debloat/src/gadget-chains/input
OUTPUT_PATH=/home/rudy/wo/rop-benchmark/binaries/x86/reallife/orig/debian-10-cloud
VULN_OUTPUT_PATH=/home/rudy/wo/rop-benchmark/binaries/x86/reallife/vuln/debian-10-cloud
BMARK_SUFFIX=baseline_ls

BMARKS=(
    nginx
)

for BMARK in "${BMARKS[@]}"; do
    OFFSET_HEX=$(objdump -h ${BMARK}/${BMARK}_${BMARK_SUFFIX} | grep ".text" | awk '{print $4}')
    SIZE_HEX=$(objdump -h ${BMARK}/${BMARK}_${BMARK_SUFFIX} | grep ".text" | awk '{print $3}')
    OFFSET=$((16#${OFFSET_HEX}))
    SIZE=$((16#${SIZE_HEX}))
    echo
    echo ${BMARK}
    echo ${OFFSET_HEX}
    echo ${SIZE_HEX}
    echo ${OFFSET}
    echo ${SIZE}
    echo
    dd if=${INPUT_PATH}/${BMARK}/${BMARK}_${BMARK_SUFFIX} of=${OUTPUT_PATH}/${BMARK}_${BMARK_SUFFIX}_onlytext.bin skip=${OFFSET} count=${SIZE} iflag=skip_bytes,count_bytes


done
