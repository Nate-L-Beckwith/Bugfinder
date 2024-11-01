# nginx_setup/utils.py
import os
import subprocess
import sys
import tarfile
from urllib.request import urlretrieve
from git import Repo, GitCommandError
from setuptools import Command

def run_command(command, cwd=None):
    """Run a shell command with error handling."""
    try:
        print(f"Running command: {command}")
        subprocess.run(command, shell=True, check=True, cwd=cwd)
    except subprocess.CalledProcessError as e:
        print(f"Command '{command}' failed with error: {e}")
        sys.exit(1)

def install_dependencies(dependencies):
    """Install necessary build dependencies."""
    print("Installing build dependencies...")
    run_command("sudo apt update")
    run_command("sudo apt upgrade -y")
    run_command(f"sudo apt install -y {' '.join(dependencies)}")


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
        except (GitCommandError, OSError) as e:
            print(f"Failed to clone repository {repo_url}: {e}")
            sys.exit(1)
    else:
        print(f"Repository already exists at {destination_dir}.")
        
def install_prerequisites():
    """Install prerequisites for the script."""
    print("Installing prerequisites...")
    run_command("sudo -E $HOME/Bugfinder/bugfinder_app/preres.sh")
    print("Prerequisites installed.")

def install_anacoda():
    """Install Anaconda."""
    print("Installing Anaconda...")
    run_command("sudo -E $HOME/Bugfinder/Nginix_Config/conda/install_conda.sh")
    print("Anaconda installed.")


