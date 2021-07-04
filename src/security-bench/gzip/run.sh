#!/bin/bash
set -euox pipefail

function usage_exit() {
    echo
    echo "Usage: ./run.sh <which-binary> <which-input>"
    echo
    exit 1
}

if [ $# != 2 ]; then
    usage_exit
fi

if [ "$1" == "base_ls" ]; then
    BIN=gzip_nostatic
    WHICH=base_ls
elif [ "$1" == "base_ls_static" ]; then
    BIN=gzip_static
    WHICH=base_ls_static
elif [ "$1" == "wpd" ]; then
    BIN=gzip_wpd_nostatic
    WHICH=wpd
elif [ "$1" == "wpd_static" ]; then
    BIN=gzip_wpd_static
    WHICH=wpd_static
elif [ "$1" == "wpd_cl" ]; then
    BIN=gzip_wpd_custlink_nostatic
    WHICH=wpd_cl
elif [ "$1" == "wpd_cl_static" ]; then
    BIN=gzip_wpd_custlink_static
    WHICH=wpd_cl_static
else
    usage_exit
fi

if [ "$2" == "small" ]; then
    # { time ./${BIN} -c < test/cp.html; } &> small-${WHICH}.out
    # { time ./${BIN} -c < test/fields.c; } &> small-${WHICH}.out
    # { time ./${BIN} -c < test/paper2; } &> small-${WHICH}.out
    # { time ./${BIN} -c < test/paper3; } &> small-${WHICH}.out
    # { time ./${BIN} -c < test/paper4; } &> small-${WHICH}.out
    # { time ./${BIN} -c < test/paper5; } &> small-${WHICH}.out
    # { time ./${BIN} -c < test/paper6; } &> small-${WHICH}.out
    # { time ./${BIN} -c < test/progc; } &> small-${WHICH}.out
    # { time ./${BIN} -c < test/progl; } &> small-${WHICH}.out
    # { time ./${BIN} -c < test/progp; } &> small-${WHICH}.out
    # { time ./${BIN} -c < test/sum; } &> small-${WHICH}.out
    { time ./${BIN} -c < test/trans; } &> small-${WHICH}.out
elif [ "$2" == "medium" ]; then
    # { time ./${BIN} -c < test/alice29.txt; } &> medium-${WHICH}.out
    # { time ./${BIN} -c < test/alphabet.txt; } &> medium-${WHICH}.out
    # { time ./${BIN} -c < test/asyoulik.txt; } &> medium-${WHICH}.out
    # { time ./${BIN} -c < test/book2; } &> medium-${WHICH}.out
    # { time ./${BIN} -c < test/geo; } &> medium-${WHICH}.out
    # { time ./${BIN} -c < test/lcet10.txt; } &> medium-${WHICH}.out
    # { time ./${BIN} -c < test/news; } &> medium-${WHICH}.out
    # { time ./${BIN} -c < test/obj2; } &> medium-${WHICH}.out
    { time ./${BIN} -c < test/pic; } &> medium-${WHICH}.out
    # { time ./${BIN} < test/plrabn12.txt; } &> medium-${WHICH}.out
    # { time ./${BIN} < test/ptt5; } &> medium-${WHICH}.out
    # { time ./${BIN} < test/random.txt; } &> medium-${WHICH}.out
elif [ "$2" == "large" ]; then
    # { time ./${BIN} -c < test/bible.txt; } &> large-${WHICH}.out
    { time ./${BIN} -c < test/E.coli; } &> large-${WHICH}.out
    # { time ./${BIN} -c < test/kennedy.xls; } &> large-${WHICH}.out
    # { time ./${BIN} -c < test/pi.txt; } &> large-${WHICH}.out
    # { time ./${BIN} -c < test/world192.txt; } &> large-${WHICH}.out
else
    usage_exit
fi

cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_$1.out
cp debrt.out debrt_$1.out