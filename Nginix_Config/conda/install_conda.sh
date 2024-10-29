#!/bin/bash

ANACONDA_VERSION="2024.10-1"
ANACONDA_INSTALL_DIR="$HOME/anaconda3"
ANACONDA_INSTALLER="Anaconda3-${ANACONDA_VERSION}-Linux-x86_64.sh"
ANACONDA_URL="https://repo.anaconda.com/archive/${ANACONDA_INSTALLER}"

# Function to print messages
function echo_message {
    echo -e "\n====================\n$1\n====================\n"
}

# Check if Anaconda is already installed
if [ -d "$ANACONDA_INSTALL_DIR" ]; then
    echo_message "Anaconda is already installed in $ANACONDA_INSTALL_DIR."
else
    # Download Anaconda installer
    echo_message "Downloading Anaconda installer..."
    wget -O "$ANACONDA_INSTALLER" "$ANACONDA_URL"

    # Verify the installer exists
    if [ ! -f "$ANACONDA_INSTALLER" ]; then
        echo_message "Failed to download Anaconda installer."
        exit 1
    fi

    # Run the Anaconda installer without sudo
    echo_message "Running the Anaconda installer..."
    bash "$ANACONDA_INSTALLER" -b -p "$ANACONDA_INSTALL_DIR"

    # Add Anaconda to PATH in ~/.bashrc
    echo_message "Adding Anaconda to PATH..."
    echo "export PATH=\"$ANACONDA_INSTALL_DIR/bin:\$PATH\"" >> ~/.bashrc

    # Update PATH for the current script
    export PATH="$ANACONDA_INSTALL_DIR/bin:$PATH"

    # Initialize Conda for the current script
    echo_message "Initializing Conda..."
    source "$ANACONDA_INSTALL_DIR/etc/profile.d/conda.sh"
    conda init bash

    # Clean up the installer
    echo_message "Cleaning up the Anaconda installer..."
    rm -f "$ANACONDA_INSTALLER"

    # Verify Anaconda installation
    if command -v conda &> /dev/null; then
        echo_message "Anaconda installation and configuration is complete."
    else
        echo_message "Anaconda installation failed. Please check the logs for details."
        exit 1
    fi
fi

# Initialize Conda for the current script (if not already done)
if ! command -v conda &> /dev/null; then
    source "$ANACONDA_INSTALL_DIR/etc/profile.d/conda.sh"
fi

# Create a Conda environment with required packages
echo_message "Creating the 'bugfinder' Conda environment with required packages..."
conda create -n bugfinder python=3.11 gitpython pyyaml flask opencv ffmpeg requests  conda-forge -y

# Activate the Conda environment
echo_message "Activating the 'bugfinder' environment..."
conda activate bugfinder

echo_message "All installations are complete."

exit 0

