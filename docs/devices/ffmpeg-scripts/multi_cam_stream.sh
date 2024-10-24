#!/bin/bash

# Stream from two webcams to an RTMP server (Nginx or any RTMP server)
ffmpeg -f v4l2 -framerate 30 -video_size 640x480 -i /dev/video0 \
       -f v4l2 -framerate 30 -video_size 640x480 -i /dev/video1 \
       -filter_complex "[0:v]scale=640:480[cam1];[1:v]scale=640:480[cam2];[cam1][cam2]hstack" \
       -c:v libx264 -preset veryfast -f flv rtmp://your-server-ip/app/stream_key
