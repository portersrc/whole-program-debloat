#!/bin/bash
set -e

SCRIPTDIR=`dirname "$(readlink -f "$0")"`

function usage() {
    echo
    echo "Usage:"
    echo "  $0 <path to performance folder>"
    echo
}

if [ $# != 1 ]; then
    usage
    exit 1
fi

BASE_PERF_FOLDER=$1
pushd $BASE_PERF_FOLDER &> /dev/null

for BMARK_FOLDER in `ls`; do
    pushd $BMARK_FOLDER &> /dev/null
    echo $BMARK_FOLDER
    for BMARK_OUTPUT in `ls large*.out`; do
        echo $BMARK_OUTPUT
        grep -P "real\t" $BMARK_OUTPUT | awk '{print $2}' | $SCRIPTDIR/parse_time.py
        echo
    done
    popd &> /dev/null
done

popd &> /dev/null
