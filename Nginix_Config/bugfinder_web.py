from logging import config
import os
from turtle import home
from utils import *
from conf_loader import load_config



config = load_config(config)

def configure_sites(config):
    """Configure Nginx sites."""
    nginx_config = config.get("nginx", {})
    sites = nginx_config.get(f"{{install_dir}}/html")
    for site in sites:
        site_config = sites[site]
        site_dir = os.path.join(nginx_config["install_dir"], "html", site)
        os.makedirs(site_dir, exist_ok=True)
        with open(os.path.join(site_dir, "index.html"), "w") as f:
            f.write(site_config["content"])
        with open(os.path.join(nginx_config["nginx_service_files_dir"], f"{site}.conf"), "w") as f:
            f.write(
                f"server {{\n"
                f"    listen 80;\n"
                f"    server_name {site};\n"
                f"    location / {{\n"
                f"        root {site_dir};\n"
                f"    }}\n"
                f"}}\n"
            )
