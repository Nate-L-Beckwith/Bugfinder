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
    /var/cache/nginx
    /var/www
    /home/bug/anaconda3
)

# Function to show progress
show_progress() {
    local msg="$1"
    shift
    local cmd=("$@")
    local delay="${SPINNER_DELAY:-0.1}"
    local spinstr="${SPINNER_CHARS:-'|/-\\'}"
    local temp

    # Start the command in the background
    "${cmd[@]}" &
    local pid=$!

    # Trap signals to clean up background process on script exit
    trap "kill $pid 2>/dev/null" SIGINT SIGTERM

    # Display the progress spinner
    printf "%s" "$msg"
    while kill -0 "$pid" 2>/dev/null; do
        temp="${spinstr#?}"
        printf " [%c]  " "$spinstr"
        spinstr="$temp${spinstr%"$temp"}"
        sleep "$delay"
        printf "\r\033[K%s" "$msg"
    done

    # Wait for the background process to finish
    wait "$pid"
    echo " [Done]"

    # Reset signal handling
    trap - SIGINT SIGTERM
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
