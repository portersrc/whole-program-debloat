#!/bin/bash
set -euo pipefail


# cporter 2021.10.10
# I broke symlinks when i changed this folder name from output/ to output-spec.
# This fixed that. Leaving here in case something stupid like this happens
# again.

DST_PATH=/home/rudy/wo/rop-benchmark/binaries/x86/reallife/orig/debian-10-cloud
#PG_PATH=/home/rudy/wo/whole-program-debloat/src/gadget-chains/output/spec
PG_PATH=/home/rudy/wo/whole-program-debloat/src/gadget-chains/output/nginx

BMARKS=(
    #500.perlbench
    #510.parest
    #538.imagick
    #541.leela
    #519.lbm
    #505.mcf
    #520.omnetpp
    #523.xalancbmk
    #508.namd
    #511.povray
    ##526.blender
    #531.deepsjeng
    #544.nab
    #557.xz
    #525.x264
    nginx
)

for BMARK in "${BMARKS[@]}"; do
    #echo ${BMARK}

    pushd ${DST_PATH}
    rm ${BMARK}_pg*.bin

    for F in `ls ${PG_PATH}/${BMARK}/${BMARK}_pg*.bin`; do
        #echo $F
        ln -s $F
    done

    popd

done
