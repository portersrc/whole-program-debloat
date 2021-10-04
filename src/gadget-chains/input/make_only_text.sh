#!/bin/bash
set -euxo pipefail


INPUT_PATH=/home/rudy/wo/whole-program-debloat/src/gadget-chains/input
OUTPUT_PATH=/home/rudy/wo/rop-benchmark/binaries/x86/reallife/orig/debian-10-cloud
#BMARK_SUFFIX=wpd_custlink_ics_nostatic
BMARK_SUFFIX=nostatic

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
    # For my wpd binaries
    #OFFSET_HEX=$(objdump -h ${BMARK}/${BMARK}_${BMARK_SUFFIX} | grep ".text" | awk '{print $4}')
    #SIZE_HEX=$(objdump -h ${BMARK}/${BMARK}_${BMARK_SUFFIX} | grep ".text" | awk '{print $3}')
    #OFFSET=$((16#${OFFSET_HEX}))
    #SIZE=$((16#${SIZE_HEX}))
    #echo
    #echo ${BMARK}
    #echo ${OFFSET_HEX}
    #echo ${SIZE_HEX}
    #echo ${OFFSET}
    #echo ${SIZE}
    #echo
    #dd if=${INPUT_PATH}/${BMARK}/${BMARK}_${BMARK_SUFFIX} of=${OUTPUT_PATH}/${BMARK}_onlytext.bin skip=${OFFSET} count=${SIZE} iflag=skip_bytes,count_bytes

    # For my baseline binaries
    OFFSET_HEX=$(objdump -h ${BMARK}/${BMARK}_${BMARK_SUFFIX} | grep ".text" | awk '{print $6}')
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
    #<${INPUT_PATH}/${BMARK}/${BMARK}_${BMARK_SUFFIX} tail -c "$((${OFFSET} + 1))" | head -c "${SIZE}" >${OUTPUT_PATH}/${BMARK}_${BMARK_SUFFIX}_onlytext2.bin

done
