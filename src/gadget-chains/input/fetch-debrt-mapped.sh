#!/bin/bash
set -euo pipefail

RESULTS_PATH=/home/rudy/wo/whole-program-debloat/results/2021-09-05/security/cl-ics-sc
RESULTS_FILE=debrt-mapped-rx-pages.out

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
    #mkdir -p ${BMARK}
    cp ${RESULTS_PATH}/${BMARK}_r/${RESULTS_FILE} ${BMARK}/
done
