#!/bin/bash

#for F in `ls ../*.bin`; do
#    echo $F
#    objcopy -O binary --only-section=.text $F $F.text
#    mv $F.text .
#done




function dump_ropgadget_jop_count() {
    rm -f $OUTPUT_FILENAME
    for F in `ls *.text`; do
        echo $F
        VAL=$(/home/rudy/wo/debloat/ROPgadget/ROPgadget.py --rawArch x86 --rawMode 64 --norop --nosys --depth 5 --binary $F | grep " jmp " | wc -l)
        echo "${F}: ${VAL}" >> $OUTPUT_FILENAME
    done
}

function dump_ropgadget_jop() {
    mkdir -p $OUTPUT_FILENAME
    for F in `ls *.text`; do
        #echo $F
        FILENAME=$F
        #FILENAME=$(basename -- "$FILENAME") # cuts the path (dont need to do)
        #EXTENSION="${FILENAME##*.}"  # grab the extension (dont need it)
        FILENAME="${FILENAME%.*}"    # grab filename without extension (.text)
        #EXTENSION="${FILENAME##*.}"  # grab the second extension (dont need it)
        FILENAME="${FILENAME%.*}"    # grab filename without second extension (.bin)
        PG=${FILENAME:9}       # chop off "nginx_pg_"
        echo $PG
        /home/rudy/wo/debloat/ROPgadget/ROPgadget.py --rawArch x86 --rawMode 64 --norop --nosys --depth 5 --binary $F | grep " jmp " > ${OUTPUT_FILENAME}/${OUTPUT_FILENAME}-pg_${PG}
    done
}




#OUTPUT_FILENAME=out-jop-count
#dump_ropgadget_jop_count

OUTPUT_FILENAME=out-jop
dump_ropgadget_jop
