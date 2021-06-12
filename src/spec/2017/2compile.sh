#!/bin/bash
set 
echo "Compiling spec2017 benchmarks"

C=`pwd`

BMARKS=(
    500.perlbench_r
    505.mcf_r
    508.namd_r
    510.parest_r
    519.lbm_r
    520.omnetpp_r
    523.xalancbmk_r
    531.deepsjeng_r
    541.leela_r
    544.nab_r
    557.xz_r
)

for BMARK in ${BMARKS[@]}; do
    echo $BMARK
done
exit 1

#A
: '
kick off 8
sleep 5 seconds
    loop over the list, and if the process has exited, mark it
    for each exited process, remove it from the list
    kick off n more processes (one for each exited one) (up until the last
    one has been started)
    if the running processes list is empty, break
'



# benches=( 500.perlbench_r 508.namd_r 510.parest_r 519.lbm_r 520.omnetpp_r 523.xalancbmk_r 531.deepsjeng_r 541.leela_r 544.nab_r 557.xz_r  )
# #benches=( 510.parest_r )
# for i in "${benches[@]}"
# do
#     #access each element as $i. . .
# 	echo $i
#  	cd $C
#  	cd $i
# 	cd build
# 	cd build_peak_mytest-m64.0000
#     B='pwd'
	
#     make clean -j8
#     make wpd -j8
#     ln -s /home/rudy/wo/whole-program-debloat/src/spec/2017/linker.py
#     python3 linker.py .
#     cd $B
#     make wpd_custlink
#     ./run.sh wpd_cl large
# done


# declare  -a benches benches=( 525.x264_r )
# for i in "${benches[@]}"
# do
#     #access each element as $i. . .
#         echo $i
#         cd $C
#         cd $i
#         cd build
#         cd build_peak_mytest-m64.0000

#         make clean -j8 TARGET=x264_r 
#         make wpd -j8 TARGET=x264_r 
#         ln -s /home/rudy/wo/whole-program-debloat/src/spec/2017/linker.py
#         python3 linker.py .
#         cd $B
#         make wpd_custlink TARGET=x264_r 
#         ./run.sh wpd_cl large
# done

# declare  -a benches benches=( 538.imagick_r )
# for i in "${benches[@]}"
# do
#    #access each element as $i. . .
#        echo $i
#        cd $C
#        cd $i
#        cd build
#        cd build_peak_mytest-m64.0000
       
#        make clean -j8 TARGET=imagick_r
#        make wpd -j8 TARGET=imagick_r 
#        ln -s /home/rudy/wo/whole-program-debloat/src/spec/2017/linker.py
#        python3 linker.py .
#        cd $B
#        make wpd_custlink TARGET=imagick_r
#         ./run.sh wpd_cl large 
# done

declare  -a benches benches=( 511.povray_r )
for i in "${benches[@]}"
do
	echo $i
	cd $C
	cd $i
	cd build
	cd build_peak_mytest-m64.0000
    
    make clean -j8 TARGET=povray_r
    make wpd -j8 TARGET=povray_r
    ln -s /home/rudy/wo/whole-program-debloat/src/spec/2017/linker.py
    python3 linker.py .
    cd $B
    make wpd_custlink TARGET=povray_r
    ./run.sh wpd_cl large 
done

# declare  -a benches benches=( 526.blender_r )
# for i in "${benches[@]}"
# do
#    #access each element as $i. . .
#        echo $i
#        cd $C
#        cd $i
#        cd build
#        cd build_peak_mytest-m64.0000

#        make clean -j8 TARGET=blender_r
#         make wpd -j8 TARGET=blender_r
#         ln -s /home/rudy/wo/whole-program-debloat/src/spec/2017/linker.py
#         python3 linker.py .
#         cd $B
#         make wpd_custlink TARGET=blender_r
# done

