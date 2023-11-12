#!/bin/bash

rm -f debrt_decision_tree.h

if [ $# -eq 1 ]; then
    ln -s DTs/$1.h debrt_decision_tree.h
else
    echo "ERROR: Please supply the benchmark DT to use, e.g. xz or parest"
    exit 1
fi



#ln -s DTs/default.h debrt_decision_tree.h
#ln -s DTs/09-test.h debrt_decision_tree.h

#ln -s DTs/namd.h debrt_decision_tree.h
#ln -s DTs/lbm.h debrt_decision_tree.h
#ln -s DTs/mcf.h debrt_decision_tree.h
#ln -s DTs/xz.h debrt_decision_tree.h
#ln -s DTs/nab.h debrt_decision_tree.h
#ln -s DTs/leela.h debrt_decision_tree.h
#ln -s DTs/omnetpp.h debrt_decision_tree.h
#ln -s DTs/parest.h debrt_decision_tree.h
#ln -s DTs/perlbench.h debrt_decision_tree.h
#ln -s DTs/povray.h debrt_decision_tree.h
#ln -s DTs/x264.h debrt_decision_tree.h
#ln -s DTs/deepsjeng.h debrt_decision_tree.h
#ln -s DTs/imagick.h debrt_decision_tree.h
#ln -s DTs/gcc.h debrt_decision_tree.h
#ln -s DTs/xalancbmk.h debrt_decision_tree.h
#ln -s DTs/blender.h debrt_decision_tree.h
