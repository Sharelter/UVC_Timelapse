#!/bin/bash

# Use $SUDO_USER to get the home directory of the user who invoked sudo, fallback to $HOME if not set
if [ -n "$SUDO_USER" ]; then
    HOME_DIR=$(getent passwd "$SUDO_USER" | cut -d: -f6)
else
    HOME_DIR=$HOME
fi

INSTALL_DIR="$HOME_DIR/uvc_timelapse"

# Define the user to run the service as
# Use the SUDO_USER environment variable if set, otherwise use the output of whoami
USER="${SUDO_USER:-$(whoami)}"

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
	echo "This script must be run as root" 1>&2
	exit 1
fi

# Create the installation directory
echo "Creating installation directory at $INSTALL_DIR..."
mkdir -p "$INSTALL_DIR"

# Copy project files
echo "Copying project files to $INSTALL_DIR..."
cp -r ./UVC_Timelapse/* "$INSTALL_DIR/"

# Update ownership (optional, depending on your requirements)
chown -R $USER:$USER "$INSTALL_DIR"

# Create systemd service file
SERVICE_FILE="/etc/systemd/system/timelapse.service"
echo "Creating systemd service file at $SERVICE_FILE..."

cat <<EOF > "$SERVICE_FILE"
[Unit]
Description=Timelapse Camera Service
After=network.target

[Service]
Type=forking
User=$USER
WorkingDirectory=$INSTALL_DIR
ExecStart=/usr/bin/screen -dmS timelapse $INSTALL_DIR/capture.sh
ExecStop=/usr/bin/screen -S timelapse -X quit
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd, enable and start the service
echo "Reloading systemd daemon..."
systemctl daemon-reload
# echo "Enabling timelapse service..."
# systemctl enable timelapse.service
# echo "Starting timelapse service..."
# systemctl start timelapse.service

echo "Installation completed successfully."