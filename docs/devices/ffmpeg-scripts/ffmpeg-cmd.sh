
ffmpeg -f v4l2 -input_format mjpeg -video_size 1280x720 -framerate 30 -i /dev/video0 \
-c:v libx264 -preset ultrafast -tune zerolatency \
-f hls -hls_time 2 -hls_list_size 5 -hls_flags delete_segments+append_list /tmp/hls/stream.m3u8
