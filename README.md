# UVC Timelapse

Get timelapse on everything running linux.

This is a set of simple scripts to capture a timelapse using a UVC compatible camera. It uses `v4l2-ctl` to control the camera and `ffmpeg` to capture the images.

This project can also uses systemd to start the timelapse at boot time and get scripts running in screen sessions.

## Usage

If using Debian-based distros, you can install the dependencies with the following command:

```bash
sudo apt update && sudo apt install ffmpeg v4l-utils bc screen -y
```