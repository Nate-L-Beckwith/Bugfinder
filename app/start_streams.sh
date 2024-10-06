# start_streams.sh

#!/bin/bash

# List of webcam devices
DEVICES=("/dev/video0" "/dev/video1")  # Update with your devices

# Corresponding stream names
STREAM_NAMES=("cam0" "cam1")  # Ensure this matches the number of devices

SERVER_URL="rtmp://localhost/live"  # Nginx RTMP server URL

# Loop through devices and start streaming
for i in "${!DEVICES[@]}"; do
    # Test if the device exists
    if [ -e "${DEVICES[$i]}" ]; then
        ffmpeg -f v4l2 -thread_queue_size 512 -i "${DEVICES[$i]}" \
        -c:v libx264 -preset veryfast -b:v 800k -maxrate 800k -bufsize 1600k \
        -f flv "${SERVER_URL}/${STREAM_NAMES[$i]}" > "/var/log/ffmpeg_${STREAM_NAMES[$i]}.log" 2>&1 &
    else
        echo "Device ${DEVICES[$i]} not found."
    fi
done

wait
