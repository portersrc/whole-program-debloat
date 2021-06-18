#!/bin/bash
set -exo pipefail


function usage() {
    echo
    echo "Usage:"
    echo "  $0 <security_or_performance>"
    echo
    exit 1
}


# parse command-line args
IS_SECURITY_RUN=false
if [ $# == 1 ]; then
    if [ $1 == "security" ]; then
        IS_SECURITY_RUN=true
    elif [ $1 == "performance" ]; then
        :
    else
        usage
    fi
else
    usage
fi


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
    500.perlbench_r
    508.namd_r
    511.povray_r
    520.omnetpp_r
    523.xalancbmk_r
    525.x264_r
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
    [GROUP_A]=${GROUP_A[@]}
    #[GROUP_B]=${GROUP_B[@]}
    #[GROUP_C]=${GROUP_C[@]}
)


CMDS=(
    "make wpd"
    "python3 linker.py ."
    "make wpd_custlink"
    "cp readelf-base.out readelf.out"
    "cp readelf-sections-base.out readelf-sections.out"
    "./run.sh wpd large"
    "cp readelf-custlink.out readelf.out"
    "cp readelf-sections-custlink.out readelf-sections.out"
    "./run.sh wpd_cl large"
    "make wpd_sink"
    "python3 linker.py ."
    "make wpd_custlink_sink"
    "cp readelf-sink.out readelf.out"
    "cp readelf-sections-sink.out readelf-sections.out"
    "./run.sh wpd_sink large"
    "cp readelf-custlink-sink.out readelf.out"
    "cp readelf-sections-custlink-sink.out readelf-sections.out"
    "./run.sh wpd_cl_sink large"
)


# TODO: put this code in a proper place
# copy results
#mkdir tmp_result
#pushd tmp_result
#for GROUP in "${!GROUP_TO_BMARKS[@]}"; do
#    for BMARK in ${GROUP_TO_BMARKS[$GROUP]}; do
#        mkdir $BMARK
#        cp $SPEC_BMARKS_PATH/$BMARK/$SPEC_BUILD_FOLDER_SUFFIX/large*.out $BMARK
#        cp $SPEC_BMARKS_PATH/$BMARK/$SPEC_BUILD_FOLDER_SUFFIX/debrt*.out $BMARK
#        cp $SPEC_BMARKS_PATH/$BMARK/$SPEC_BUILD_FOLDER_SUFFIX/wpd_stats*.txt $BMARK
#    done
#done
#popd
#exit 42

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
                    DEBRT_ENABLE_STATS=1 $CMD &
                # otherwise launch serialized in foreground for performance
                else
                    $CMD
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
