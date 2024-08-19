#!/bin/bash
set -euxo pipefail

BUILD_HOME=/home/rudy/wo/spec/spec2017/benchspec/CPU

# 2022.10.22 cporter gcc result hack
GCC_HOME=502.gcc_r/build/build_peak_mytest-m64.0000
#GCC_BIN=502.gcc_r_baseline_ls
#GCC_BIN=502.gcc_r_wpd_custlink_ics
GCC_BIN=debrt-mapped-rx-pages.out
cp \
  $BUILD_HOME/$GCC_HOME/$GCC_BIN \
  502.gcc/
exit 1

PERLBENCH_HOME=500.perlbench_r/build/build_peak_mytest-m64.0000
PERLBENCH_BIN=500.perlbench_r_baseline_ls
PAREST_HOME=510.parest_r/build/build_peak_mytest-m64.0000
PAREST_BIN=510.parest_r_baseline_ls
IMAGICK_HOME=538.imagick_r/build/build_peak_mytest-m64.0000
IMAGICK_BIN=538.imagick_r_baseline_ls
LEELA_HOME=541.leela_r/build/build_peak_mytest-m64.0000
LEELA_BIN=541.leela_r_baseline_ls
LBM_HOME=519.lbm_r/build/build_peak_mytest-m64.0000
LBM_BIN=519.lbm_r_baseline_ls
MCF_HOME=505.mcf_r/build/build_peak_mytest-m64.0000
MCF_BIN=505.mcf_r_baseline_ls
OMNETPP_HOME=520.omnetpp_r/build/build_peak_mytest-m64.0000
OMNETPP_BIN=520.omnetpp_r_baseline_ls
XALANCBMK_HOME=523.xalancbmk_r/build/build_peak_mytest-m64.0000
XALANCBMK_BIN=523.xalancbmk_r_baseline_ls
NAMD_HOME=508.namd_r/build/build_peak_mytest-m64.0000
NAMD_BIN=508.namd_r_baseline_ls
POVRAY_HOME=511.povray_r/build/build_peak_mytest-m64.0000
POVRAY_BIN=511.povray_r_baseline_ls
BLENDER_HOME=526.blender_r/build/build_peak_mytest-m64.0000
BLENDER_BIN=526.blender_r_baseline_ls
DEEPSJENG_HOME=531.deepsjeng_r/build/build_peak_mytest-m64.0000
DEEPSJENG_BIN=531.deepsjeng_r_baseline_ls
NAB_HOME=544.nab_r/build/build_peak_mytest-m64.0000
NAB_BIN=544.nab_r_baseline_ls
XZ_HOME=557.xz_r/build/build_peak_mytest-m64.0000
XZ_BIN=557.xz_r_baseline_ls
X264_HOME=525.x264_r/build/build_peak_mytest-m64.0000
X264_BIN=525.x264_r_baseline_ls


cp \
  $BUILD_HOME/$PERLBENCH_HOME/$PERLBENCH_BIN \
  500.perlbench/

cp \
  $BUILD_HOME/$PAREST_HOME/$PAREST_BIN \
  510.parest/

cp \
  $BUILD_HOME/$IMAGICK_HOME/$IMAGICK_BIN \
  538.imagick/

cp \
  $BUILD_HOME/$LEELA_HOME/$LEELA_BIN \
  541.leela/

cp \
  $BUILD_HOME/$LBM_HOME/$LBM_BIN \
  519.lbm/

cp \
  $BUILD_HOME/$MCF_HOME/$MCF_BIN \
  505.mcf/

cp \
  $BUILD_HOME/$OMNETPP_HOME/$OMNETPP_BIN \
  520.omnetpp/

cp \
  $BUILD_HOME/$XALANCBMK_HOME/$XALANCBMK_BIN \
  523.xalancbmk/

cp \
  $BUILD_HOME/$NAMD_HOME/$NAMD_BIN \
  508.namd/

cp \
  $BUILD_HOME/$POVRAY_HOME/$POVRAY_BIN \
  511.povray/

cp \
  $BUILD_HOME/$BLENDER_HOME/$BLENDER_BIN \
  526.blender/

cp \
  $BUILD_HOME/$DEEPSJENG_HOME/$DEEPSJENG_BIN \
  531.deepsjeng/

cp \
  $BUILD_HOME/$NAB_HOME/$NAB_BIN \
  544.nab/

cp \
  $BUILD_HOME/$XZ_HOME/$XZ_BIN \
  557.xz/

cp \
  $BUILD_HOME/$X264_HOME/$X264_BIN \
  525.x264/
