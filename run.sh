#!/bin/bash


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
        cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_wpd_cl_ics-security.out
        cp debrt_wpd_cl_ics.out debrt_wpd_cl_ics-security.out
        cp large-wpd_cl_ics.out large-wpd_cl_ics-security.out

        # performance run (i.e. no extra logging)
        DEBRT_ENABLE_INDIRECT_CALL_SINKING=1 ./run.sh wpd_cl_ics large

        popd
    done

    popd
}


function run_coreutils() {
    echo "====================="
    echo "Running GNU Coreutils"
    echo "====================="


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

        cp readelf-custlink-ics-nostatic.out readelf.out
        cp readelf-sections-custlink-ics-nostatic.out readelf-sections.out

        # baseline run
        ./run.sh base_ls large # "base_ls" here will run base_ls_nostatic

        # performance run (i.e. no extra logging)
        # Run perf first for coreutils, b/c there are many inputs, and we
        # can blow over the performance logs but not the security logs. (perf
        # is negligible difference; just running for completeness.)
        DEBRT_ENABLE_INDIRECT_CALL_SINKING=1 ./run.sh wpd_cl_ics large

        # security run (i.e. log the page sets)
        # (again, "wpd_cl_ics" here will run wpd_cl_ics_nostatic)
        DEBRT_ENABLE_STATS=1 DEBRT_ENABLE_INDIRECT_CALL_SINKING=1 ./run.sh wpd_cl_ics large


        popd
    done

}


function run_nginx() {
    echo "============="
    echo "Running nginx"
    echo "============="


    BASE_NGINX_FOLDER=/root/decker/nginx
    BASE_WRK_FOLDER=/root/decker/wrk

    NGINX_WARMUP_TIME_S=3 # hacky time in seconds for nginx to get started
    NGINX_TEARDOWN_TIME_S=3 # hacky time in seconds for nginx to tear down and release address


    pushd ${BASE_NGINX_FOLDER}

    cp readelf-custlink-ics.out readelf.out
    cp readelf-sections-custlink-ics.out readelf-sections.out

    #
    # baseline run
    #
    echo "Running baseline version"

    # nginx is launched in the background
    objs/nginx_baseline_ls \
      -c conf/nginx.conf \
      -p .
    sleep ${NGINX_WARMUP_TIME_S}
    pushd /root/decker/whole-program-debloat/src/nginx/performance

    echo "Running baseline version - size variation"
    pushd size-variation
    ./run.sh baseline_ls
    popd
    echo "Running baseline version - time variation"
    pushd time-variation
    ./run.sh baseline_ls
    popd

    popd # leave src/nginx/performance
    pkill nginx
    sleep ${NGINX_TEARDOWN_TIME_S}


    #
    # security run (i.e. log the page sets)
    #
    echo "Running decker version for security"

    # nginx is launched in the background
    DEBRT_ENABLE_STATS=1 DEBRT_ENABLE_INDIRECT_CALL_SINKING=1 objs/nginx_wpd_custlink_ics \
      -c conf/nginx.conf \
      -p .
    sleep ${NGINX_WARMUP_TIME_S}

    pushd /root/decker/whole-program-debloat/src/nginx/security
    ./run.sh wpd_custlink_ics
    popd

    # OK to copy here (and not in the other run script) b/c the security
    # doesn't iterate more than once
    cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages-security.out

    # (no extra pop needed here)
    pkill nginx
    sleep ${NGINX_TEARDOWN_TIME_S}


    #
    # performance run (i.e. no extra logging)
    #
    echo "Running decker version for performance"

    # nginx is launched in the background
    DEBRT_ENABLE_INDIRECT_CALL_SINKING=1 objs/nginx_wpd_custlink_ics \
      -c conf/nginx.conf \
      -p .
    sleep ${NGINX_WARMUP_TIME_S}
    pushd /root/decker/whole-program-debloat/src/nginx/performance

    echo "Running decker version for performance - size variation"
    pushd size-variation
    ./run.sh wpd_custlink_ics
    popd
    echo "Running decker version for performance - time variation"
    pushd time-variation
    ./run.sh wpd_custlink_ics
    popd

    popd # leave src/nginx/performance
    pkill nginx
    sleep ${NGINX_TEARDOWN_TIME_S}

    popd

}


#run_spec
#run_coreutils
run_nginx
