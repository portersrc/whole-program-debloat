#!/bin/bash

echo "See comments in this script and edit to run"

#
# This is a one-liner script, but I'm checking in for the record.
# To get the artd-datalog-ensue.out file, just run datalog on the
# artd-datalog.out file. The artd-datalog.out file is output by the compiler
# pass and sits in the benchmark's spec folder. So, the command inside
# the benchmark's folder is just:
#   time /home/rudy/wo/datalog/datalog-2.6/datalog artd-datalog.out -o artd-datalog-ensue.out; echo $?
#
