#!/bin/bash


WRK_BASE=$HOME/wo/wrk


NUM_SEC_ARR=(
    3
    30
    300
)

BASE_WPD_ARR=(
    #baseline_ls
    wpd_custlink_ics
)


function LAUNCH_WRK() {
    NUM_SEC=$1
    BP=$2
    WRK_OUT=wrk.${NUM_SEC}s.${BP}.out
    $WRK_BASE/wrk -t12 -c400 -d${NUM_SEC}s http://127.0.0.1:8080/wikipedia_main_page.html &> $WRK_OUT
}


for x in {1..3}; do
    for NUM_SEC in ${NUM_SEC_ARR[@]}; do
        for BP in ${BASE_WPD_ARR[@]}; do
            LAUNCH_WRK $NUM_SEC $BP
        done
    done
    mkdir -p $x
    mv *.out $x
done
