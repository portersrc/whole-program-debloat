#!/bin/bash

SPEC_BASE=/home/rudy/wo/spec/spec2017/benchspec/CPU

BMARKS=(
    perlbench
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
)

declare -A BMARK_TO_FOLDER=(
    [perlbench]=500.perlbench_r/build/build_peak_mytest-m64.0000
    [mcf]=505.mcf_r/build/build_peak_mytest-m64.0000
    [namd]=508.namd_r/build/build_peak_mytest-m64.0000
    [parest]=510.parest_r/build/build_peak_mytest-m64.0000
    [povray]=511.povray_r/build/build_peak_mytest-m64.0000
    [lbm]=519.lbm_r/build/build_peak_mytest-m64.0000
    [omnetpp]=520.omnetpp_r/build/build_peak_mytest-m64.0000
    [xalancbmk]=523.xalancbmk_r/build/build_peak_mytest-m64.0000
    [x264]=525.x264_r/build/build_peak_mytest-m64.0000
    [blender]=526.blender_r/build/build_peak_mytest-m64.0000
    [deepsjeng]=531.deepsjeng_r/build/build_peak_mytest-m64.0000
    [imagick]=538.imagick_r/build/build_peak_mytest-m64.0000
    [leela]=541.leela_r/build/build_peak_mytest-m64.0000
    [nab]=544.nab_r/build/build_peak_mytest-m64.0000
    [xz]=557.xz_r/build/build_peak_mytest-m64.0000
)

pushd ${SPEC_BASE} &> /dev/null

for BMARK in ${BMARKS[@]}; do
    FOLDER=${BMARK_TO_FOLDER[$BMARK]}
    pushd $FOLDER &> /dev/null
    du -sb *_wpd_custlink_ics
    du -sb *_baseline_ls
    popd &> /dev/null
done

popd &> /dev/null
