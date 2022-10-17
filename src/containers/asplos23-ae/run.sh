#!/bin/bash

docker run \
  -it \
  --rm \
  --network host \
  -w /root/decker \
  -e HOST_PERMS="$(id -u):$(id -g)" \
  -v /home/rudy:/mnt \
  --name decker-ae \
  decker-07:latest \
  /bin/bash
