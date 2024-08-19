#!/bin/bash
set -euxo pipefail

#
# Salt to taste...
#


BASE_PATH=/home/rudy/wo/spec/spec2017/benchspec/CPU
#DEST_RESULTS_BASE=/home/rudy/wo/advanced-rtd/whole-program-debloat/results/asplos25-summer/2024-06-19/yes-tracing-yes-path-checking
#DEST_RESULTS_BASE=/home/rudy/wo/advanced-rtd/whole-program-debloat/results/2024-06-27/page-fault-no-clean
#DEST_RESULTS_BASE=/home/rudy/wo/advanced-rtd/whole-program-debloat/results/2024-06-27/page-fault-clean-after-loops
#DEST_RESULTS_BASE=/home/rudy/wo/advanced-rtd/whole-program-debloat/results/2024-06-27/medhard-page-fault-clean-after-loops
DEST_RESULTS_BASE=/home/rudy/wo/advanced-rtd/whole-program-debloat/results/2024-06-27/medhard-page-fault-no-clean

#DEST_FOLDER=/home/rudy/wo/advanced-rtd/whole-program-debloat/src/learning/old-linker-disjoint-sets
#DEST_FOLDER=/home/rudy/wo/advanced-rtd/whole-program-debloat/src/learning/new-linker-disjoint-sets

#DEST_FOLDER=/home/rudy/wo/advanced-rtd/whole-program-debloat/src/learning/2-var-hist-output
#DEST_FOLDER=/home/rudy/wo/advanced-rtd/whole-program-debloat/src/learning/static-reachability-files
#DEST_FOLDER=/home/rudy/wo/advanced-rtd/whole-program-debloat/src/learning/2-var-hist-only-trace-output
#DEST_FOLDER=/home/rudy/wo/advanced-rtd/whole-program-debloat/src/learning/16-buf-hist-output
#DEST_FOLDER=/home/rudy/wo/advanced-rtd/whole-program-debloat/src/learning/one

#FILENAME=debrt.out
#FILENAME=artd_static_reachability.txt
#FILENAME=large-artd_release.out





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

    echo $BMARK

    BMARK_PATH=${BASE_PATH}/${BMARK}/build/*peak*0
    #echo $BMARK_PATH
    #pushd $BMARK_PATH
    #cp $FILENAME ${DEST_FOLDER}/${BMARK}-${FILENAME}
    #popd

    #ls -al ${BMARK_PATH}/large-artd_release.out

    # 01
    #cp ${BMARK_PATH}/large-artd_release.out 01/${BMARK}-large-artd_release.out
    #mkdir -p 01/else/${BMARK}
    #cp ${BMARK_PATH}/debrt* 01/else/${BMARK}
    #cp ${BMARK_PATH}/artd* 01/else/${BMARK}
    #cp ${BMARK_PATH}/func-set*.out 01/else/${BMARK}
    #cp ${BMARK_PATH}/training-data.out 01/else/${BMARK}
    #cp ${BMARK_PATH}/readelf*.out 01/else/${BMARK}

    # 02
    #cp ${BMARK_PATH}/large-artd_release.out 02/${BMARK}-large-artd_release.out
    #mkdir -p 02/else/${BMARK}
    #cp ${BMARK_PATH}/debrt* 02/else/${BMARK}
    #cp ${BMARK_PATH}/artd* 02/else/${BMARK}
    #cp ${BMARK_PATH}/func-set*.out 02/else/${BMARK}
    #cp ${BMARK_PATH}/training-data.out 02/else/${BMARK}
    #cp ${BMARK_PATH}/readelf*.out 02/else/${BMARK}

    # 03
    #cp ${BMARK_PATH}/large-artd_release.out 03/${BMARK}-large-artd_release.out
    #mkdir -p 03/else/${BMARK}
    #cp ${BMARK_PATH}/debrt* 03/else/${BMARK}
    #cp ${BMARK_PATH}/artd* 03/else/${BMARK}
    #cp ${BMARK_PATH}/func-set*.out 03/else/${BMARK}
    #cp ${BMARK_PATH}/training-data.out 03/else/${BMARK}
    #cp ${BMARK_PATH}/readelf*.out 03/else/${BMARK}

    # 04
    #cp ${BMARK_PATH}/large-artd_release.out 04/${BMARK}-large-artd_release.out
    #mkdir -p 04/else/${BMARK}
    #cp ${BMARK_PATH}/debrt* 04/else/${BMARK}
    #cp ${BMARK_PATH}/artd* 04/else/${BMARK}
    #cp ${BMARK_PATH}/func-set*.out 04/else/${BMARK}
    #cp ${BMARK_PATH}/training-data.out 04/else/${BMARK}
    #cp ${BMARK_PATH}/readelf*.out 04/else/${BMARK}

    # 2023-11-16
    ##pushd ${DEST_RESULTS_BASE}/2023-11-16
    #pushd ${DEST_RESULTS_BASE}/2023-11-16-security
    #cp ${BMARK_PATH}/large-artd_release.out ${BMARK}-large-artd_release.out
    #mkdir -p else/${BMARK}
    #cp ${BMARK_PATH}/debrt* else/${BMARK}
    #cp ${BMARK_PATH}/artd* else/${BMARK}
    #cp ${BMARK_PATH}/func-set*.out else/${BMARK}
    #cp ${BMARK_PATH}/training-data.out else/${BMARK}
    #cp ${BMARK_PATH}/readelf*.out else/${BMARK}
    ## gcc is too big, but just deleting all of these files. We aren't saving
    ## the models (i.e. header files) either, and this is not much different
    #rm $(find -name "artd-datalog*.out") 
    #popd

    # 2024-06-19
    #pushd ${DEST_RESULTS_BASE}
    #cp ${BMARK_PATH}/large-artd_release.out ${BMARK}-large-artd_release.out
    #mkdir -p else/${BMARK}
    #cp ${BMARK_PATH}/debrt* else/${BMARK}
    #cp ${BMARK_PATH}/artd* else/${BMARK}
    #cp ${BMARK_PATH}/func-set*.out else/${BMARK}
    #cp ${BMARK_PATH}/training-data.out else/${BMARK}
    #cp ${BMARK_PATH}/readelf*.out else/${BMARK}
    ## gcc is too big, but just deleting all of these files. We aren't saving
    ## the models (i.e. header files) either, and this is not much different
    #rm $(find -name "artd-datalog*.out") 
    #popd

    # 2024-06-27
    pushd ${DEST_RESULTS_BASE}
    cp ${BMARK_PATH}/large-artd_release.out ${BMARK}-large-artd_release.out
    popd

done
