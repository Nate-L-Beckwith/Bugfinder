import os
import tarfile
import subprocess
from urllib.request import urlretrieve
from dotenv import load_dotenv
from git import Repo


def run_command(command):
    """Run a shell command and print it."""
    print(f"Running command: {command}")
    subprocess.run(command, shell=True, check=True)


def download_file(url, destination):
    """Download a file from a given URL to a local destination."""
    print(f"Downloading {url} to {destination}")
    urlretrieve(url, destination)


def extract_tarball(tarball_path, extract_to):
    """Extract a tar.gz file to a specific directory."""
    print(f"Extracting {tarball_path} to {extract_to}")
    with tarfile.open(tarball_path, "r:gz") as tar:
        tar.extractall(path=extract_to)


def clone_repository(repo_url, destination_dir):
    """Clone a git repository to a specified directory using GitPython."""
    if not os.path.exists(destination_dir):
        print(f"Cloning repository {repo_url} into {destination_dir}")
        Repo.clone_from(repo_url, destination_dir)
    else:
        print(f"Repository already exists at {destination_dir}")


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
    nginx_tarball = os.path.join(nginx_src_dir, f"nginx-{nginx_version}.tar.gz")

    # Ensure the source directory exists
    os.makedirs(nginx_src_dir, exist_ok=True)

    download_url = f"http://nginx.org/download/nginx-{nginx_version}.tar.gz"
    download_file(download_url, nginx_tarball)
    extract_tarball(nginx_tarball, nginx_src_dir)

    # Clone the nginx-rtmp-module repository using GitPython
    os.makedirs(nginx_module_dir, exist_ok=True)
    clone_repository(
        "https://github.com/arut/nginx-rtmp-module.git",
        os.path.join(nginx_module_dir, "nginx-rtmp-module"),
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
        f"--add-module={os.path.join(nginx_module_dir, 'nginx-rtmp-module')}"
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
