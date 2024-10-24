# nginx_setup/config_loader.py
import os
import sys
import yaml


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
    nginx_vars = [
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

    for var in nginx_vars:
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
