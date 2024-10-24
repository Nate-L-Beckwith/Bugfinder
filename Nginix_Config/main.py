# main.py
import os
from Nginix_Config.conf_loader import load_config, validate_config
from Nginix_Config.Nginix_install import setup_nginx

if __name__ == "__main__":
    # Define paths
    script_dir = os.path.dirname(os.path.abspath(__file__))
    config_path = os.path.join(script_dir, "config", "nginx_vars.yaml")

    # Load configuration
    config = load_config(config_path)

    # Validate configuration
    validate_config(config)

    # Setup Nginx
    setup_nginx(config)
