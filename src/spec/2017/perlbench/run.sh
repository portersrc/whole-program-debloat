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

if [ "$1" == "base" ]; then
    BIN=500.perlbench_r_baseline
    WHICH=base
elif [ "$1" == "base_ls" ]; then
    BIN=500.perlbench_r_baseline_ls
    WHICH=base_ls
elif [ "$1" == "wpd" ]; then
    BIN=500.perlbench_r_wpd
    WHICH=wpd
elif [ "$1" == "wpd_cl" ]; then
    BIN=500.perlbench_r_wpd_custlink
    WHICH=wpd_cl
elif [ "$1" == "wpd_ls" ]; then
    BIN=500.perlbench_r_wpd_ls
    WHICH=wpd_ls
else
    usage_exit
fi

if [ "$2" == "small" ]; then
    { time ./${BIN} -I. -I./lib makerand.pl; } &> small-${WHICH}.out
    # another small inputs if i want to try:
    #{ time ./${BIN} -I. -I./lib test.pl; } &> small2-${WHICH}.out
elif [ "$2" == "medium" ]; then
    { time ./${BIN} -I./lib diffmail.pl 2 550 15 24 23 100; } &> medium-${WHICH}.out
    # more medium inputs if i want to try:
    #{ time ./${BIN} -I./lib perfect.pl b 3; } &> medium2-${WHICH}.out
    #{ time ./${BIN} -I. -I./lib scrabbl.pl < scrabbl.in; } &> mediumr3-${WHICH}.out
    #{ time ./${BIN} -I./lib splitmail.pl 535 13 25 24 1091 1; } &> medium4-${WHICH}.out
    #{ time ./${BIN} -I. -I./lib suns.pl; } &> medium5-${WHICH}.out
elif [ "$2" == "large" ]; then
    { time ./${BIN} -I./lib checkspam.pl 2500 5 25 11 150 1 1 1 1; } &> large-${WHICH}.out
    # more large inputs if i want to try:
    #{ time ./${BIN} -I./lib diffmail.pl 4 800 10 17 19 300; } &> large2-${WHICH}.out
    #{ time ./${BIN} -I./lib splitmail.pl 6400 12 26 16 100 0; } &> large3-${WHICH}.out
else
    usage_exit
fi
