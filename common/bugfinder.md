
# **Table of Contents**

1. [Prerequisites](#1-prerequisites)
2. [Installing Anaconda and Creating a Conda Environment](#2-installing-anaconda-and-creating-a-conda-environment)
3. [Installing Nginx with RTMP Module](#3-installing-nginx-with-rtmp-module)
4. [Configuring Nginx for RTMP and HLS Streaming](#4-configuring-nginx-for-rtmp-and-hls-streaming)
5. [Streaming from Webcams Using FFmpeg](#5-streaming-from-webcams-using-ffmpeg)
6. [Creating a Flask Web Application](#6-creating-a-flask-web-application)
7. [Testing and Running the Application](#7-testing-and-running-the-application)
8. [Automating the Setup](#8-automating-the-setup)
9. [Conclusion](#9-conclusion)
10. [Additional Resources](#10-additional-resources)

---

## **1. Prerequisites**

- **Operating System**: Ubuntu/Debian-based Linux distribution
- **Hardware**: Logitech BRIO and Logitech Webcam C930e
- **User Permissions**: Administrative (sudo) privileges

---

## **2. Installing Anaconda and Creating a Conda Environment**

Anaconda is a distribution of Python and R for scientific computing, which simplifies package management and deployment.

### **Step 1: Download Anaconda Installer**

Navigate to the [Anaconda Distribution](https://www.anaconda.com/products/distribution) website and copy the link for the latest Linux installer.

Alternatively, use the following command to download the latest Anaconda installer (as of October 2023):

```bash
wget https://repo.anaconda.com/archive/Anaconda3-2023.09-Linux-x86_64.sh
```

### **Step 2: Verify the Installer (Optional but Recommended)**

Verify the integrity of the installer using `sha256sum`.

```bash
sha256sum Anaconda3-2023.09-Linux-x86_64.sh
```

Compare the output hash with the one provided on the Anaconda website.

### **Step 3: Run the Installer**

```bash
bash Anaconda3-2023.09-Linux-x86_64.sh
```

- **Follow the prompts**:
  - Press **Enter** to review the license agreement.
  - Type **`yes`** to accept the license terms.
  - Press **Enter** to confirm the installation location (default is `~/anaconda3`).
  - Type **`yes`** to initialize Anaconda3 by running `conda init`.

### **Step 4: Activate Anaconda**

Close and reopen your terminal or source your `.bashrc` file:

```bash
source ~/.bashrc
```

### **Step 5: Create a Conda Environment**

Create a new environment called `bf-conda` with Python 3.9 (or your preferred version):

```bash
conda create -n bf-conda python=3.9
```

### **Step 6: Activate the Conda Environment**

```bash
conda activate bf-conda
```

Your prompt should now indicate that you're in the `bf-conda` environment.

### **Step 7: Install Required Python Packages**

Install Flask and any other necessary Python packages within the environment:

```bash
conda install flask
```

Alternatively, you can install packages using `pip`:

```bash
pip install flask
```

---

## **3. Installing Nginx with RTMP Module**

Since Nginx is not Python-based, we'll install it system-wide.

### **Step 1: Install Dependencies**

```bash
sudo apt-get update
sudo apt-get install -y build-essential libpcre3 libpcre3-dev libssl-dev ffmpeg git
```

### **Step 2: Download Nginx and RTMP Module Sources**

```bash
cd /usr/local/src
sudo wget http://nginx.org/download/nginx-1.24.0.tar.gz
sudo tar -zxvf nginx-1.24.0.tar.gz
sudo git clone https://github.com/arut/nginx-rtmp-module.git
```

### **Step 3: Compile Nginx with RTMP Module**

```bash
cd nginx-1.24.0
sudo ./configure --add-module=../nginx-rtmp-module --with-http_ssl_module
sudo make
sudo make install
```

Nginx is installed to `/usr/local/nginx`.

### **Step 4: Verify Nginx Installation**

```bash
/usr/local/nginx/sbin/nginx -V
```

Ensure you see `--add-module=../nginx-rtmp-module` in the configuration arguments.

---

## **4. Configuring Nginx for RTMP and HLS Streaming**

### **Step 1: Backup Default Configuration**

```bash
sudo mv /usr/local/nginx/conf/nginx.conf /usr/local/nginx/conf/nginx.conf.backup
```

### **Step 2: Create New Nginx Configuration**

```bash
sudo nano /usr/local/nginx/conf/nginx.conf
```

**Add the following content:**

```nginx
worker_processes  auto;
events {
    worker_connections  1024;
}

rtmp {
    server {
        listen 1935;
        chunk_size 4096;

        application live {
            live on;
            record off;

            hls on;
            hls_path /tmp/hls;
            hls_fragment 3;
            hls_playlist_length 10;
            hls_nested on;
        }
    }
}

http {
    server {
        listen 80;

        location / {
            root   html;
            index  index.html index.htm;
        }

        location /hls {
            types {
                application/vnd.apple.mpegurl m3u8;
                video/mp2t ts;
            }
            root /tmp;
            add_header Cache-Control no-cache;
        }
    }
}
```

### **Step 3: Create HLS Directory**

```bash
sudo mkdir -p /tmp/hls
sudo chmod 777 /tmp/hls
```

### **Step 4: Start Nginx**

```bash
sudo /usr/local/nginx/sbin/nginx
```

If Nginx is already running, reload the configuration:

```bash
sudo /usr/local/nginx/sbin/nginx -s reload
```

---

## **5. Streaming from Webcams Using FFmpeg**

We'll use FFmpeg to capture video from your webcams and stream them to the Nginx RTMP server.

### **Identify Your Webcams**

Based on your device information:

- **Logitech BRIO**: `/dev/video0`
- **Logitech C930e**: `/dev/video4`

### **Step 1: Stream from Logitech BRIO**

In a new terminal, run:

```bash
ffmpeg -f v4l2 -i /dev/video0 -vcodec libx264 -preset ultrafast -tune zerolatency -f flv rtmp://localhost/live/camera1
```

### **Step 2: Stream from Logitech C930e**

In another terminal, run:

```bash
ffmpeg -f v4l2 -i /dev/video4 -vcodec libx264 -preset ultrafast -tune zerolatency -f flv rtmp://localhost/live/camera2
```

**Explanation of FFmpeg Options:**

- `-f v4l2`: Input format for Video4Linux2 devices.
- `-i /dev/videoX`: Input device.
- `-vcodec libx264`: Use H.264 codec.
- `-preset ultrafast`: Use the fastest encoding preset.
- `-tune zerolatency`: Optimize for low latency.
- `-f flv`: Output format for RTMP streaming.
- `rtmp://localhost/live/cameraX`: RTMP server URL.

---

## **6. Creating a Flask Web Application**

We'll create a Flask app within your `bf-conda` environment.

### **Step 1: Set Up Project Directory**

```bash
mkdir ~/webcam_app
cd ~/webcam_app
mkdir templates static
```

### **Step 2: Create the Flask Application**

**File: `app.py`**

```python
from flask import Flask, render_template
app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

### **Step 3: Create the HTML Template**

**File: `templates/index.html`**

```html
<!DOCTYPE html>
<html>
<head>
    <title>Webcam Pet App</title>
</head>
<body>
    <h1>Webcam Pet App</h1>
    <h2>Camera 1 - Logitech BRIO</h2>
    <video width="640" height="480" controls autoplay>
        <source src="http://localhost/hls/camera1.m3u8" type="application/vnd.apple.mpegurl">
    </video>
    <h2>Camera 2 - Logitech C930e</h2>
    <video width="640" height="480" controls autoplay>
        <source src="http://localhost/hls/camera2.m3u8" type="application/vnd.apple.mpegurl">
    </video>
</body>
</html>
```

### **Step 4: Install Additional Python Packages (if needed)**

If you plan to use more packages, install them in your `bf-conda` environment:

```bash
conda install package_name
# or
pip install package_name
```

---

## **7. Testing and Running the Application**

### **Step 1: Run the Flask App**

Ensure you're in the `bf-conda` environment:

```bash
conda activate bf-conda
cd ~/webcam_app
python app.py
```

### **Step 2: Access the Application**

- Open a web browser and navigate to `http://localhost:5000`.
- You should see the webpage with two video streams.

### **Step 3: Access from Other Devices**

Replace `localhost` with your server's IP address in `index.html`:

```html
<source src="http://<your_server_ip>/hls/camera1.m3u8" type="application/vnd.apple.mpegurl">
```

---

## **8. Automating the Setup**

### **Step 1: Create a Shell Script for Starting Streams**

**File: `start_streams.sh`**

```bash
#!/bin/bash
ffmpeg -f v4l2 -i /dev/video0 -vcodec libx264 -preset ultrafast -tune zerolatency -f flv rtmp://localhost/live/camera1 &
ffmpeg -f v4l2 -i /dev/video4 -vcodec libx264 -preset ultrafast -tune zerolatency -f flv rtmp://localhost/live/camera2 &
```

Make the script executable:

```bash
chmod +x start_streams.sh
```

### **Step 2: Create a Shell Script for Setting Up Environment**

**File: `anacondaconfig.sh`**

```bash
#!/bin/bash
# Activate conda environment
source ~/anaconda3/bin/activate bf-conda

# Navigate to the project directory
cd ~/webcam_app

# Run the Flask app
python app.py
```

Make the script executable:

```bash
chmod +x anacondaconfig.sh
```

### **Step 3: Running Everything Together**

Open three terminals:

1. **Terminal 1**: Start Nginx (if not running)

   ```bash
   sudo /usr/local/nginx/sbin/nginx
   ```

2. **Terminal 2**: Start the FFmpeg streams

   ```bash
   ./start_streams.sh
   ```

3. **Terminal 3**: Run the Flask app

   ```bash
   ./anacondaconfig.sh
   ```

Alternatively, you can create a master script to run all components.

---

## **9. Conclusion**

By following these steps, you've set up a webcam pet application that streams video from your Logitech webcams using FFmpeg, Nginx with RTMP and HLS, and serves a web application using Flask within a conda environment named `bf-conda`. This configuration allows for better management of Python packages and environments using Anaconda.

---

## **10. Additional Resources**

- **Anaconda Documentation**: [https://docs.anaconda.com/anaconda/](https://docs.anaconda.com/anaconda/)
- **Conda Cheat Sheet**: [https://docs.conda.io/projects/conda/en/latest/user-guide/cheatsheet.html](https://docs.conda.io/projects/conda/en/latest/user-guide/cheatsheet.html)
- **FFmpeg Documentation**: [https://ffmpeg.org/ffmpeg.html](https://ffmpeg.org/ffmpeg.html)
- **Nginx RTMP Module Documentation**: [https://github.com/arut/nginx-rtmp-module/wiki/Directives](https://github.com/arut/nginx-rtmp-module/wiki/Directives)
- **Flask Documentation**: [https://flask.palletsprojects.com/](https://flask.palletsprojects.com/)

---

## **Troubleshooting and Tips**

- **Permissions**: Ensure your user has permission to access `/dev/videoX` devices. You may need to add your user to the `video` group:

  ```bash
  sudo usermod -a -G video $USER
  ```

  Log out and back in for the changes to take effect.

- **Firewall Settings**: If you have a firewall enabled, allow necessary ports:

  ```bash
  sudo ufw allow 80
  sudo ufw allow 1935
  sudo ufw allow 5000
  ```

- **Check Stream Availability**: Use VLC to test RTMP streams:

  ```bash
  vlc rtmp://localhost/live/camera1
  ```

- **Stream Latency**: To reduce latency, adjust FFmpeg parameters and consider using WebRTC for real-time streaming.

---

## **Next Steps**

- **Enhance the Web Interface**: Improve the `index.html` with better styling and responsiveness.
- **Implement Security**: Add authentication to restrict access to your streams.
- **Add Features**: Implement functionality like motion detection, recording, or remote control.

---

If you have any questions or need further assistance with specific configurations or troubleshooting, feel free to ask!