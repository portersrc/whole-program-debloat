#!/bin/bash
set -euo pipefail

RESULTS_BASE=/home/rudy/wo/whole-program-debloat/results/2021-10-10/nginx/performance/time-variation

function get_avg() {
    BASELINE_WPD=$1
    S=$2
    SUM=0
    for i in {1..3}; do
        F=$i/wrk.${S}s.${BASELINE_WPD}.out
        TRANSFER_PER_SEC=$(grep "Transfer/sec" $F | awk '{print $2}')
        TRANSFER_PER_SEC=${TRANSFER_PER_SEC::-2}
        SUM=`echo $SUM + $TRANSFER_PER_SEC | bc`
    done
    AVG=`echo $SUM / 3.0 | bc -l`
    echo $AVG
}

pushd ${RESULTS_BASE}

for S in {3,30,300}; do

    BASELINE_AVG=`get_avg "baseline_ls" $S`
    WPD_AVG=`get_avg "wpd_custlink_ics" $S`
    # slowdown is baseline / wpd, because we're looking at transfers/sec
    SLOWDOWN=`echo $BASELINE_AVG / $WPD_AVG | bc -l`
    echo "avg SLOWDOWN for ${S}s: $SLOWDOWN"

done

popd

