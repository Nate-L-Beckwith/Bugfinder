#!/bin/bash

# Function to run commands with sudo
run_with_sudo() {
    sudo "$@"
}

# Check versions of ffmpeg and nginx
run_with_sudo ffmpeg -version && run_with_sudo nginx -v

# List device information and save to devices_list.txt
{
    echo "Devices:"
    run_with_sudo v4l2-ctl --list-devices
    echo

    echo "Formats:"
    run_with_sudo v4l2-ctl --list-formats-ext
    echo

    echo "Standards:"
    run_with_sudo v4l2-ctl --list-standards
    echo

    echo "Inputs:"
    run_with_sudo v4l2-ctl --list-inputs
    echo

    echo "Controls:"
    run_with_sudo v4l2-ctl --list-ctrls
    echo

    echo "Controls Menu:"
    run_with_sudo v4l2-ctl --list-ctrls-menu
} | tee devices_list.txt

    echo "Device information saved to devices_list.txt"
cat devices_list.txt