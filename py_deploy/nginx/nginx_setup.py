import os
import tarfile
import subprocess
from urllib.request import urlretrieve
from dotenv import load_dotenv
from git import Repo


def run_command(command):
    """Run a shell command and print it, with error handling."""
    print(f"Running command: {command}")
    try:
        subprocess.run(command, shell=True, check=True)
    except subprocess.CalledProcessError as e:
        print(f"Command '{command}' failed with error: {e}")
        exit(1)


def install_dependencies():
    """Ensure necessary dependencies for building Nginx are installed."""
    print("Checking and installing required build dependencies...")
    dependencies = [
        "make",
        "gcc",
        "g++",
        "libpcre3-dev",
        "zlib1g-dev",
        "libssl-dev",
        "git",
    ]
    run_command(f"sudo apt update && sudo apt install -y {' '.join(dependencies)}")


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


def fetch_nginx_config():
    """Load Nginx configuration from environment variables and validate them."""
    load_dotenv("/home//bug/Bugfinder/py_deploy/nginx_vars.env")

    # Retrieve required environment variables with validation
    required_vars = [
        "nginx_version",
        "nginx_src_dir",
        "nginx_module_dir",
        "nginx_install_dir",
        "nginx_sbin_path",
        "nginx_conf_path",
        "nginx_pid_path",
        "nginx_lock_path",
        "nginx_error_log_path",
        "nginx_access_log_path",
    ]

    config = {}
    for var in required_vars:
        value = os.getenv(var)
        if value is None:
            raise ValueError(
                f"Environment variable '{var}' is not set. Please check your nginx_vars.env file."
            )
        config[var] = value

    return config


def setup_nginx():
    # Load the Nginx configuration
    config = fetch_nginx_config()

    # Derived paths
    nginx_dir = os.path.join(
        config["nginx_src_dir"], f"nginx-{config['nginx_version']}"
    )
    nginx_tarball = os.path.join(
        config["nginx_src_dir"], f"nginx-{config['nginx_version']}.tar.gz"
    )

    # Ensure the source directory exists
    os.makedirs(config["nginx_src_dir"], exist_ok=True)

    # Step 1: Install dependencies (make, gcc, pcre, ssl, etc.)
    install_dependencies()

    # Step 2: Download and extract Nginx
    download_url = f"http://nginx.org/download/nginx-{config['nginx_version']}.tar.gz"
    download_file(download_url, nginx_tarball)
    extract_tarball(nginx_tarball, config["nginx_src_dir"])

    # Step 3: Clone the nginx-rtmp-module repository using GitPython
    os.makedirs(config["nginx_module_dir"], exist_ok=True)
    clone_repository(
        "https://github.com/arut/nginx-rtmp-module.git",
        os.path.join(config["nginx_module_dir"], "nginx-rtmp-module"),
    )

    # Step 4: Change to the Nginx directory
    os.chdir(nginx_dir)

    # Step 5: Configure Nginx with the necessary modules
    configure_command = (
        f"sudo -E ./configure "
        f"--prefix={config['nginx_install_dir']} "
        f"--sbin-path={config['nginx_sbin_path']} "
        f"--conf-path={config['nginx_conf_path']} "
        f"--pid-path={config['nginx_pid_path']} "
        f"--lock-path={config['nginx_lock_path']} "
        f"--error-log-path={config['nginx_error_log_path']} "
        f"--http-log-path={config['nginx_access_log_path']} "
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
        f"--add-module={os.path.join(config['nginx_module_dir'], 'nginx-rtmp-module')}"
    )
    run_command(configure_command)

    # Step 6: Build and install Nginx
    run_command("sudo -E make")
    run_command("sudo -E make install")

    # Step 7: Verify the installation
    run_command(f"sudo -E {config['nginx_sbin_path']} -vV")

    print("Nginx setup and installation completed successfully.")


if __name__ == "__main__":
    setup_nginx()
