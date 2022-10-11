#!/bin/bash
#set -euo pipefail


function run_spec() {
    echo "================="
    echo "Running SPEC 2017"
    echo "================="

    pushd /root/decker/spec2017
    source shrc

    BASE_FOLDER=/root/decker/spec2017/benchspec/CPU
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

    for BMARK in ${BMARKS[@]}; do
        pushd ${BASE_FOLDER}/${BMARK}/build/build_peak_mytest-m64.0000

        cp readelf-custlink-ics.out readelf.out
        cp readelf-sections-custlink-ics.out readelf-sections.out

        # baseline run
        ./run.sh base_ls large

        # security run (i.e. log the page sets)
        DEBRT_ENABLE_STATS=1 DEBRT_ENABLE_INDIRECT_CALL_SINKING=1 ./run.sh wpd_cl_ics large
        # back up the security result, b/c performance run blows over them
        cp debrt-mapped-rx-pages_wpd_cl_ics.out debrt-mapped-rx-pages_wpd_cl_ics-security.out
        cp debrt_wpd_cl_ics.out debrt_wpd_cl_ics-security.out
        cp large-wpd_cl_ics.out large-wpd_cl_ics-security.out

        # performance run (i.e. no extra logging)
        DEBRT_ENABLE_INDIRECT_CALL_SINKING=1 ./run.sh wpd_cl_ics large

        popd
    done

    popd
}


run_spec
