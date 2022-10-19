#!/bin/bash

docker run \
  -it \
  --rm \
  --network host \
  -w /root/decker \
  -e HOST_PERMS="$(id -u):$(id -g)" \
  --name decker-ae \
  decker:latest \
  /bin/bash
