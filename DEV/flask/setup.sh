#!/bin/bash
set -e

NGINX_VERSION="latest"
NGINX_INSTALL_DIR="/usr/local/nginx"
DEPLOY_DIR="/opt/apps/bugfinder"
PROJECT_DIR="/home/bug/lab/Bugfinder"
FLASK_APP="app.py"
USER=$(whoami)
DOMAIN_OR_IP="192.168.1.202"

# Generate a secure secret key
SECRET_KEY=$(openssl rand -hex 32)

# Ensure script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

echo "Updating system and installing dependencies..."
apt update
apt install -y build-essential libpcre3 libpcre3-dev libssl-dev zlib1g-dev \
  unzip git wget ffmpeg python3 python3-pip

echo "Installing Python packages..."
apt install -y python3-flask python3-flask-login python3-werkzeug

echo "Creating deployment directory at ${DEPLOY_DIR}..."
mkdir -p "${DEPLOY_DIR}"

echo "Downloading Nginx with RTMP module..."
cd /usr/src
wget "http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz"
tar -zxvf "nginx-${NGINX_VERSION}.tar.gz"
git clone https://github.com/arut/nginx-rtmp-module.git

echo "Compiling and installing Nginx with RTMP module..."
cd "nginx-${NGINX_VERSION}"
./configure --with-http_ssl_module --add-module=../nginx-rtmp-module
make
make install

echo "Creating necessary directories..."
mkdir -p /var/log/nginx
touch /var/log/nginx/error.log
chmod -R 755 /var/log/nginx

mkdir -p /tmp/hls
chmod -R 755 /tmp/hls

echo "Setting up Nginx configuration..."
cp "${PROJECT_DIR}/nginx.conf" "${NGINX_INSTALL_DIR}/conf/nginx.conf"
sed -i "s/your_domain_or_ip/${DOMAIN_OR_IP}/g" "${NGINX_INSTALL_DIR}/conf/nginx.conf"

echo "Copying application files to ${DEPLOY_DIR}..."

cp "${PROJECT_DIR}/start_streams.sh" "${DEPLOY_DIR}/"
chmod +x "${DEPLOY_DIR}/start_streams.sh"

cp "${PROJECT_DIR}/app.py" "${DEPLOY_DIR}/"
sed -i "s/your_secret_key/${SECRET_KEY}/g" "${DEPLOY_DIR}/app.py"

mkdir -p "${DEPLOY_DIR}/templates"
cp "${PROJECT_DIR}/templates/"*.html "${DEPLOY_DIR}/templates/"

mkdir -p "${DEPLOY_DIR}/static"
# Copy any static files if you have them
if [ -d "${PROJECT_DIR}/static" ]; then
  cp -r "${PROJECT_DIR}/static/"* "${DEPLOY_DIR}/static/"
fi

echo "Applying permissions..."
chown -R ${USER}:${USER} "${DEPLOY_DIR}"

echo "Copying test scripts..."

cp "${PROJECT_DIR}/test_webcams.sh" "${DEPLOY_DIR}/"
chmod +x "${DEPLOY_DIR}/test_webcams.sh"

cp "${PROJECT_DIR}/test_streaming.sh" "${DEPLOY_DIR}/"
chmod +x "${DEPLOY_DIR}/test_streaming.sh"

echo "Installing Certbot for SSL certificates..."
apt install -y certbot

echo "Stopping Nginx to obtain SSL certificates..."
${NGINX_INSTALL_DIR}/sbin/nginx -s stop || true

echo "Obtaining SSL certificates for domain ${DOMAIN_OR_IP}..."
certbot certonly --standalone -d ${DOMAIN_OR_IP} --non-interactive --agree-tos --email natebeckwith@proton.me

echo "Starting Nginx..."
${NGINX_INSTALL_DIR}/sbin/nginx

echo "Starting Flask application..."
cd "${DEPLOY_DIR}"
nohup python3 "${FLASK_APP}" > /var/log/flask_app.log 2>&1 &

echo "All set! Your pet cam application should now be running."
echo "Remember to update device paths, domain names, and secret keys in the configuration files."
