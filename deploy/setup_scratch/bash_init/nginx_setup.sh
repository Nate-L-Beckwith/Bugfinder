import os
import subprocess

def run_command(command):
    """Run a shell command and print it."""
    print(f"Running command: {command}")
    subprocess.run(command, shell=True, check=True)

def setup_nginx():
    # Set up environment variables
    nginx_version = os.environ.get('NGINX_VERSION', '1.21.3')
    nginx_src_dir = os.environ.get('NGINX_SRC_DIR', '/usr/local/src')
    nginx_module_dir = os.environ.get('NGINX_MODULE_DIR', '/usr/local/src/nginx-modules')
    nginx_dir = os.path.join(nginx_src_dir, f'nginx-{nginx_version}')

    # Change to the source directory
    os.makedirs(nginx_src_dir, exist_ok=True)
    os.chdir(nginx_src_dir)

    # Download and extract Nginx
    run_command(f"sudo -E wget http://nginx.org/download/nginx-{nginx_version}.tar.gz")
    run_command(f"sudo -E tar -zxvf nginx-{nginx_version}.tar.gz")

    # Clone the nginx-rtmp-module repository
    os.makedirs(nginx_module_dir, exist_ok=True)
    run_command(f"git clone https://github.com/arut/nginx-rtmp-module.git {nginx_module_dir}/nginx-rtmp-module")

    # Change to the Nginx directory
    os.chdir(nginx_dir)

    # Configure Nginx with the necessary modules
    configure_command = (
        "sudo -E ./configure "
        "--prefix=/usr/local/nginx "
        "--sbin-path=/usr/sbin/nginx "
        "--conf-path=/etc/nginx/nginx.conf "
        "--pid-path=/var/run/nginx.pid "
        "--lock-path=/var/lock/nginx.lock "
        "--error-log-path=/var/log/nginx/error.log "
        "--http-log-path=/var/log/nginx/access.log "
        "--with-http_ssl_module "
        "--with-http_v2_module "
        "--with-http_realip_module "
        "--with-http_stub_status_module "
        "--with-http_sub_module "
        "--with-http_flv_module "
        "--with-http_mp4_module "
        "--with-pcre "
        "--with-pcre-jit "
        "--with-threads "
        "--with-stream "
        "--with-stream_ssl_module "
        f"--add-module={nginx_module_dir}/nginx-rtmp-module"
    )
    run_command(configure_command)

    # Build and install Nginx
    run_command("sudo -E make")
    run_command("sudo -E make install")

    # Verify the installation
    run_command("sudo -E nginx -vV")

    print("Done")

if __name__ == "__main__":
    setup_nginx()