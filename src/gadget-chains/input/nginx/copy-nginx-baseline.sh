#!/bin/bash
set -euxo pipefail


NGINX_HOME=/home/rudy/wo/nginx/objs
NGINX_BIN=nginx_baseline_ls


cp \
  $NGINX_HOME/$NGINX_BIN \
  nginx/

