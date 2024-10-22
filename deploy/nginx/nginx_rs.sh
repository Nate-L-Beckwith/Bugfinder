#!/bin/bash

# Variables
SOURCE_DIR="$HOME/Bugfinder/nginx_d/"
DEST_DIR="/usr/local/nginx/"
EXCLUDE_FILE="$HOME/home/bug/Bugfinder/deploy/rsync_nginx_exclude.txt"

# rsync command
sudo rsync -avz --delete --exclude-from="$EXCLUDE_FILE" "$SOURCE_DIR" "$DEST_DIR"
