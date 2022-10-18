#!/bin/bash

BASE_WPD=$1

WRK_BASE=/root/decker/wrk


REQ_SIZE_ARR=(
    1
    10
    100
)

#BASE_WPD_ARR=(
#    #baseline_ls
#    wpd_custlink_ics
#)


function LAUNCH_WRK() {
    REQ_SIZE=$1
    BP=$2
    WRK_OUT=wrk.${REQ_SIZE}mb.${BP}.out
    $WRK_BASE/wrk -t12 -c400 -d30s http://127.0.0.1:8080/${REQ_SIZE}mb.bin &> $WRK_OUT
}


#for x in {1..3}; do
    for REQ_SIZE in ${REQ_SIZE_ARR[@]}; do
        #for BP in ${BASE_WPD_ARR[@]}; do
            BP=${BASE_WPD}
            LAUNCH_WRK $REQ_SIZE $BP
        #done
    done
    #mkdir -p $x
    #mv *.out $x
#done
