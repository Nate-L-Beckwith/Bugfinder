Here’s an updated README with details for the additional files:

---

# bugfinder

**Bugfinder** is a modular streaming application that supports live video feeds using Nginx with RTMP and HLS configurations, built for use in an Nginx environment with service management and device configurations.

---

### Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)
  - [1. Preliminary Setup](#1-preliminary-setup)
  - [2. Install Anaconda](#2-install-anaconda)
  - [3. Install Nginx with RTMP Module](#3-install-nginx-with-rtmp-module)
  - [4. Configure Nginx](#4-configure-nginx)
- [Usage](#usage)
- [Files and Structure](#files-and-structure)

---

### Requirements

- **System packages**: See `preres.sh` for the installation of system dependencies.
- **Conda packages**: Installed by `install_conda.sh`, including `gitpython`, `pyyaml`, `flask`, `opencv`, and `requests`.
- **FFmpeg**: Used for video streaming, installed as part of system requirements.
- **Streaming Devices**: Details on configured devices are in `used_devices.txt`.

---

### Installation

#### 1. Preliminary Setup

Run `preres.sh` to install system dependencies and prepare the environment.

```bash
bash preres.sh
```

#### 2. Install Anaconda

Run `install_conda.sh` to set up the `bugfinder` environment with necessary Python packages.

```bash
bash install_conda.sh
```

#### 3. Install Nginx with RTMP Module

Install and configure Nginx with RTMP support using `Nginx_install.py`.

```bash
python3 Nginx_install.py
```

#### 4. Configure Nginx

Configuration files for Nginx, including `nginx.conf` and `nginx_vars.yml`, set up paths and RTMP module options. Use `nginx-rtmp.service` to manage Nginx as a systemd service:

```bash
sudo systemctl enable nginx-rtmp.service
sudo systemctl start nginx-rtmp.service
```

---

### Usage

- **Web Interface**: Access live streams via the `index.html` page.
- **Service Management**: Use `streams.service` and `nginx-rtmp.service` to manage streams and Nginx server.
- **Streaming**: Start streaming manually with `start_streams.sh` or through `ffmpeg-cmd.sh` for single-camera configurations.

---

### Files and Structure

| File               | Description                                                                 |
|--------------------|-----------------------------------------------------------------------------|
| `conf_loader.py`   | Loads configuration settings for the application.                          |
| `main.py`          | Entry point of the application, handling primary logic.                    |
| `Nginx_install.py` | Installs and configures Nginx with RTMP support.                           |
| `nginx_vars.yml`   | Configurable paths and Nginx settings.                                      |
| `install_conda.sh` | Installs Anaconda and sets up the `bugfinder` Conda environment.           |
| `preres.sh`        | Installs system dependencies.                                              |
| `index.html`       | Front-end page for live streaming, utilizing HLS.                          |
| `50x.html`         | Error page displayed during server issues.                                 |
| `nginx.conf`       | Nginx configuration file.                                                  |
| `nginx-rtmp.service` | Systemd service file for managing Nginx with RTMP support.               |
| `streams.service`  | Manages streaming services using systemd.                                  |
| `used_devices.txt` | Details on streaming devices and their configurations.                     |
| `ffmpeg-cmd.sh`    | FFmpeg command for single-camera streaming.                                |
| `start_streams.sh` | Starts multiple camera streams using FFmpeg commands.                      |

---

### Notes

- IP addresses in `index.html` should be updated to match your network.
- Streaming devices and configurations, including input sources and camera parameters, are listed in `used_devices.txt`.
