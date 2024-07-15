#!/bin/bash

# Use $SUDO_USER to get the home directory of the user who invoked sudo, fallback to $HOME if not set
if [ -n "$SUDO_USER" ]; then
	HOME_DIR=$(getent passwd "$SUDO_USER" | cut -d: -f6)
else
	HOME_DIR=$HOME
fi

INSTALL_DIR="$HOME_DIR/uvc_timelapse"

# Define the systemd service file path
SERVICE_FILE="/etc/systemd/system/timelapse.service"

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
	echo "This script must be run as root" 1>&2
	exit 1
fi

# Stop and disable the systemd service
echo "Stopping and disabling the timelapse service..."
systemctl stop timelapse
systemctl disable timelapse

# Remove the systemd service file
echo "Removing the systemd service file..."
rm -f "$SERVICE_FILE"

# Reload systemd daemon to apply changes
echo "Reloading systemd daemon..."
systemctl daemon-reload

# Remove the installation directory and its contents
echo "Removing the installation directory and its contents..."
rm -rf "$INSTALL_DIR"

echo "Uninstallation completed successfully."