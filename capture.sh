#!/bin/bash

# Load configuration
source capture.conf

# Check for ffmpeg and v4l-utils
if ! command -v ffmpeg &> /dev/null || ! command -v v4l2-ctl &> /dev/null; then
	echo "ffmpeg and v4l-utils are required. Please install them first."
	exit 1
fi

# Redirect all output to capture.log
exec > >(awk '{ print strftime("[%Y-%m-%d %H:%M:%S]"), $0; fflush(); }' >>capture.log) 2>&1

# Use the loaded configuration for interval and duration
interval=$INTERVAL_SECONDS

# # Calculate total shots
# let total_shots=($duration*60)/$interval

# Create a directory for the captured images in the user's home directory
timelapse_dir=$TIMELAPSE_DIR
mkdir -p "$timelapse_dir"
cd "$timelapse_dir"

# Query the maximum supported resolution
max_res=$(v4l2-ctl --list-formats-ext | grep -oP 'Size: \K\d+x\d+' | sort -nr | head -1)

# Check if we successfully obtained a resolution
if [ -z "$max_res" ]; then
	echo "Could not determine the maximum resolution of the camera."
	exit 1
fi

echo "Using maximum resolution: $max_res"

# Capture images until storage is less than 10%
while true; do
	if [ ! -e /dev/video0 ]; then
		echo "USB UVC device not found. Please ensure the device is properly connected."
		exit 1
	fi

	remaining_storage=$(df "$timelapse_dir" | awk 'NR==2 {print $4/$2*100}')
	if (( $(echo "$remaining_storage < 10" | bc -l) )); then
		echo "Remaining storage is below 10%, stopping capture."
		break
	fi

	start_time=$(date +%s.%N)
	filename=$(date +'%Y-%m-%d_%H-%M-%S').jpg
	ffmpeg -f v4l2 -video_size $max_res -i /dev/video0 -frames 1 "$filename"
	if [ $? -ne 0 ]; then
		echo "Error capturing image. Please check the camera and try again."
		exit 1
	fi
	echo "Captured $filename"
	end_time=$(date +%s.%N)
	elapsed=$(echo "$end_time - $start_time" | bc)
	adjusted_sleep=$(echo "$interval - $elapsed" | bc)
	echo "Capture took $elapsed seconds, sleeping for $adjusted_sleep seconds"
	sleep $adjusted_sleep
done