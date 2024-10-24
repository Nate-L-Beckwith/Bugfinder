import sys
import os
import subprocess
import tarfile
import yaml
from urllib.request import urlretrieve
from git import Repo


def load_config(config_path):
    """Load YAML configuration."""
    try:
        with open(config_path, "r", encoding="utf-8") as f:
            try:
                return yaml.safe_load(f)
            except yaml.YAMLError as yaml_error:
                print(f"Error parsing YAML file: {yaml_error}")
                sys.exit(1)
    except OSError as e:
        print(f"Error loading configuration: {e}")
        sys.exit(1)


def validate_config(config):
    """Validate the loaded configuration."""
    required_nginx_vars = [
        "version",
        "src_dir",
        "module_dir",
        "install_dir",
        "sbin_path",
        "conf_path",
        "pid_path",
        "lock_path",
        "error_log_path",
        "access_log_path",
    ]

    for var in required_nginx_vars:
        if var not in config.get("nginx", {}):
            print(f"Missing required nginx configuration: {var}")
            sys.exit(1)

    # Check additional configurations
    if "additional" not in config:
        print("Missing 'additional' configuration section.")
        sys.exit(1)

    if "rtmp_module_repo" not in config["additional"]:
        print("Missing 'rtmp_module_repo' in 'additional' configuration.")
        sys.exit(1)

    if "dependencies" not in config["additional"]:
        print("Missing 'dependencies' in 'additional' configuration.")
        sys.exit(1)


def run_command(command, cwd=None):
    """Run a shell command with error handling."""
    try:
        print(f"Running command: {' '.join(command)}")
        subprocess.run(command, check=True, cwd=cwd)
    except subprocess.CalledProcessError as e:
        print(f"Command '{' '.join(command)}' failed with error: {e}")
        sys.exit(1)


def install_dependencies(dependencies):
    """Install necessary build dependencies."""
    print("Installing build dependencies...")
    run_command(["sudo", "apt", "update"])
    run_command(["sudo", "apt", "install", "-y"] + dependencies)


def download_file(url, destination):
    """Download a file from a URL to a destination."""
    try:
        print(f"Downloading {url} to {destination}...")
        urlretrieve(url, destination)
        print("Download completed.")
    except Exception as e:
        print(f"Failed to download {url}: {e}")
        sys.exit(1)


def extract_tarball(tarball_path, extract_to):
    """Extract a tar.gz file."""
    try:
        print(f"Extracting {tarball_path} to {extract_to}...")
        with tarfile.open(tarball_path, "r:gz") as tar:
            tar.extractall(path=extract_to)
        print("Extraction completed.")
    except Exception as e:
        print(f"Failed to extract {tarball_path}: {e}")
        sys.exit(1)


def clone_repository(repo_url, destination_dir):
    """Clone a git repository."""
    if not os.path.exists(destination_dir):
        try:
            print(f"Cloning repository {repo_url} into {destination_dir}...")
            Repo.clone_from(repo_url, destination_dir)
            print("Repository cloned successfully.")
        except Exception as e:
            print(f"Failed to clone repository {repo_url}: {e}")
            sys.exit(1)
    else:
        print(f"Repository already exists at {destination_dir}.")


def setup_nginx():
    """Setup and install Nginx with the specified configuration."""
    # Define paths
    script_dir = os.path.dirname(os.path.abspath(__file__))
    config_path = os.path.join(script_dir, "..", "config", "nginx_vars.yaml")

    # Load configuration
    config = load_config(config_path)

    # Validate configuration
    validate_config(config)

    nginx_config = config.get("nginx", {})
    additional_config = config.get("additional", {})

    # Extract Nginx variables
    version = nginx_config.get("version")
    src_dir = nginx_config.get("src_dir")
    module_dir = nginx_config.get("module_dir")
    install_dir = nginx_config.get("install_dir")
    sbin_path = nginx_config.get("sbin_path")
    conf_path = nginx_config.get("conf_path")
    pid_path = nginx_config.get("pid_path")
    lock_path = nginx_config.get("lock_path")
    error_log_path = nginx_config.get("error_log_path")
    access_log_path = nginx_config.get("access_log_path")

    # Additional variables
    rtmp_repo = additional_config.get("rtmp_module_repo")
    dependencies = additional_config.get("dependencies", [])

    # Derived paths
    nginx_dir = os.path.join(src_dir, f"nginx-{version}")
    nginx_tarball = os.path.join(src_dir, f"nginx-{version}.tar.gz")

    # Ensure source directory exists
    os.makedirs(src_dir, exist_ok=True)

    # Step 1: Install dependencies
    install_dependencies(dependencies)

    # Step 2: Download Nginx
    download_url = f"http://nginx.org/download/nginx-{version}.tar.gz"
    download_file(download_url, nginx_tarball)

    # Step 3: Extract Nginx
    extract_tarball(nginx_tarball, src_dir)

    # Step 4: Clone RTMP module
    clone_repository(rtmp_repo, os.path.join(module_dir, "nginx-rtmp-module"))

    # Step 5: Configure Nginx
    configure_command = [
        "sudo",
        "-E",
        "./configure",
        f"--prefix={install_dir}",
        f"--sbin-path={sbin_path}",
        f"--conf-path={conf_path}",
        f"--pid-path={pid_path}",
        f"--lock-path={lock_path}",
        f"--error-log-path={error_log_path}",
        f"--http-log-path={access_log_path}",
        "--with-http_ssl_module",
        "--with-http_v2_module",
        "--with-http_realip_module",
        "--with-http_stub_status_module",
        "--with-http_sub_module",
        "--with-http_flv_module",
        "--with-http_mp4_module",
        "--with-pcre",
        "--with-pcre-jit",
        "--with-threads",
        "--with-stream",
        "--with-stream_ssl_module",
        f"--add-module={os.path.join(module_dir, 'nginx-rtmp-module')}",
    ]
    run_command(configure_command, cwd=nginx_dir)

    # Step 6: Build Nginx
    run_command(["sudo", "-E", "make"], cwd=nginx_dir)

    # Step 7: Install Nginx
    run_command(["sudo", "-E", "make", "install"], cwd=nginx_dir)

    # Step 8: Verify Installation
    run_command([sbin_path, "-vV"])

    print("Nginx setup and installation completed successfully.")


if __name__ == "__main__":
    setup_nginx()
