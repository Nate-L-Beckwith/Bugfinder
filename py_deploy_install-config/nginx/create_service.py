import os
import subprocess

from jinja2 import Template


# Read the service template from the Jinja2 file
with open("/home/bug/Bugfinder/py_deploy/conf_command.py.j2", "r") as file:
    service_template = file.read()

service_file_path = "/etc/systemd/system/my_service.service"

def create_service_file():
    """Create a systemd service file."""
    if os.path.exists(service_file_path):
        print(f"Service file {service_file_path} already exists!")
        return

    print(f"Creating service file at {service_file_path}")

    try:
        with open(service_file_path, "w") as service_file:
            service_file.write(service_template)
        print(f"Service file {service_file_path} created successfully.")
    except PermissionError as e:
        print(f"Permission denied: {e}")
        exit(1)


def enable_and_start_service():
    """Enable and start the systemd service."""
    print(f"Reloading systemd daemon to recognize new service: {service_name}")
    run_command("sudo systemctl daemon-reload")

    print(f"Enabling {service_name} service to start on boot")
    run_command(f"sudo systemctl enable {service_name}")

    print(f"Starting {service_name} service")
    run_command(f"sudo systemctl start {service_name}")

    print(f"Checking status of {service_name} service")
    run_command(f"sudo systemctl status {service_name}")


def run_command(command):
    """Run a shell command and print it, with error handling."""
    print(f"Running command: {command}")
    try:
        subprocess.run(command, shell=True, check=True)
    except subprocess.CalledProcessError as e:
        print(f"Command '{command}' failed with error: {e}")
        exit(1)


if __name__ == "__main__":
    create_service_file()
    enable_and_start_service()
