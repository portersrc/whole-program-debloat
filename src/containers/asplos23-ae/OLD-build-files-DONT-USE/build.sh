#!/bin/bash
set -x

docker build \
  --network host \
  -t decker:latest \
  .
