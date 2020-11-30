#!/bin/bash

FOLDERS=(
    401.bzip2/build/build_base_amd64-m64-gcc43-nn.0000
    403.gcc/build/build_base_amd64-m64-gcc43-nn.0000
    429.mcf/build/build_base_amd64-m64-gcc43-nn.0001
    433.milc/build/build_base_amd64-m64-gcc43-nn.0000
    444.namd/build/build_base_amd64-m64-gcc43-nn.0000
    445.gobmk/build/build_base_amd64-m64-gcc43-nn.0001
    450.soplex/build/build_base_amd64-m64-gcc43-nn.0001
    453.povray/build/build_base_amd64-m64-gcc43-nn.0001
    456.hmmer/build/build_base_amd64-m64-gcc43-nn.0000
    458.sjeng/build/build_base_amd64-m64-gcc43-nn.0000
    462.libquantum/build/build_base_amd64-m64-gcc43-nn.0000
    464.h264ref/build/build_base_amd64-m64-gcc43-nn.0000
    470.lbm/build/build_base_amd64-m64-gcc43-nn.0000
    471.omnetpp/build/build_base_amd64-m64-gcc43-nn.0000
    473.astar/build/build_base_amd64-m64-gcc43-nn.0000
    482.sphinx3/build/build_base_amd64-m64-gcc43-nn.0000
)

pushd /home/rudy/wo/spec/spec2006/benchspec/CPU2006 &> /dev/null

for FOLDER in ${FOLDERS[@]}; do
    pushd $FOLDER &> /dev/null
    du -sk *_debprof
    popd &> /dev/null
done
