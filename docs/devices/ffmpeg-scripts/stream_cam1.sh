#!/bin/bash

# ffmpeg-scripts/stream_cam1.sh

# Export PATH to ensure ffmpeg is found
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Start FFmpeg streaming and log output with timestamps
{
    echo "[$(date)] Starting FFmpeg streaming..."
    ffmpeg -f v4l2 -input_format mjpeg -i /dev/video1 \
           -c:v libx264 -preset ultrafast -f flv \
           rtmp://localhost/live/cam1
    echo "[$(date)] FFmpeg streaming stopped."
} >> /var/log/stream_cam1.log 2>&1
