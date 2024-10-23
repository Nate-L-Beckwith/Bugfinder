#!/bin/bash
sudo mkdir -p /src/nginx/modules
export NGINX_VERSION="1.27.2"
export NGINX_SRC_DIR="/src/nginx"
export NGINX_MODULE_DIR="/src/nginx/modules"
export NGINX_DEPLOY_DIR="$HOME/Bugfinder/deploy/nginx" 

export NGINX_DIR="/src/nginx/nginx-$NGINX_VERSION"
export DEV_SOURCE_DIR="$HOME/Bugfinder/nginx_d/configurations"
export DEST_DIR="/etc/nginx/"
export EXCLUDE_FILE="$NGINX_DEPLOY_DIR/rsync_nginx_exclude.txt"


echo $NGINX_VERSION $NGINX_DIR $NGINX_MODULE_DIR $NGINX_SRC_DIR
