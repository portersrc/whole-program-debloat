#!/bin/bash

if [ -f debrt-mapped-rx-pages.out ]; then
    cp debrt-mapped-rx-pages.out debrt-mapped-rx-pages-${WHICH}.out
fi

if [ -f debrt.out ]; then
    cp debrt.out debrt-${WHICH}.out
fi
