#!/bin/bash
set -euxo pipefail

#
# Salt to taste...
#


BASE_PATH=/home/rudy/wo/spec/spec2017/benchspec/CPU


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


REG_FOLDER=build_peak_mytest-m64.0000
MLI_FOLDER=build_peak_mytest-m64.0000-mli
WPD_FOLDER=build_peak_mytest-m64.0000-wpd


for BMARK in "${BMARKS[@]}"; do
    echo $BMARK
    cd ${BASE_PATH}/${BMARK}/build
    mv ${REG_FOLDER} ${MLI_FOLDER}
    cp -r ${WPD_FOLDER} ${REG_FOLDER}
done
