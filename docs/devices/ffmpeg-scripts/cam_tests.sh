#!/bin/bash

# Array of video devices
VIDEO_DEVICES=("/dev/video0" "/dev/video2")  # Replace with your actual devices

# Stream settings
WIDTH=640
HEIGHT=480
FPS=30

# Loop through each device and start streaming
for DEVICE in "${VIDEO_DEVICES[@]}"; do
    PORT=$((8000 + ${DEVICE: -1}))  # Generate a port number based on device number
    echo "Starting stream for $DEVICE on port $PORT"
    ffmpeg -f v4l2 -framerate $FPS -video_size ${WIDTH}x${HEIGHT} -i $DEVICE \
           -codec:v libx264 -preset veryfast -f mpegts udp://localhost:$PORT &
done

echo "All streams started."
