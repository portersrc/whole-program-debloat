#!/bin/bash
set -euo pipefail

#RESULTS_BASE=/home/rudy/wo/whole-program-debloat/results/2021-10-10/nginx/performance/size-variation

function get_avg() {
    BASELINE_WPD=$1
    MB=$2
    SUM=0
    #for i in {1..3}; do
        #F=$i/wrk.${MB}mb.${BASELINE_WPD}.out
        F=wrk.${MB}mb.${BASELINE_WPD}.out
        TRANSFER_PER_SEC=$(grep "Transfer/sec" $F | awk '{print $2}')
        TRANSFER_PER_SEC=${TRANSFER_PER_SEC::-2}
        SUM=`echo $SUM + $TRANSFER_PER_SEC | bc`
    #done
    AVG=`echo $SUM / 3.0 | bc -l`
    echo $AVG
}

#pushd ${RESULTS_BASE}

for MB in {1,10,100}; do

    BASELINE_AVG=`get_avg "baseline_ls" $MB`
    WPD_AVG=`get_avg "wpd_custlink_ics" $MB`
    # slowdown is baseline / wpd, because we're looking at transfers/sec
    SLOWDOWN=`echo $BASELINE_AVG / $WPD_AVG | bc -l`
    echo "${MB}mb $SLOWDOWN"

done

#popd

