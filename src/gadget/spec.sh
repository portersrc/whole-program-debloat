#!/bin/bash

#THE_LOG=spec.log
THE_LOG=/dev/stdout

SPEC_PATH=/home/rudy/wo/spec/spec2017

a=( 505.mcf_r 519.lbm_r  531.deepsjeng_r 541.leela_r 544.nab_r 557.xz_r )
b=( 500.perlbench_r 508.namd_r 511.povray_r 520.omnetpp_r 523.xalancbmk_r 525.x264_r )
c=( 510.parest_r 538.imagick_r 526.blender_r )
d=( 502.gcc_r )
BMARKS=( ${a[@]} ${b[@]} ${c[@]} ${d[@]} )
#z=( 500.perlbench_r )
#BMARKS=( ${z[@]} )



echo "Gathering gadget results for spec" &> ${THE_LOG}

for i in "${!BMARKS[@]}"; do
    BMARK="${BMARKS[$i]}"

    START=$(readelf -S ${SPEC_PATH}/benchspec/CPU/${BMARK}/build/build_peak_mytest-m64.0000/${BMARK}_artd_release | grep .text | awk '{print $4}')
    SIZE=$(readelf -S ${SPEC_PATH}/benchspec/CPU/${BMARK}/build/build_peak_mytest-m64.0000/${BMARK}_artd_release | grep .text -A 1 | awk '{getline; print $1}')
    echo $BMARK &>> ${THE_LOG}
    echo $START &>> ${THE_LOG}
    echo $SIZE  &>> ${THE_LOG}

    rm -rf resultsartd_release/$BMARK
    python3 GSA.py --text_only --binary_version artd_release --result_folder_name ${BMARK} ${SPEC_PATH}/benchspec/CPU/$BMARK/build/build_peak_mytest-m64.0000/$BMARK"_artd_release" ${SPEC_PATH}/benchspec/CPU/$BMARK/build/build_peak_mytest-m64.0000/debrt-mapped-rx-pages-artd_release.out $START $SIZE &>> ${THE_LOG}

done

echo "Running calculate.py" &>> ${THE_LOG}
python3 calculate.py --A --B --C --D --ics_linker &>> ${THE_LOG}
#python3 calculate.py --E --ics_linker &>> ${THE_LOG}

tail -n16 ics_linker.csv | awk -F',' '{print $1" "$4" "$6" "$8 }'
