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
    /home/bug/anaconda3
)

# Function to show progress
show_progress() {
    local -r msg=$1
    local -r pid=$2
    local -r delay=0.1
    local spinstr='|/-\'
    echo -n "$msg"
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    echo " [Done]"
}

# Remove packages
sudo apt remove --purge -y "${packages[@]}" &
show_progress "Removing packages..." $!

# Remove directories and files
sudo rm -rf "${paths[@]}" &
show_progress "Removing directories and files..." $!

sudo apt autoremove -y
sudo apt autoclean -y
sudo apt clean
sudo apt update
sudo apt upgrade -y
sudo apt dist-upgrade -y

echo "Nginx and related packages have been removed."
