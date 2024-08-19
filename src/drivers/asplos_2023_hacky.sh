#!/bin/bash

FOLDERS=(
    #500.perlbench_r/build/build_peak_mytest-m64.0000
    #502.gcc_r/build/build_peak_mytest-m64.0000
    #505.mcf_r/build/build_peak_mytest-m64.0000
    #508.namd_r/build/build_peak_mytest-m64.0000
    #510.parest_r/build/build_peak_mytest-m64.0000
    #511.povray_r/build/build_peak_mytest-m64.0000
    #519.lbm_r/build/build_peak_mytest-m64.0000
    #520.omnetpp_r/build/build_peak_mytest-m64.0000
    523.xalancbmk_r/build/build_peak_mytest-m64.0000
    #525.x264_r/build/build_peak_mytest-m64.0000
    #526.blender_r/build/build_peak_mytest-m64.0000
    #531.deepsjeng_r/build/build_peak_mytest-m64.0000
    #538.imagick_r/build/build_peak_mytest-m64.0000
    #541.leela_r/build/build_peak_mytest-m64.0000
    #544.nab_r/build/build_peak_mytest-m64.0000
    #557.xz_r/build/build_peak_mytest-m64.0000
)
#
#pushd /home/rudy/wo/spec/spec2017/benchspec/CPU &> /dev/null


# Get absolute pass time
#for FOLDER in ${FOLDERS[@]}; do
#    pushd $FOLDER &> /dev/null
#    echo $FOLDER
#    { time make wpd_ics_hack; } 2>&1 | grep ^real
#    echo $?
#    popd &> /dev/null
#done

# get time of building a decker binary
# make sure the makefile has ics.ll link step enabled
#for FOLDER in ${FOLDERS[@]}; do
#    pushd $FOLDER &> /dev/null
#    echo $FOLDER
#    make clean &> /dev/null
#    #time make base_loop_simplify_ics wpd_ics_hack2 wpd_custlink_ics
#    { time make base_loop_simplify_ics wpd_ics_hack2 wpd_custlink_ics; } 2>&1 | grep ^real
#    echo $?
#    popd &> /dev/null
#done

# get time of building a baseline binary
# make sure the makefile has link step enabled (just the regular one without ics.ll is fine)
#for FOLDER in ${FOLDERS[@]}; do
#    pushd $FOLDER &> /dev/null
#    echo $FOLDER
#    make clean &> /dev/null
#    #time make base_loop_simplify
#    { time make base_loop_simplify; } 2>&1 | grep ^real
#    echo $?
#    popd &> /dev/null
#done


# quick hack to get me back into a state that I want.
#for FOLDER in ${FOLDERS[@]}; do
#    pushd $FOLDER &> /dev/null
#    echo $FOLDER
#    time make base_loop_simplify_ics wpd_ics wpd_custlink_ics
#    echo $?
#    popd &> /dev/null
#done

pushd /home/rudy/wo/spec/spec2017/benchspec/CPU &> /dev/null
for FOLDER in ${FOLDERS[@]}; do
    pushd $FOLDER &> /dev/null
    echo $FOLDER
    ./calc-false-positives.py
    echo $?
    popd &> /dev/null
done
popd

#for FOLDER in ${FOLDERS[@]}; do
#    pushd $FOLDER &> /dev/null
#    BMARK=$(cut -d/ -f1 <<<"$FOLDER")
#    echo $BMARK
#    mv ${BMARK}_wpd_custlink_ics ${BMARK}_wpd_custlink_ics_trace
#    mv debrt-mapped-rx-pages_wpd_cl_ics.out debrt-mapped-rx-pages_wpd_cl_ics_trace.out
#    mv large-wpd_cl_ics.out large-wpd_cl_ics_trace.out
#    #echo $?
#    popd &> /dev/null
#done

#for FOLDER in ${FOLDERS[@]}; do
#    pushd $FOLDER &> /dev/null
#    #grep ^real large-wpd_cl_ics_trace.out | awk '{print $2}' | /home/rudy/wo/whole-program-debloat/src/drivers/get_times/parse_time.py
#    grep ^real large-wpd_cl_ics_trace.out # | awk '{print $2}' | /home/rudy/wo/whole-program-debloat/src/drivers/get_times/parse_time.py
#    popd &> /dev/null
#done

#for FOLDER in ${FOLDERS[@]}; do
#    pushd $FOLDER &> /dev/null
#    #echo $FOLDER
#    ls -l *_wpd_custlink_ics
#    popd &> /dev/null
#done


#FOLDERS=(
#	500.perlbench_r/build/build_peak_mytest-m64.0000
#    #502.gcc_r/build/build_peak_mytest-m64.0000
#	505.mcf_r/build/build_peak_mytest-m64.0000
#	508.namd_r/build/build_peak_mytest-m64.0000
#    #510.parest_r/build/build_peak_mytest-m64.0000
#	511.povray_r/build/build_peak_mytest-m64.0000
#	519.lbm_r/build/build_peak_mytest-m64.0000
#	520.omnetpp_r/build/build_peak_mytest-m64.0000
#	523.xalancbmk_r/build/build_peak_mytest-m64.0000
#	525.x264_r/build/build_peak_mytest-m64.0000
#	#526.blender_r/build/build_peak_mytest-m64.0000
#	531.deepsjeng_r/build/build_peak_mytest-m64.0000
#	#538.imagick_r/build/build_peak_mytest-m64.0000
#	541.leela_r/build/build_peak_mytest-m64.0000
#	544.nab_r/build/build_peak_mytest-m64.0000
#	557.xz_r/build/build_peak_mytest-m64.0000
#)
#
#pushd /home/rudy/wo/spec/spec2017/benchspec/CPU &> /dev/null
#
#for FOLDER in ${FOLDERS[@]}; do
#    pushd $FOLDER &> /dev/null
#    #echo $FOLDER
#    #ls -l *_wpd_ics_split
#    #python3 linker.py .
#    #ls -l *_wpd_custlink_ics_split
#    ls -l readelf-custlink-ics-split.out
#    ls -l readelf-sections-custlink-ics-split.out
#    popd &> /dev/null
#done
