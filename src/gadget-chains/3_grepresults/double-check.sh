#!/bin/bash


BMARKS=(
    #500.perlbench
    #505.mcf
    #508.namd
    #510.parest
    #511.povray
    #519.lbm
    #520.omnetpp
    #523.xalancbmk
    #525.x264
    #531.deepsjeng
    #538.imagick
    #541.leela
    #544.nab
    #557.xz
    nginx
)

pushd /home/rudy/wo/rop-benchmark/binaries/x86/reallife/vuln/debian-10-cloud

for BMARK in "${BMARKS[@]}"; do

    printf ${BMARK}" "
    ls ${BMARK}_pg*.bin.ropper.output | wc -l
    #grep "Cannot create gadget: writewhatwhere" ${BMARK}_pg*.bin.ropper.output | wc -l
    #grep "syscall opcode found" ${BMARK}_pg*.bin.ropper.output | wc -l
    #grep "syscall opcode not found" ${BMARK}_pg*.bin.ropper.output | wc -l
done

popd
