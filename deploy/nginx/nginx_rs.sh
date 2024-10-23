#!/bin/bash


sudo rsync -avzu --delete --exclude-from="$EXCLUDE_FILE" "$SOURCE_DIR" "$DEST_DIR"
