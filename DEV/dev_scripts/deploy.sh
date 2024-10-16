#!/bin/bash

# cli/deploy.sh

# Exit immediately if a command exits with a non-zero status
set -e

# Variables
BACKUP_DIR="/home/bug/lab/VM_net/Bugnest/backups/$(date +%F_%T)"
PROJECT_DIR="/home/bug/lab/VM_net/Bugnest/bugfinder"  # Adjust if different

# Function to create backup
backup_file() {
    local src="$1"
    local dest="$2"

    if [ -f "$src" ] || [ -d "$src" ]; then
        mkdir -p "$(dirname "$dest")"
        cp -a "$src" "$dest"
        echo "Backed up $src to $dest"
    else
        echo "No existing $src to back up."
    fi
}

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "Please run this script with sudo or as root."
    exit 1
fi

echo "Starting deployment..."

# Create backup directory
echo "Creating backup directory at $BACKUP_DIR..."
mkdir -p "$BACKUP_DIR"

# 1. Update Package Lists
echo "Updating package lists..."
apt update

# 2. Install Nginx and RTMP Module
echo "Installing Nginx and the RTMP module..."
apt install -y nginx libnginx-mod-rtmp

# 3. Backup and Deploy Nginx main configuration
echo "Backing up and deploying Nginx main configuration..."
backup_file "/etc/nginx/nginx.conf" "$BACKUP_DIR/etc/nginx/nginx.conf.bak"
cp "$PROJECT_DIR/etc/nginx/nginx.conf" "/etc/nginx/nginx.conf"

# 4. Backup and Deploy Nginx Site Configuration
echo "Backing up and deploying Nginx site configuration..."
backup_file "/etc/nginx/sites-available/bugfinder.conf" "$BACKUP_DIR/etc/nginx/sites-available/bugfinder.conf.bak"
backup_file "/etc/nginx/sites-enabled/bugfinder.conf" "$BACKUP_DIR/etc/nginx/sites-enabled/bugfinder.conf.bak"
cp "$PROJECT_DIR/etc/nginx/sites-available/bugfinder.conf" "/etc/nginx/sites-available/bugfinder.conf"
ln -sf /etc/nginx/sites-available/bugfinder.conf /etc/nginx/sites-enabled/bugfinder.conf

# 5. Backup and Deploy SSL Certificates and Keys
echo "Backing up and deploying SSL certificates and keys..."
backup_file "/etc/ssl/certs/bugnest.crt" "$BACKUP_DIR/etc/ssl/certs/bugnest.crt.bak"
backup_file "/etc/ssl/private/bugnest.key" "$BACKUP_DIR/etc/ssl/private/bugnest.key.bak"
cp "$PROJECT_DIR/etc/ssl/certs/bugnest.crt" "/etc/ssl/certs/bugnest.crt"
cp "$PROJECT_DIR/etc/ssl/private/bugnest.key" "/etc/ssl/private/bugnest.key"
chmod 600 /etc/ssl/private/bugnest.key
chown root:root /etc/ssl/private/bugnest.key

# 6. Backup and Deploy Streaming Scripts
echo "Backing up and deploying FFmpeg streaming scripts..."
backup_file "/usr/local/bin/stream_cam0.sh" "$BACKUP_DIR/usr/local/bin/stream_cam0.sh.bak"
backup_file "/usr/local/bin/stream_cam1.sh" "$BACKUP_DIR/usr/local/bin/stream_cam1.sh.bak"
cp "$PROJECT_DIR/ffmpeg-scripts/stream_cam0.sh" "/usr/local/bin/stream_cam0.sh"
cp "$PROJECT_DIR/ffmpeg-scripts/stream_cam1.sh" "/usr/local/bin/stream_cam1.sh"
chmod +x /usr/local/bin/stream_cam0.sh
chmod +x /usr/local/bin/stream_cam1.sh
chown www-data:www-data /usr/local/bin/stream_cam0.sh
chown www-data:www-data /usr/local/bin/stream_cam1.sh

# 7. Backup and Deploy Systemd Service Files
echo "Backing up and deploying systemd service files..."
backup_file "/etc/systemd/system/stream_cam0.service" "$BACKUP_DIR/etc/systemd/system/stream_cam0.service.bak"
backup_file "/etc/systemd/system/stream_cam1.service" "$BACKUP_DIR/etc/systemd/system/stream_cam1.service.bak"
cp "$PROJECT_DIR/etc/systemd/system/stream_cam0.service" "/etc/systemd/system/stream_cam0.service"
cp "$PROJECT_DIR/etc/systemd/system/stream_cam1.service" "/etc/systemd/system/stream_cam1.service"

# 8. Create and Set Permissions for Log Files
echo "Setting up log files for streaming..."
if [ ! -f /var/log/stream_cam0.log ]; then
    touch /var/log/stream_cam0.log
    chown www-data:www-data /var/log/stream_cam0.log
    chmod 644 /var/log/stream_cam0.log
    echo "[$(date)] Log file created." > /var/log/stream_cam0.log
fi

if [ ! -f /var/log/stream_cam1.log ]; then
    touch /var/log/stream_cam1.log
    chown www-data:www-data /var/log/stream_cam1.log
    chmod 644 /var/log/stream_cam1.log
    echo "[$(date)] Log file created." > /var/log/stream_cam1.log
fi

# 9. Reload systemd Daemon and Enable Services
echo "Reloading systemd daemon and enabling streaming services..."
systemctl daemon-reload
systemctl enable stream_cam0.service
systemctl enable stream_cam1.service
systemctl restart stream_cam0.service
systemctl restart stream_cam1.service

# 10. Add www-data to video Group
echo "Adding www-data to video group..."
usermod -aG video www-data

# 11. Create HLS Directory and Set Permissions
echo "Setting up HLS directory..."
mkdir -p /tmp/hls
chown www-data:www-data /tmp/hls
chmod 755 /tmp/hls

# 12. Restart Nginx to Apply Changes
echo "Restarting Nginx..."
systemctl restart nginx

echo "Deployment completed successfully."
echo "Backup of existing configurations is stored at $BACKUP_DIR"
