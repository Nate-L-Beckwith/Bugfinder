#!/bin/bash

# Variables
SOURCE_DIR="$HOME/Bugfinder/nginx_d/"
DEST_DIR="/usr/local/nginx/"
EXCLUDE_FILE="$HOME/Bugfinder/deploy/nginx/rsync_nginx_exclude.txt"

# rsync command
sudo rsync -avzu --delete --exclude-from="$EXCLUDE_FILE" "$SOURCE_DIR" "$DEST_DIR"
