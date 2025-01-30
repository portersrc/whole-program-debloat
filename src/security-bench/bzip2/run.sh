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
    BIN=bzip2
    WHICH=base_ls
elif [ "$1" == "wpd" ]; then
    BIN=bzip2_wpd
    WHICH=wpd
    cp readelf-wpd.out readelf.out
    cp readelf-sections-wpd.out readelf-sections.out
    cp wpd_disjoint_sets.txt wpd_disjoint_sets.txt 
    cp wpd_encompassed_funcs.txt wpd_encompassed_funcs.txt
    cp wpd_static_reachability.txt wpd_static_reachability.txt
    cp wpd_loop_static_reachability.txt wpd_loop_static_reachability.txt
    cp wpd_loop_to_func.txt wpd_loop_to_func.txt
    cp wpd_static_reachability.txt wpd_static_reachability.txt
    cp wpd_loop_static_reachability.txt wpd_loop_static_reachability.txt
    cp wpd_stats.txt wpd_stats.txt
    cp wpd_func_name_to_id.txt wpd_func_name_to_id.txt
    cp wpd_func_name_has_addr_taken.txt wpd_func_name_has_addr_taken.txt
elif [ "$1" == "wpd_cl" ]; then
    BIN=bzip2_wpd_custlink
    WHICH=wpd_cl
    cp readelf-wpd-custlink.out readelf.out
    cp readelf-sections-wpd-custlink.out readelf-sections.out
    cp wpd_disjoint_sets.txt wpd_disjoint_sets.txt 
    cp wpd_encompassed_funcs.txt wpd_encompassed_funcs.txt
    cp wpd_static_reachability.txt wpd_static_reachability.txt
    cp wpd_loop_static_reachability.txt wpd_loop_static_reachability.txt
    cp wpd_loop_to_func.txt wpd_loop_to_func.txt
    cp wpd_static_reachability.txt wpd_static_reachability.txt
    cp wpd_loop_static_reachability.txt wpd_loop_static_reachability.txt
    cp wpd_stats.txt wpd_stats.txt
    cp wpd_func_name_to_id.txt wpd_func_name_to_id.txt
    cp wpd_func_name_has_addr_taken.txt wpd_func_name_has_addr_taken.txt
elif [ "$1" == "wpd_ics" ]; then
    BIN=bzip2_wpd_ics
    WHICH=wpd_ics
    cp readelf-ics.out readelf.out
    cp readelf-sections-ics.out readelf-sections.out
    cp wpd_disjoint_sets_ics.txt wpd_disjoint_sets.txt 
    cp wpd_encompassed_funcs_ics.txt wpd_encompassed_funcs.txt
    cp wpd_static_reachability_ics.txt wpd_static_reachability.txt
    cp wpd_loop_static_reachability_ics.txt wpd_loop_static_reachability.txt
    cp wpd_loop_to_func_ics.txt wpd_loop_to_func.txt
    cp wpd_loop_static_reachability_ics.txt wpd_loop_static_reachability.txt
    cp wpd_stats_ics.txt wpd_stats.txt
    cp wpd_func_name_to_id.txt wpd_func_name_to_id.txt
    cp wpd_func_name_has_addr_taken.txt wpd_func_name_has_addr_taken.txt
elif [ "$1" == "wpd_cl_ics" ]; then
    BIN=bzip2_wpd_custlink_ics
    WHICH=wpd_cl_ics
    cp readelf-custlink-ics.out readelf.out
    cp readelf-sections-custlink-ics.out readelf-sections.out
    cp readelf-ics.out readelf.out
    cp readelf-sections-ics.out readelf-sections.out
    cp wpd_disjoint_sets_ics.txt wpd_disjoint_sets.txt 
    cp wpd_encompassed_funcs_ics.txt wpd_encompassed_funcs.txt
    cp wpd_static_reachability_ics.txt wpd_static_reachability.txt
    cp wpd_loop_static_reachability_ics.txt wpd_loop_static_reachability.txt
    cp wpd_loop_to_func_ics.txt wpd_loop_to_func.txt
    cp wpd_loop_static_reachability_ics.txt wpd_loop_static_reachability.txt
    cp wpd_stats_ics.txt wpd_stats.txt
    cp wpd_func_name_to_id.txt wpd_func_name_to_id.txt
    cp wpd_func_name_has_addr_taken.txt wpd_func_name_has_addr_taken.txt
elif [ "$1" == "artd_profile" ]; then
    BIN=bzip2_artd_profile
    WHICH=artd_profile
elif [ "$1" == "artd_test_predict" ]; then
    BIN=bzip2_artd_test_predict
    WHICH=artd_test_predict
elif [ "$1" == "artd_release" ]; then
    BIN=bzip2_artd_release
    WHICH=artd_release
else
    usage_exit
fi

source ${PROJ_DIR}/src/spec/2017/run_aux_preprocess.sh

# 2024.11.02 porter
# adjusting this to match the experiments michael brown used in his usenix
# paper.
# note that his training inputs aren't enumerated in the paper, nor is it
# clear in the repo what to use. I'll choose one input from razor (the first)
# and report that in writing. (can also refer to my 2024.11.01 notes about
# what i saw when tried looking for all this).

DEBLOATER_EVAL_PATH=/home/rudy/wo/debloater-eval
TRAIN_INPUT_PATH=train
TRAIN_INPUT=aaa.txt
TEST_INPUT_PATH=${DEBLOATER_EVAL_PATH}/metrics/performance-tests/performance-benchmarks/inputs/bzip2
TEST_INPUT=20mb.bin

if [ "$2" == "small" ]; then
    INPUT=${TRAIN_INPUT_PATH}/${TRAIN_INPUT}
    OUTPUT=${TRAIN_INPUT}.bz2
    { time ./${BIN} -c -f <"${INPUT}" >"${OUTPUT}"; } &> small-${WHICH}.out

elif [ "$2" == "large" ]; then
    INPUT=${TEST_INPUT_PATH}/${TEST_INPUT}
    OUTPUT=${TEST_INPUT}.bz2
    rm -f large-${WHICH}.out
    rm -f large-${WHICH}.debrt
    #for run in {1..10}; do
        { /usr/bin/time -v "./${BIN}" -c -f <"${INPUT}" >"${OUTPUT}"; } &>> large-${WHICH}.out
        cat debrt.out &>> large-${WHICH}.debrt
    #done
else
    usage_exit
fi

## 2021.09.23 cporter note:
## 30/32 inputs are used. (a.txt and grammar.lsp are unused.)
#
#{ time ./${BIN} -c < test/cp.html; } &> 1-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_1_$1.out
#cp debrt.out debrt_1_$1.out
#
#{ time ./${BIN} -c < test/fields.c; } &> 2-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_2_$1.out
#cp debrt.out debrt_2_$1.out
#
#{ time ./${BIN} -c < test/paper2; } &> 3-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_3_$1.out
#cp debrt.out debrt_3_$1.out
#{ time ./${BIN} -c < test/paper3; } &> 4-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_4_$1.out
#cp debrt.out debrt_4_$1.out
#{ time ./${BIN} -c < test/paper4; } &> 5-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_5_$1.out
#cp debrt.out debrt_5_$1.out
#{ time ./${BIN} -c < test/paper5; } &> 6-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_6_$1.out
#cp debrt.out debrt_6_$1.out
#{ time ./${BIN} -c < test/paper6; } &> 7-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_7_$1.out
#cp debrt.out debrt_7_$1.out
#
#{ time ./${BIN} -c < test/progc; } &> 8-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_8_$1.out
#cp debrt.out debrt_8_$1.out
#{ time ./${BIN} -c < test/progl; } &> 9-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_9_$1.out
#cp debrt.out debrt_9_$1.out
#{ time ./${BIN} -c < test/progp; } &> 10-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_10_$1.out
#cp debrt.out debrt_10_$1.out
#
#{ time ./${BIN} -c < test/sum; } &> 11-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_11_$1.out
#cp debrt.out debrt_11_$1.out
#{ time ./${BIN} -c < test/trans; } &> 12-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_12_$1.out
#cp debrt.out debrt_12_$1.out
#
#{ time ./${BIN} -c < test/alice29.txt; } &> 13-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_13_$1.out
#cp debrt.out debrt_13_$1.out
#{ time ./${BIN} -c < test/alphabet.txt; } &> 14-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_14_$1.out
#cp debrt.out debrt_14_$1.out
#{ time ./${BIN} -c < test/asyoulik.txt; } &> 15-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_15_$1.out
#cp debrt.out debrt_15_$1.out
#{ time ./${BIN} -c < test/book2; } &> 16-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_16_$1.out
#cp debrt.out debrt_16_$1.out
#
#{ time ./${BIN} -c < test/geo; } &> 17-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_17_$1.out
#cp debrt.out debrt_17_$1.out
#{ time ./${BIN} -c < test/lcet10.txt; } &> 18-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_18_$1.out
#cp debrt.out debrt_18_$1.out
#{ time ./${BIN} -c < test/news; } &> 19-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_19_$1.out
#cp debrt.out debrt_19_$1.out
#{ time ./${BIN} -c < test/obj2; } &> 20-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_20_$1.out
#cp debrt.out debrt_20_$1.out
#
#{ time ./${BIN} -c < test/pic; } &> 21-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_21_$1.out
#cp debrt.out debrt_21_$1.out
#{ time ./${BIN} -c < test/plrabn12.txt; } &> 22-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_22_$1.out
#cp debrt.out debrt_22_$1.out
#
#{ time ./${BIN} -c < test/ptt5; } &> 23-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_23_$1.out
#cp debrt.out debrt_23_$1.out
#
#{ time ./${BIN} -c < test/random.txt; } &> 24-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_24_$1.out
#cp debrt.out debrt_24_$1.out
#
#{ time ./${BIN} -c < test/bible.txt; } &> 25-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_25_$1.out
#cp debrt.out debrt_25_$1.out
#
#{ time ./${BIN} -c < test/E.coli; } &> 26-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_26_$1.out
#cp debrt.out debrt_26_$1.out
#
#{ time ./${BIN} -c < test/kennedy.xls; } &> 27-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_27_$1.out
#cp debrt.out debrt_27_$1.out
#
#{ time ./${BIN} -c < test/pi.txt; } &> 28-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_28_$1.out
#cp debrt.out debrt_28_$1.out
#
#{ time ./${BIN} -c < test/world192.txt; } &> 29-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_29_$1.out
#cp debrt.out debrt_29_$1.out
#
#{ time ./${BIN} -c < test/xargs.1; } &> 30-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_30_$1.out
#cp debrt.out debrt_30_$1.out

source ${PROJ_DIR}/src/spec/2017/run_aux_postprocess.sh
