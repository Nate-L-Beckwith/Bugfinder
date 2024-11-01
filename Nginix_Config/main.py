# main.py
import os
from bugfinder_web import configure_sites
from utils import install_prerequisites, install_anaconda
# , start_rtmp

from conf_loader import load_config, validate_config
from Nginix_install import setup_nginx

if __name__ == "__main__":
    # Define paths
    script_dir = os.path.dirname(os.path.abspath(__file__))
    config_path = os.path.join(script_dir, "nginx_vars.yml")
    
    install_prerequisites()

    # Load configuration
    config = load_config(config_path)

    # Validate configuration
    # validate_config(config)

    
    install_anaconda()
    # Setup Nginx
    setup_nginx(config)
    
    # configure_sites(config)

    # start_rtmp(config)
