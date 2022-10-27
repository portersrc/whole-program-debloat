#!/bin/bash

readelf -s --wide ${BIN}  > readelf.out
cp readelf.out readelf-${WHICH}.out

readelf --sections ${BIN} > readelf-sections.out
cp readelf-sections.out readelf-sections-${WHICH}.out
