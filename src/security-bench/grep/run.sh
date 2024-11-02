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
    BIN=grep
    WHICH=base_ls
elif [ "$1" == "wpd" ]; then
    BIN=grep_wpd
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
    BIN=grep_wpd_custlink
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
    BIN=grep_wpd_ics
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
    BIN=grep_wpd_custlink_ics
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
    BIN=grep_artd_profile
    WHICH=artd_profile
elif [ "$1" == "artd_test_predict" ]; then
    BIN=grep_artd_test_predict
    WHICH=artd_test_predict
elif [ "$1" == "artd_release" ]; then
    BIN=grep_artd_release
    WHICH=artd_release
else
    usage_exit
fi


source ${PROJ_DIR}/src/spec/2017/run_aux_preprocess.sh

#{ time ./${BIN} "a" test1; } &> 1-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_1_$1.out
#cp debrt.out debrt_1_$1.out
#{ time ./${BIN} "a" ./test2; } &> 2-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_2_$1.out
#cp debrt.out debrt_2_$1.out

# 2021.09.24 cporter: This test has a return value of 1.
#{ time ./${BIN} -n "si" ./test1; } &> 3-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_3_$1.out
#cp debrt.out debrt_3_$1.out

#{ time ./${BIN} -n "si" ./test2; } &> 4-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_4_$1.out
#cp debrt.out debrt_4_$1.out

# 2021.09.24 cporter: This test has a return value of 1.
#{ time ./${BIN} -o [r][a][n][d]* ./test1; } &> 5-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_5_$1.out
#cp debrt.out debrt_5_$1.out

#{ time ./${BIN} -o [r][a][n][d]* ./test2; } &> 6-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_6_$1.out
#cp debrt.out debrt_6_$1.out

# 2021.09.24 cporter: This test has a return value of 1.
#{ time ./${BIN} -v "a" ./test1; } &> 7-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_7_$1.out
#cp debrt.out debrt_7_$1.out

#{ time ./${BIN} -v "a" ./test2; } &> 8-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_8_$1.out
#cp debrt.out debrt_8_$1.out

# 2021.09.24 cporter: This test has a return value of 1.
#{ time ./${BIN} -i "Si" ./test1; } &> 9-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_9_$1.out
#cp debrt.out debrt_9_$1.out

#{ time ./${BIN} -i "Si" ./test2; } &> 10-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_10_$1.out
#cp debrt.out debrt_10_$1.out

# 2021.09.24 cporter: This test has a return value of 1.
#{ time ./${BIN} -w "Si" ./test1; } &> 11-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_11_$1.out
#cp debrt.out debrt_11_$1.out

# 2021.09.24 cporter: This test has a return value of 1.
#{ time ./${BIN} -w "Si" ./test2; } &> 12-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_12_$1.out
#cp debrt.out debrt_12_$1.out

# 2021.09.24 cporter: This test has a return value of 1.
#{ time ./${BIN} -x "Don't" ./test1; } &> 13-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_13_$1.out
#cp debrt.out debrt_13_$1.out

# 2021.09.24 cporter: This test has a return value of 1.
#{ time ./${BIN} -x "Don't" ./test2; } &> 14-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_14_$1.out
#cp debrt.out debrt_14_$1.out

# 2021.09.24 cporter: This test has a return value of 1.
#{ time ./${BIN} -E "randomtext*" ./test1; } &> 15-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_15_$1.out
#cp debrt.out debrt_15_$1.out

# 2021.09.24 cporter: This test has a return value of 1.
#{ time ./${BIN} -E "randomtext*" ./test2; } &> 16-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_16_$1.out
#cp debrt.out debrt_16_$1.out

# 2021.09.24 cporter: This test has a return value of 1.
#{ time ./${BIN} "ye " ./test1; } &> 17-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_17_$1.out
#cp debrt.out debrt_17_$1.out

#{ time ./${BIN} "ye " ./test2; } &> 18-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_18_$1.out
#cp debrt.out debrt_18_$1.out

# 2021.09.24 cporter: This test has a return value of 1.
#{ time ./${BIN} "cold" ./test1; } &> 19-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_19_$1.out
#cp debrt.out debrt_19_$1.out

# 2021.09.24 cporter: This test has a return value of 1.
#{ time ./${BIN} "cold" ./test2; } &> 20-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_20_$1.out
#cp debrt.out debrt_20_$1.out

# 2021.09.24 cporter: This test has a return value of 1.
#{ time ./${BIN} "not exist" ./test1; } &> 21-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_21_$1.out
#cp debrt.out debrt_21_$1.out

#{ time ./${BIN} "not exist" ./test2; } &> 22-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_22_$1.out
#cp debrt.out debrt_22_$1.out

# 2021.09.24 cporter: This test has a return value of 1.
#{ time ./${BIN} ^D  ./test1; } &> 23-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_23_$1.out
#cp debrt.out debrt_23_$1.out

#{ time ./${BIN} ^D  ./test2; } &> 24-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_24_$1.out
#cp debrt.out debrt_24_$1.out
#{ time ./${BIN} .$  ./test1; } &> 25-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_25_$1.out
#cp debrt.out debrt_25_$1.out
#{ time ./${BIN} .$  ./test2; } &> 26-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_26_$1.out
#cp debrt.out debrt_26_$1.out
#{ time ./${BIN} \^  ./test1; } &> 27-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_27_$1.out
#cp debrt.out debrt_27_$1.out
#{ time ./${BIN} \^  ./test2; } &> 28-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_28_$1.out
#cp debrt.out debrt_28_$1.out

# 2021.09.24 cporter: This test has a return value of 1.
#{ time ./${BIN} \^$  ./test1; } &> 29-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_29_$1.out
#cp debrt.out debrt_29_$1.out

# 2021.09.24 cporter: This test has a return value of 1.
#{ time ./${BIN} \^$  ./test2; } &> 30-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_30_$1.out
#cp debrt.out debrt_30_$1.out

# 2021.09.24 cporter: This test has a return value of 1.
#{ time ./${BIN} ^[AEIOU]  ./test1; } &> 31-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_31_$1.out
#cp debrt.out debrt_31_$1.out

#{ time ./${BIN} ^[AEIOU]  ./test2; } &> 32-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_32_$1.out
#cp debrt.out debrt_32_$1.out
#{ time ./${BIN} ^[^AEIOU]  ./test1; } &> 33-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_33_$1.out
#cp debrt.out debrt_33_$1.out
#{ time ./${BIN} ^[^AEIOU]  ./test2; } &> 34-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_34_$1.out
#cp debrt.out debrt_34_$1.out

# 2021.09.24 cporter: This test has a return value of 1.
#{ time ./${BIN} -E "free[^[:space:]]+"  ./test1; } &> 35-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_35_$1.out
#cp debrt.out debrt_35_$1.out

#{ time ./${BIN} -E "free[^[:space:]]+"  ./test2; } &> 36-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_36_$1.out
#cp debrt.out debrt_36_$1.out

# 2021.09.24 cporter: This test has a return value of 1.
#{ time ./${BIN} -E '\b(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?\.)3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)'  ./test1; } &> 37-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_37_$1.out
#cp debrt.out debrt_37_$1.out

# 2021.09.24 cporter: This test has a return value of 1.
#{ time ./${BIN} -E '\b(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?\.)3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)'  ./test2; } &> 38-${WHICH}.out
#cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages_38_$1.out
#cp debrt.out debrt_38_$1.out

source ${PROJ_DIR}/src/spec/2017/run_aux_postprocess.sh