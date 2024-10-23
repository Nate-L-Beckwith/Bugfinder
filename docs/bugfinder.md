## nginx_rtmp_setup.sh

## Step 1: Install Dependencies

```bash
sudo apt-get update
sudo apt-get install -y build-essential libpcre3 libpcre3-dev libssl-dev ffmpeg git
```

## Step 2: Download Nginx and RTMP Module Sources

```bash
cd /etc/src
sudo wget http://nginx.org/download/nginx-1.24.0.tar.gz \
sudo tar -zxvf nginx-1.24.0.tar.gz \
sudo git clone https://github.com/arut/nginx-rtmp-module.git
```

## Step 3: Compile Nginx with RTMP Module

```bash
cd nginx-1.24.0 \
sudo ./configure --add-module=../nginx-rtmp-module --with-http_ssl_module \
sudo make \
sudo make install
```

## Step 4: Verify Installation

```bash
sudo /etc/nginx/ -V
```

## Ensure --add-module=../nginx-rtmp-module is present in the configuration arguments

## Configuring Nginx for RTMP, HLS Streaming, and HTTPS

### Step 1: Backup the Default Configuration

sudo mv /usr/local/nginx/conf/nginx.conf /etc/nginx/nginx.conf.backup

### Step 2: Create a New nginx.conf File

cat <<EOL | sudo tee /etc/nginx/nginx.conf
worker_processes auto;

events {
    worker_connections 1024;
}

rtmp {
    server {
        listen 1935;
        chunk_size 4096;

        application live {
            live on;
            record off;

            hls on;
            hls_path /var/tmp/hls;
            hls_fragment 3;
            hls_playlist_length 10;
            hls_nested on;
        }
    }
}

http {
    server {
        listen 80;
        server_name your_domain.com;
        return 301 https://\$host\$request_uri;
    }

    server {
        listen 443 ssl;
        server_name your_domain.com;

        ssl_certificate /etc/nginx/ssl/nginx.crt;
        ssl_certificate_key /etc/nginx/ssl/nginx.key;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers HIGH:!aNULL:!MD5;

        location / {
            root html;
            index index.html index.htm;
        }

        location /hls {
            types {
                application/vnd.apple.mpegurl m3u8;
                video/mp2t ts;
            }
            root /var/tmp;
            add_header Cache-Control no-cache;
        }

        # reverse proxy to access rtmp stream from https
        location /live {
            proxy_pass http://localhost:1935;
            proxy_buffering off;
        }
    }
}

pid /var/run/nginx.pid;
user nobody;
EOL

### Step 3: Create the HLS Directory and Set Permissions

sudo mkdir -p /var/tmp/hls
sudo chmod 777 /var/tmp/hls

### Step 4: Create SSL Directory and Generate Self-Signed Certificate

sudo mkdir -p /etc/nginx/ssl
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt -subj "/C=US/ST=State/L=City/O=Organization/OU=Department/CN=your_domain.com"

### Step 5: Start Nginx

sudo /usr/local/nginx/sbin/nginx

## Identifying Webcams

### Logitech Brio: /dev/video0

### Logitech C930e: /dev/video2

## Step 6: Stream from Webcams Using FFmpeg

### Start Streaming from Logitech Brio (/dev/video0) to the Nginx RTMP Server

ffmpeg -f v4l2 -i /dev/video0 -c:v libx264 -f flv rtmp://localhost/live/brio

### Start Streaming from Logitech C930e (/dev/video2) to the Nginx RTMP Server

ffmpeg -f v4l2 -i /dev/video2 -c:v libx264 -f flv rtmp://localhost/live/c930e

## Notes

# - /dev/video0 and /dev/video2 correspond to the webcams connected to the system

# - replace "localhost" with the appropriate server address if streaming to a remote server

# - the "live" application name matches the configuration in the nginx.conf file

## Step 7: Access the Stream

# - to view the stream, use a media player like VLC or a web player that supports HLS

# - for RTMP, use the URL: rtmp://<server-ip>/live/<stream-key> (e.g., rtmp://localhost/live/brio)

# - for HLS, use the URL: https://<server-ip>/hls/<stream-key>.m3u8 (e.g., https://your_domain.com/hls/brio.m3u8)

# - to access via HTTPS reverse proxy, use: https://<server-ip>/live/<stream-key>

## Step 8: Configure Recording and Screenshots

# to add recording functionality, modify nginx.conf

cat <<EOL | sudo tee -a /etc/nginx/nginx.conf
rtmp {
    server {
        listen 1935;
        chunk_size 4096;

        application live {
            live on;

            # enable recording
            record all;
            record_path /var/tmp/recordings;
            record_unique on;

            # screenshot configuration
            exec ffmpeg -i rtmp://localhost/live/\$name -vframes 1 -q:v 2 /var/tmp/screenshots/\$name.png;

            hls on;
            hls_path /var/tmp/hls;
            hls_fragment 3;
            hls_playlist_length 10;
            hls_nested on;
        }
    }
}
EOL

## Step 9: Create Directories for Recordings and Screenshots

sudo mkdir -p /var/tmp/recordings
sudo mkdir -p /var/tmp/screenshots
sudo chmod 777 /var/tmp/recordings
sudo chmod 777 /var/tmp/screenshots

## Step 10: Restart Nginx to Apply Changes

sudo /usr/local/nginx/sbin/nginx -s reload
