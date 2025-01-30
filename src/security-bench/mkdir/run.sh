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
    BIN=mkdir
    WHICH=base_ls
elif [ "$1" == "wpd" ]; then
    BIN=mkdir_wpd
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
    BIN=mkdir_wpd_custlink
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
    BIN=mkdir_wpd_ics
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
    BIN=mkdir_wpd_custlink_ics
    WHICH=wpd_cl_ics
    cp readelf-custlink-ics.out readelf.out
    cp readelf-sections-custlink-ics.out readelf-sections.out
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
    BIN=mkdir_artd_profile
    WHICH=artd_profile
elif [ "$1" == "artd_test_predict" ]; then
    BIN=mkdir_artd_test_predict
    WHICH=artd_test_predict
elif [ "$1" == "artd_release" ]; then
    BIN=mkdir_artd_release
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


if [ "$2" == "small" ]; then

    { time ./${BIN} d1; } &> small-${WHICH}.out


elif [ "$2" == "large" ]; then
    rm -f large-${WHICH}.out
    rm -f large-${WHICH}.debrt
    rm -rf /tmp/mkdir_benchmark
    rm -rf d1
    # BIN isn't working correclty inside /bin/bash -c i guess... hack this for now
    if [ "$1" == "base_ls" ]; then
        for run in {1..10}; do
            { /usr/bin/time -v /bin/bash -c './mkdir -p /tmp/mkdir_benchmark && \
    cd /tmp/mkdir_benchmark && \
    /home/rudy/wo/security-bench/artd/mkdir/mkdir -p d1 && \
    /home/rudy/wo/security-bench/artd/mkdir/mkdir -p d1/d2 && \
    /home/rudy/wo/security-bench/artd/mkdir/mkdir -p d1/d2/d3/d4 && \
    /home/rudy/wo/security-bench/artd/mkdir/mkdir -p d1 && \
    /home/rudy/wo/security-bench/artd/mkdir/mkdir -p d1/d2'; } &>> large-${WHICH}.out
            cat debrt.out &>> large-${WHICH}.debrt
        done
    elif  [ "$1" == "artd_release" ]; then
        # NOTE porter: I moved the cd /tmp/mkdir_benchmark to be the last
        # command b/c all of the ad-hoc files that the runtime needs (artd*.txt
        # files, etc.) are not available there. But keeping it as the last
        # command is at least truer to the (very very fast) execution time.
        # I also put `rm -rf d1` abovebecause otherwise this mkdir folder
        # would get polluted with it.
        #for run in {1..10}; do
            { /usr/bin/time -v /bin/bash -c './mkdir_artd_release -p /tmp/mkdir_benchmark && \
    /home/rudy/wo/security-bench/artd/mkdir/mkdir_artd_release -p d1 && \
    /home/rudy/wo/security-bench/artd/mkdir/mkdir_artd_release -p d1/d2 && \
    /home/rudy/wo/security-bench/artd/mkdir/mkdir_artd_release -p d1/d2/d3/d4 && \
    /home/rudy/wo/security-bench/artd/mkdir/mkdir_artd_release -p d1 && \
    /home/rudy/wo/security-bench/artd/mkdir/mkdir_artd_release -p d1/d2 && \
    cd /tmp/mkdir_benchmark'; } &>> large-${WHICH}.out
            cat debrt.out &>> large-${WHICH}.debrt
        #done
        rm -rf d1
    else
        echo "Error: should be base_ls or artd_release"
        exit 1
    fi

else
    usage_exit
fi






# 2021.09.24 cporter: razor paper reports 24 tests, but the run-razor.py
# script has 25 tests. We replicate all 25 tests.
# Also, the original tests don't `rm -rf d1` between each test. We replicate
# whatever they did. This makes testing pretty manual, at the moment, because
# if a test fails, I sometimes have to `rm -rf d1` or whatever and rerun a
# prior test to get back to the proper state before kicking off the next test.

# 2021.09.24 cporter: This test returns 1
#{ time ./${BIN} d1/d2/d3; } &> 1-${WHICH}.out
#rm -rf d1
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_1_$1.out
#cp debrt.out debrt_1_$1.out

#{ time ./${BIN} -p d1/d2/d3; } &> 2-${WHICH}.out
#rm -rf d1
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_2_$1.out
#cp debrt.out debrt_2_$1.out

#{ time ./${BIN} -p -m 567 d1/d2/d3; } &> 3-${WHICH}.out
#rm -rf d1
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_3_$1.out
#cp debrt.out debrt_3_$1.out

# 2021.09.24 cporter: This test returns 1
#{ time ./${BIN} -m 777 d1/d2; } &> 4-${WHICH}.out
#rm -rf d1
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_4_$1.out
#cp debrt.out debrt_4_$1.out

#{ time ./${BIN} -p -m 777 d1/d2/d3; } &> 5-${WHICH}.out
#rm -rf d1
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_5_$1.out
#cp debrt.out debrt_5_$1.out

#{ time ./${BIN} -p -m 777 d1/d2/d3; } &> 6-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_6_$1.out
#cp debrt.out debrt_6_$1.out
#{ time ./${BIN} -p -m 500 d1/d2/d3/d4; } &> 7-${WHICH}.out
#rm -rf d1
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_7_$1.out
#cp debrt.out debrt_7_$1.out

#{ time ./${BIN} -p -m 555 d1/d2/d3/d4; } &> 8-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_8_$1.out
#cp debrt.out debrt_8_$1.out
#{ time ./${BIN} -m 644 d1/d2/d3/d5; } &> 9-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_9_$1.out
#cp debrt.out debrt_9_$1.out
#{ time ./${BIN} -m 610 d1/d6; } &> 10-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_10_$1.out
#cp debrt.out debrt_10_$1.out
# 2021.09.24 cporter: This test returns 1
#{ time ./${BIN} -m 777 d1/d6/d7; } &> 11-${WHICH}.out
#rm -rf d1
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_11_$1.out
#cp debrt.out debrt_11_$1.out

#{ time ./${BIN} -p -m 777 d1/d2/d3; } &> 12-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_12_$1.out
#cp debrt.out debrt_12_$1.out
# 2021.09.24 cporter: This test returns 1
#{ time ./${BIN} -m 555 d1/d2/d3; } &> 13-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_13_$1.out
#cp debrt.out debrt_13_$1.out
#{ time ./${BIN} -m 644 d1/d2/d3/d4; } &> 14-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_14_$1.out
#cp debrt.out debrt_14_$1.out
# 2021.09.24 cporter: This test returns 1
#{ time ./${BIN} -m 610 d1/d2/d3/d4/d5; } &> 15-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_15_$1.out
#cp debrt.out debrt_15_$1.out
# 2021.09.24 cporter: This test returns 1
#{ time ./${BIN} -m 777 d1/d2/d3/d4/d5/d6; } &> 16-${WHICH}.out
#rm -rf d1
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_16_$1.out
#cp debrt.out debrt_16_$1.out

#{ time ./${BIN} -p -m 777 d1/d2/d3; } &> 17-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_17_$1.out
#cp debrt.out debrt_17_$1.out
#{ time ./${BIN} -m 555 d1/d2/d4; } &> 18-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_18_$1.out
#cp debrt.out debrt_18_$1.out
#{ time ./${BIN} -m 644 d1/d2/d5; } &> 19-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_19_$1.out
#cp debrt.out debrt_19_$1.out
#{ time ./${BIN} -m 610 d1/d2/d6; } &> 20-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_20_$1.out
#cp debrt.out debrt_20_$1.out
#{ time ./${BIN} -m 777 d1/d2/d7; } &> 21-${WHICH}.out
#rm -rf d1
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_21_$1.out
#cp debrt.out debrt_21_$1.out

#{ time ./${BIN} -p d1/d2/d3; } &> 22-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_22_$1.out
#cp debrt.out debrt_22_$1.out
#{ time ./${BIN} -p d1/d2/d3/d4; } &> 23-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_23_$1.out
#cp debrt.out debrt_23_$1.out
#{ time ./${BIN} -p d1/d2/d3/d5; } &> 24-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_24_$1.out
#cp debrt.out debrt_24_$1.out
#{ time ./${BIN} -p d1/d2/d3/d5/d6; } &> 25-${WHICH}.out
#rm -rf d1
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_25_$1.out
#cp debrt.out debrt_25_$1.out

source ${PROJ_DIR}/src/spec/2017/run_aux_postprocess.sh
