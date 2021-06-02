#!/bin/bash

#benches=( 500.perlbench_r 505.mcf_r 508.namd_r 510.parest_r 511.povray_r 519.lbm_r 520.omnetpp_r 523.xalancbmk_r 525.x264_r 526.blender_r 531.deepsjeng_r 541.leela_r 544.nab_r 557.xz_r  )
#benches=( 526.blender_r  )
benches=( 519.lbm_r )
for i in "${benches[@]}"
do
    rm results/$i
    python3 GSA.py --output_metrics --output_addresses --output_tables original --result_folder_name $i --output_locality /home/sharjeel/spec2017_clean/benchspec/CPU/$i/build/build_base_mytest-m64.0000/$i"_baseline_ls" "{}"
done
