#!/bin/bash
set -euxo pipefail

# cporter 2021.09.28
# Copy the "pg" (page group) binaries for each benchmark into the "orig"
# folder for rop-benchmark. This is essentially a staging area. Then execute
# make. This will link the vuln.o against each pg bin file and produce
# an executable for each one here:
#   /home/rudy/wo/rop-benchmark/binaries/x86/reallife/vuln/debian-10-cloud
#




if [ $# == 1 ]; then
    BMARKS=(
        $1
    )
else
    BMARKS=(
        bzip2
        chown
        date
        grep
        gzip
        mkdir
        rm
        sort
        tar
        uniq
    )
fi




for BMARK in "${BMARKS[@]}"; do

    pushd /home/rudy/wo/whole-program-debloat/src/gadget-chains/output/${BMARK}
    cp *_pg_*.bin /home/rudy/wo/rop-benchmark/binaries/x86/reallife/orig/debian-10-cloud

    pushd /home/rudy/wo/rop-benchmark/binaries/x86/reallife
    make
    popd

    popd

done
echo "done"
