#!/bin/bash
set -euo pipefail


function build_decker() {
    echo "==============="
    echo "Building Decker"
    echo "==============="
    mkdir -p build
    pushd build
    cmake ../src
    make
    popd

    pushd src/debloat_rt/ics
    make
    popd
}





function build_spec() {
    echo "=================="
    echo "Building SPEC 2017"
    echo "=================="

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
    declare -A TARGET_EQUALS=(
        [511.povray_r]=povray_r
        [525.x264_r]=x264_r
        [526.blender_r]=blender_r
        [538.imagick_r]=imagick_r
    )

    for BMARK in ${BMARKS[@]}; do
        pushd ${BASE_FOLDER}/${BMARK}/build/build_peak_mytest-m64.0000

        OPTIONAL_TARGET=""
        if [ ${TARGET_EQUALS[$BMARK]+abc} ]; then
            OPTIONAL_TARGET="TARGET=${TARGET_EQUALS[$BMARK]}"
        fi
        echo "optional target: $OPTIONAL_TARGET"

        if [ "${BMARK}" == "502.gcc_r" ]; then
            make all_gcc ${OPTIONAL_TARGET}
        else
            make all ${OPTIONAL_TARGET}
        fi

        make base_loop_simplify base_loop_simplify_ics wpd_ics ${OPTIONAL_TARGET}
        python3 linker.py .
        make wpd_custlink_ics ${OPTIONAL_TARGET}

        popd
    done

    popd
}


function build_coreutils() {
    echo "======================"
    echo "Building GNU Coreutils"
    echo "======================"

    BASE_FOLDER=/root/decker/security-bench
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

    for BMARK in ${BMARKS[@]}; do
        pushd ${BASE_FOLDER}/${BMARK}

        make base_ls_nostatic wpd_ics_nostatic
        python3 linker.py .
        make wpd_custlink_ics_nostatic

        popd
    done
}


function build_nginx() {
    echo "=============="
    echo "Building nginx"
    echo "=============="

    BASE_FOLDER=/root/decker/nginx

    pushd ${BASE_FOLDER}

    make base_ls wpd_ics
    pushd objs
    ln -fs ../wpd_func_name_to_id.txt
    ln -fs ../wpd_disjoint_sets.txt
    python3 linker.py .
    popd
    make wpd_custlink_ics

    popd
}


#build_decker 
#build_spec
#build_coreutils
build_nginx
