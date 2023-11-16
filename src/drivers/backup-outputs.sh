#!/bin/bash
set -euo pipefail

#
# Salt to taste...
#


SPEC_BASE_PATH=/home/rudy/wo/spec/spec2017/benchspec/CPU

BMARKS=(
    500.perlbench_r
    502.gcc_r
    505.mcf_r
    508.namd_r
    510.parest_r
    511.povray_r
    519.lbm_r
    520.omnetpp_r
    523.xalancbmk_r
    525.x264_r
    526.blender_r
    531.deepsjeng_r
    538.imagick_r
    541.leela_r
    544.nab_r
    557.xz_r
)


for BMARK in "${BMARKS[@]}"; do

    BMARK_PATH=${SPEC_BASE_PATH}/${BMARK}/build/*peak*0
    BMARK_SHORT="${BMARK:4}"
    BMARK_SHORT="${BMARK_SHORT::-2}"

    pushd ${BMARK_PATH} &> /dev/null
    #cp debrt-mapped-rx-pages-artd_release.out debrt-mapped-rx-pages-artd_release-security.out
    #cp debrt-artd_release.out debrt-artd_release-security.out
    #cp large-artd_release.out large-artd_release-security.out
    ls -al *base
    popd &> /dev/null

done
