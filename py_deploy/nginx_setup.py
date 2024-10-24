import os
import subprocess
from dotenv import load_dotenv


def run_command(command):
    """Run a shell command and print it."""
    print(f"Running command: {command}")
    subprocess.run(command, shell=True, check=True)


def setup_nginx():
    # Load environment variables from file
    load_dotenv("nginx_vars.env")

    # Set up environment variables from the var file
    nginx_version = os.getenv("nginx_version")
    nginx_src_dir = os.getenv("nginx_src_dir")
    nginx_module_dir = os.getenv("nginx_module_dir")
    nginx_install_dir = os.getenv("nginx_install_dir")
    nginx_sbin_path = os.getenv("nginx_sbin_path")
    nginx_conf_path = os.getenv("nginx_conf_path")
    nginx_pid_path = os.getenv("nginx_pid_path")
    nginx_lock_path = os.getenv("nginx_lock_path")
    nginx_error_log_path = os.getenv("nginx_error_log_path")
    nginx_access_log_path = os.getenv("nginx_access_log_path")


    # Derived paths
    nginx_dir = os.path.join(nginx_src_dir, f"nginx-{nginx_version}")

    # Change to the source directory
    os.makedirs(nginx_src_dir, exist_ok=True)
    os.chdir(nginx_src_dir)

    # Download and extract Nginx
    run_command(f"sudo -E wget http://nginx.org/download/nginx-{nginx_version}.tar.gz")
    run_command(f"sudo -E tar -zxvf nginx-{nginx_version}.tar.gz")

    # Clone the nginx-rtmp-module repository
    os.makedirs(nginx_module_dir, exist_ok=True)
    run_command(
        f"git clone https://github.com/arut/nginx-rtmp-module.git {nginx_module_dir}/nginx-rtmp-module"
    )

    # Change to the Nginx directory
    os.chdir(nginx_dir)

    # Configure Nginx with the necessary modules
    configure_command = (
        f"sudo -E ./configure "
        f"--prefix={nginx_install_dir} "
        f"--sbin-path={nginx_sbin_path} "
        f"--conf-path={nginx_conf_path} "
        f"--pid-path={nginx_pid_path} "
        f"--lock-path={nginx_lock_path} "
        f"--error-log-path={nginx_error_log_path} "
        f"--http-log-path={nginx_access_log_path} "
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
    run_command(f"sudo -E {nginx_sbin_path} -vV")

    print("Done")


if __name__ == "__main__":
    setup_nginx()
