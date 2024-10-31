#!/bin/bash

sudo apt update && sudo apt upgrade -y

sudo apt install -y git curl wget vim rsync \
    build-essential cmake python3 python3-pip \
    libjpeg-dev libtiff-dev libpng-dev libavcodec-dev \
    libavformat-dev libswscale-dev libv4l-dev \
    libxvidcore-dev libx264-dev libgtk-3-dev \
    python3-flask v4l-utils qv4l2 \
    libatlas-base-dev gfortran libhdf5-dev \
    libhdf5-103 ffmpeg \
    libavcodec-extra libavutil-dev  \
    libavdevice-dev libavfilter-dev libpostproc-dev \
    libswresample-dev

sudo apt autoclean && sudo apt autoremove


echo "Done"
