#!/bin/bash
set -euxo pipefail

./make.sh
./run.sh
./post-process.sh
./learn.sh
