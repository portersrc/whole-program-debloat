#!/bin/bash
set -x
set -eo pipefail


# set env if needed
[ $SPEC ]     || pushd ~/wo/spec/spec2017; source shrc; popd
[ $LLVM_BIN ] || source ~/wo/whole-program-debloat/setenv

SPEC_ROOT=/home/rudy/wo/spec/spec2017
SPEC_BMARKS_PATH=${SPEC_ROOT}/benchspec/CPU
SPEC_BUILD_FOLDER_SUFFIX=build/build_peak_mytest-m64.0000

BMARKS=(
    500.perlbench_r
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


GROUP_A=(
    505.mcf_r
    519.lbm_r
    531.deepsjeng_r
    541.leela_r
    544.nab_r
    557.xz_r
)

GROUP_B=(
    #500.perlbench_r
    #508.namd_r
    #511.povray_r
    #520.omnetpp_r
    523.xalancbmk_r
    #525.x264_r
)

GROUP_C=(
    510.parest_r
    526.blender_r
    538.imagick_r
)

declare -A TARGET_EQUALS=(
    [525.x264_r]=x264_r
    [511.povray_r]=povray_r
    [526.blender_r]=blender_r
    [538.imagick_r]=imagick_r
)

declare -A GROUP_TO_BMARKS=(
    #[GROUP_A]=${GROUP_A[@]}
    [GROUP_B]=${GROUP_B[@]}
    #[GROUP_C]=${GROUP_C[@]}
)


CMDS=(
    #"make wpd"
    #"python3 linker.py ."
    #"make wpd_custlink"
    #"cp readelf-base.out readelf.out"
    #"cp readelf-sections-base.out readelf-sections.out"
    #"./run.sh wpd large"
    #"cp readelf-custlink.out readelf.out"
    #"cp readelf-sections-custlink.out readelf-sections.out"
    #"./run.sh wpd_cl large"
    #"make wpd_sink"
    #"python3 linker.py ."
    #"make wpd_custlink_sink"
    #"cp readelf-sink.out readelf.out"
    #"cp readelf-sections-sink.out readelf-sections.out"
    #"./run.sh wpd_sink large"
    #"cp readelf-custlink-sink.out readelf.out"
    #"cp readelf-sections-custlink-sink.out readelf-sections.out"
    #"./run.sh wpd_cl_sink large"
    #"make base_loop_simplify_ics"
    #"make wpd_ics"
    #"python3 linker.py ."
    #"make wpd_custlink_ics"
    #"cp readelf-ics.out readelf.out"
    #"cp readelf-sections-ics.out readelf-sections.out"
    #"./run.sh wpd_ics large"
    "cp readelf-custlink-ics.out readelf.out"
    "cp readelf-sections-custlink-ics.out readelf-sections.out"
    "./run.sh wpd_cl_ics large"
    #"make wpd_bicsa"
    #"python3 linker.py ."
    #"make wpd_custlink_bicsa"
    #"cp readelf-bicsa.out readelf.out"
    #"cp readelf-sections-bicsa.out readelf-sections.out"
    #"./run.sh wpd_bicsa large"
    #"cp readelf-custlink-bicsa.out readelf.out"
    #"cp readelf-sections-custlink-bicsa.out readelf-sections.out"
    #"./run.sh wpd_cl_bicsa large"
)




function usage() {
    echo
    echo "Usage:"
    echo "  $0 <cmd> [stack-cleaning indirect-call-sinking basic-indirect-call-static-analysis]"
    echo
    echo "where cmd is one of: "
    echo "  security: to drive security results"
    echo "  performance: to drive performance results"
    echo "  copy-results: to copy last set of results to ./tmp_result"
    echo
    echo "Passing stack-cleaning will turn on stack cleaning for a security"
    echo "or performance run. Passing indirect-call-sinking will turn on"
    echo "indirect call sinking for a security or performance run. Passing"
    echo "basic-indirect-call-static-analysis will ensure loop headers map"
    echo "statically reachable functions based on basic function pointer"
    echo "analysis. You can pass any number of these options arguments (or"
    echo "none), and order doesn't matter."
    echo
    exit 1
}


function copy_results() {
    echo "Copying results..."
    mkdir tmp_result
    pushd tmp_result
    for GROUP in "${!GROUP_TO_BMARKS[@]}"; do
        for BMARK in ${GROUP_TO_BMARKS[$GROUP]}; do
            mkdir $BMARK
            cp $SPEC_BMARKS_PATH/$BMARK/$SPEC_BUILD_FOLDER_SUFFIX/large*.out $BMARK
            cp $SPEC_BMARKS_PATH/$BMARK/$SPEC_BUILD_FOLDER_SUFFIX/debrt*.out $BMARK
            cp $SPEC_BMARKS_PATH/$BMARK/$SPEC_BUILD_FOLDER_SUFFIX/wpd_stats*.txt $BMARK

            # hacky copy in case im checking wpd stats for sinking behavior:
            #cp $SPEC_BMARKS_PATH/$BMARK/$SPEC_BUILD_FOLDER_SUFFIX/wpd_stats_sink.txt $BMARK

            # hacky check for large*.out timestamps
            #ls -l $SPEC_BMARKS_PATH/$BMARK/$SPEC_BUILD_FOLDER_SUFFIX/large*.out

            # hacky check for ics and cl-ics binary timestamps
            #ls -l $SPEC_BMARKS_PATH/$BMARK/$SPEC_BUILD_FOLDER_SUFFIX/*wpd*_ics

            # hacky check for base_loop_simplify_ics bitcode output
            #ls -l $SPEC_BMARKS_PATH/$BMARK/$SPEC_BUILD_FOLDER_SUFFIX/*_baseline_ls_ics_opt.bc

            # hacky check for wpd_ics and wpd_custlink_ics binaries
            #ls -l $SPEC_BMARKS_PATH/$BMARK/$SPEC_BUILD_FOLDER_SUFFIX/*wpd*ics
        done
    done
    popd
}




#
# Parse command-line args
#
IS_COPY_RESULTS=false
IS_SECURITY_RUN=false
IS_PERFORMANCE_RUN=false
IS_STACK_CLEANING_RUN=false
IS_INDIRECT_CALL_SINKING_RUN=false
IS_BASIC_INDIRECT_CALL_STATIC_ANALYSIS_RUN=false
if [ $# -gt 3 ]; then
    usage
fi
if [ $# -lt 1 ]; then
    usage
fi

if [ $# -gt 1 ]; then
    if [ $2 == "stack-cleaning" ]; then
        IS_STACK_CLEANING_RUN=true
    elif [ $2 == "indirect-call-sinking" ]; then
        IS_INDIRECT_CALL_SINKING_RUN=true
    elif [ $2 == "basic-indirect-call-static-analysis" ]; then
        IS_BASIC_INDIRECT_CALL_STATIC_ANALYSIS_RUN=true
    else
        usage
    fi
fi
if [ $# -gt 2 ]; then
    if [ $3 == "stack-cleaning" ]; then
        IS_STACK_CLEANING_RUN=true
    elif [ $3 == "indirect-call-sinking" ]; then
        IS_INDIRECT_CALL_SINKING_RUN=true
    elif [ $3 == "basic-indirect-call-static-analysis" ]; then
        IS_BASIC_INDIRECT_CALL_STATIC_ANALYSIS_RUN=true
    else
        usage
    fi
fi
if [ $# -gt 3 ]; then
    if [ $4 == "stack-cleaning" ]; then
        IS_STACK_CLEANING_RUN=true
    elif [ $4 == "indirect-call-sinking" ]; then
        IS_INDIRECT_CALL_SINKING_RUN=true
    elif [ $4 == "basic-indirect-call-static-analysis" ]; then
        IS_BASIC_INDIRECT_CALL_STATIC_ANALYSIS_RUN=true
    else
        usage
    fi
fi

if [ $1 == "copy-results" ]; then
    IS_COPY_RESULTS=true
elif [ $1 == "security" ]; then
    IS_SECURITY_RUN=true
elif [ $1 == "performance" ]; then
    IS_PERFORMANCE_RUN=true
else
    usage
fi




#
# If we're just copying results, perform copies and then exit.
#
if $IS_COPY_RESULTS; then
    copy_results
    exit 0
fi


#
# Main driver...
#
for GROUP in "${!GROUP_TO_BMARKS[@]}"; do

    echo $GROUP
    
    for CMD in "${CMDS[@]}"; do

        for BMARK in ${GROUP_TO_BMARKS[$GROUP]}; do
            echo "$BMARK"
            pushd $SPEC_BMARKS_PATH/$BMARK/$SPEC_BUILD_FOLDER_SUFFIX &> /dev/null
            pwd

            # if this is a run command...
            if [[ $CMD == *"run.sh "* ]]; then
                # launch in background with stats for security runs.
                if $IS_SECURITY_RUN; then
                    if $IS_STACK_CLEANING_RUN; then
                        if $IS_INDIRECT_CALL_SINKING_RUN; then
                            if $IS_BASIC_INDIRECT_CALL_STATIC_ANALYSIS_RUN; then
                                DEBRT_ENABLE_STATS=1 DEBRT_ENABLE_STACK_CLEANING=1 DEBRT_ENABLE_INDIRECT_CALL_SINKING=1 DEBRT_ENABLE_BASIC_INDIRECT_CALL_STATIC_ANALYSIS=1 $CMD &
                            else
                                DEBRT_ENABLE_STATS=1 DEBRT_ENABLE_STACK_CLEANING=1 DEBRT_ENABLE_INDIRECT_CALL_SINKING=1 $CMD &
                            fi
                        else
                            if $IS_BASIC_INDIRECT_CALL_STATIC_ANALYSIS_RUN; then
                                DEBRT_ENABLE_STATS=1 DEBRT_ENABLE_STACK_CLEANING=1 DEBRT_ENABLE_BASIC_INDIRECT_CALL_STATIC_ANALYSIS=1 $CMD &
                            else
                                DEBRT_ENABLE_STATS=1 DEBRT_ENABLE_STACK_CLEANING=1 $CMD &
                            fi
                        fi
                    else
                        if $IS_INDIRECT_CALL_SINKING_RUN; then
                            if $IS_BASIC_INDIRECT_CALL_STATIC_ANALYSIS_RUN; then
                                DEBRT_ENABLE_STATS=1 DEBRT_ENABLE_INDIRECT_CALL_SINKING=1 DEBRT_ENABLE_BASIC_INDIRECT_CALL_STATIC_ANALYSIS=1 $CMD &
                            else
                                DEBRT_ENABLE_STATS=1 DEBRT_ENABLE_INDIRECT_CALL_SINKING=1 $CMD &
                            fi
                        else
                            if $IS_BASIC_INDIRECT_CALL_STATIC_ANALYSIS_RUN; then
                                DEBRT_ENABLE_STATS=1 DEBRT_ENABLE_BASIC_INDIRECT_CALL_STATIC_ANALYSIS=1 $CMD &
                            else
                                DEBRT_ENABLE_STATS=1 $CMD &
                            fi
                        fi
                    fi
                # otherwise launch serialized in foreground for performance
                else
                    if $IS_STACK_CLEANING_RUN; then
                        if $IS_INDIRECT_CALL_SINKING_RUN; then
                            if $IS_BASIC_INDIRECT_CALL_STATIC_ANALYSIS_RUN; then
                                DEBRT_ENABLE_STACK_CLEANING=1 DEBRT_ENABLE_INDIRECT_CALL_SINKING=1 DEBRT_ENABLE_BASIC_INDIRECT_CALL_STATIC_ANALYSIS=1 $CMD
                            else
                                DEBRT_ENABLE_STACK_CLEANING=1 DEBRT_ENABLE_INDIRECT_CALL_SINKING=1 $CMD
                            fi
                        else
                            if $IS_BASIC_INDIRECT_CALL_STATIC_ANALYSIS_RUN; then
                                DEBRT_ENABLE_STACK_CLEANING=1 DEBRT_ENABLE_BASIC_INDIRECT_CALL_STATIC_ANALYSIS=1 $CMD
                            else
                                DEBRT_ENABLE_STACK_CLEANING=1 $CMD
                            fi
                        fi
                    else
                        if $IS_INDIRECT_CALL_SINKING_RUN; then
                            if $IS_BASIC_INDIRECT_CALL_STATIC_ANALYSIS_RUN; then
                                DEBRT_ENABLE_INDIRECT_CALL_SINKING=1 DEBRT_ENABLE_BASIC_INDIRECT_CALL_STATIC_ANALYSIS=1 $CMD
                            else
                                DEBRT_ENABLE_INDIRECT_CALL_SINKING=1 $CMD
                            fi
                        else
                            if $IS_BASIC_INDIRECT_CALL_STATIC_ANALYSIS_RUN; then
                                DEBRT_ENABLE_BASIC_INDIRECT_CALL_STATIC_ANALYSIS=1 $CMD
                            else
                                $CMD
                            fi
                        fi
                    fi
                fi

            else
                # Else, this may be a make command.
                # Add TARGET=*, if this is a make command for some benchmark
                # that needs it, e.g. add TARGET=povray_r for povray
                OPTIONAL_TARGET=""
                if [[ $CMD == *"make "* ]]; then
                    if [ ${TARGET_EQUALS[$BMARK]+abc} ]; then
                        OPTIONAL_TARGET="TARGET=${TARGET_EQUALS[$BMARK]}"
                    fi
                    echo "optional target: $OPTIONAL_TARGET"
                fi

                # Timing doesn't matter, so launch in background.
                $CMD $OPTIONAL_TARGET &
            fi

            popd &> /dev/null
            echo
        done

		# wait between commands
		wait

    done


done
