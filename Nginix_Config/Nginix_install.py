# nginx_setup/nginx_installer.py
import os
import subprocess

import test
from utils import (
    run_command,
    install_dependencies,
    download_file,
    extract_tarball,
    clone_repository,
)


def setup_nginx(config):
    """Setup and install Nginx with the specified configuration."""
    nginx_config = config.get("nginx", {})
    additional_config = config.get("additional", {})
    nginx_service_files_dir = nginx_config.get("nginx_service_files_dir", {})
    # Derived paths
    nginx_dir = os.path.join(
        nginx_config["src_dir"], f"nginx-{nginx_config['version']}"
    )
    nginx_tarball = os.path.join(
        nginx_config["src_dir"], f"nginx-{nginx_config['version']}.tar.gz"
    )

    # Ensure source directory exists
    os.makedirs(nginx_config["src_dir"], exist_ok=True)

    # Install dependencies
    install_dependencies(additional_config["dependencies"])

    # Download Nginx from src
    download_url = f"http://nginx.org/download/nginx-{nginx_config['version']}.tar.gz"
    download_file(download_url, nginx_tarball)

    # Step 3: Extract Nginx
    extract_tarball(nginx_tarball, nginx_config["src_dir"])

    # clone RTMP module
    clone_repository(
        additional_config["rtmp_module_repo"],
        os.path.join(nginx_config["module_dir"], "nginx-rtmp-module"),
    )

    # Configure Nginx Build command
    configure_command = (
        f"sudo -E ./configure "
        f"--prefix={nginx_config['install_dir']} "
        f"--sbin-path={nginx_config['sbin_path']} "
        f"--conf-path={nginx_config['conf_path']} "
        f"--pid-path={nginx_config['pid_path']} "
        f"--lock-path={nginx_config['lock_path']} "
        f"--error-log-path={nginx_config['error_log_path']} "
        f"--http-log-path={nginx_config['access_log_path']} "
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
        f"--add-module={os.path.join(nginx_config['module_dir'], 'nginx-rtmp-module')}"
    )
    run_command(configure_command, cwd=nginx_dir)

    # Build Nginx
    run_command("sudo -E make", cwd=nginx_dir)
    run_command("sudo -E make install", cwd=nginx_dir)
    run_command(f"{nginx_config['sbin_path']} -vV")
    
    def test_nginx():
        try:
            run_command(f"{nginx_config['sbin_path']} -t")
        except Exception as e:
            print(e)
            print("Nginx test failed. Retrying...")
            test_nginx()

    run_command(f"{nginx_config['sbin_path']} -t")
    
    # run_command(f"sudo cp -av {nginx_service_files_dir}/* /etc/systemd/system/")
    # run_command("sudo systemctl daemon-reload")
    # # Enable and start Nginx RTMP service
    # run_command("sudo systemctl enable nginx-rtmp")
    # run_command("sudo systemctl start nginx-rtmp && sudo systemctl status nginx-rtmp")

    print("Nginx setup and installation completed successfully.")
