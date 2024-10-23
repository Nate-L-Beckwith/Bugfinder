#!/bin/bash
exec_static preres.sh
exec_static vars.sh

cd $NGINX_SRC_DIR

sudo wget http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz
sudo tar -zxvf nginx-$NGINX_VERSION.tar.gz
sudo git clone https://github.com/arut/nginx-rtmp-module.git $NGINX_MODULE_DIR

cd $NGINX_DIR

sudo ./configure \
    --prefix=/usr/local/nginx \
    --sbin-path=/usr/sbin/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/lock/nginx.lock \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-http_realip_module \
    --with-http_stub_status_module \
    --with-http_sub_module \
    --with-http_flv_module \
    --with-http_mp4_module \
    --with-pcre \
    --with-pcre-jit \
    --with-threads \
    --with-stream \
    --with-stream_ssl_module \
    --add-module=../nginx-rtmp-module

sudo make
sudo make install

sudo nginx -v

echo "Done"