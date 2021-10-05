#!/bin/bash
set -euxo pipefail


INPUT_PATH=/home/rudy/wo/whole-program-debloat/src/gadget-chains/input
OUTPUT_PATH=/home/rudy/wo/rop-benchmark/binaries/x86/reallife/orig/debian-10-cloud
VULN_OUTPUT_PATH=/home/rudy/wo/rop-benchmark/binaries/x86/reallife/vuln/debian-10-cloud
#BMARK_SUFFIX=r_wpd_custlink_ics
BMARK_SUFFIX=r_baseline_ls

BMARKS=(
    500.perlbench
    510.parest
    538.imagick
    541.leela
    519.lbm
    505.mcf
    520.omnetpp
    523.xalancbmk
    508.namd
    511.povray
    526.blender
    531.deepsjeng
    544.nab
    557.xz
    525.x264
)

for BMARK in "${BMARKS[@]}"; do
    # For my wpd binaries
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
