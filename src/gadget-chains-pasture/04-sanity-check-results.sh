#!/bin/bash


BMARKS=(
    decker
    #pasture
)

pushd /home/rudy/wo/rop-benchmark/binaries/x86/reallife/vuln/debian-10-cloud

for BMARK in "${BMARKS[@]}"; do

    printf ${BMARK}" "
    ls ${BMARK}_pg*.bin.ropper.output | wc -l
    grep "Cannot create gadget: writewhatwhere" ${BMARK}_pg*.bin.ropper.output | wc -l
    grep "syscall opcode found" ${BMARK}_pg*.bin.ropper.output | wc -l
    grep "syscall opcode not found" ${BMARK}_pg*.bin.ropper.output | wc -l
done

popd
