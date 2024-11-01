#!/bin/bash

# Packages to remove
packages=(
    make
    gcc
    g++
    libpcre3-dev
    zlib1g-dev
    libssl-dev
    ffmpeg
    python3*
    v4l-utils
    libv4l-dev
)

# Directories and files to remove
paths=(
    /usr/local/nginx
    /etc/src/nginx
    /etc/nginx
    /usr/sbin/nginx
    /var/run/nginx.pid
    /var/lock/nginx.lock
    /var/log/nginx
)

# Remove packages
sudo apt remove --purge -y "${packages[@]}"

# Remove directories and files
sudo rm -rf "${paths[@]}"

sudo apt autoremove -y
sudo apt autoclean
sudo apt clean
sudo apt update
sudo apt upgrade -y
sudo apt dist-upgrade -y

echo_message "Nginx and related packages have been removed."
