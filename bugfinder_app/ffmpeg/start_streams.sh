#!/bin/bash

# Start streaming Camera 1
ffmpeg -f v4l2 -i /dev/video0 -vcodec libx264 -preset ultrafast -tune zerolatency -b:v 1500k -maxrate 1500k -bufsize 1000k -pix_fmt yuv420p -g 50 -f flv rtmp://127.0.0.1/live/camera1 &

# Start streaming Camera 2
ffmpeg -f v4l2 -i /dev/video2 -vcodec libx264 -preset ultrafast -tune zerolatency -b:v 1500k -maxrate 1500k -bufsize 1000k -pix_fmt yuv420p -g 50 -f flv rtmp://127.0.0.1/live/camera2 &

# Start streaming Camera 3
ffmpeg -f v4l2 -i /dev/video6 -vcodec libx264 -preset ultrafast -tune zerolatency -b:v 1500k -maxrate 1500k -bufsize 1000k -pix_fmt yuv420p -g 50 -f flv rtmp://127.0.0.1/live/camera3 &
