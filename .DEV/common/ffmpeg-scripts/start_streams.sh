#!/bin/bash

# Directory containing the scripts
SCRIPT_DIR="/home/bug/Bugfinder/common/ffmpeg-scripts"

# Log file to store output and errors
LOG_FILE="/home/bug/Bugfinder/common/start_streams.log"

# Run each .sh file in the directory sequentially
for script in "$SCRIPT_DIR"/*.sh; 
do
    echo "Running $script..." | tee -a "$LOG_FILE"
    bash "$script" >> "$LOG_FILE" 2>&1
    if [ $? -ne 0 ]; then
        echo "Error running $script. Check the log file for details." | tee -a "$LOG_FILE"
    else
        echo "$script completed successfully." | tee -a "$LOG_FILE"
    fi
done

