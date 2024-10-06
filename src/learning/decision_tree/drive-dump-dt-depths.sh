#!/bin/bash
set -euxo pipefail

#
# Salt to taste...
#


BMARKS=(
    perlbench
    gcc
    mcf
    namd
    parest
    povray
    lbm
    omnetpp
    xalancbmk
    x264
    blender
    deepsjeng
    imagick
    leela
    nab
    xz
    nginx
)



for BMARK in "${BMARKS[@]}"; do
    ./dump_dt_depths.py $BMARK/debrt_decision_tree.h
done
