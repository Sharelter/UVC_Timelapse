#!/bin/bash

# Initialize variables
input_dir=""
output_file=""
frame_rate=24  # Default frame rate

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
	case $1 in
		--input) input_dir="$2"; shift ;;
		--output) output_file="$2"; shift ;;
		--fps) frame_rate="$2"; shift ;;
		*) echo "Unknown parameter passed: $1"; exit 1 ;;
	esac
	shift
done
	
# Check if input directory is provided and exists
if [[ -z "$input_dir" || ! -d "$input_dir" ]]; then
	echo "Input directory is required and must exist."
	exit 1
fi

# Check if output file is provided
if [[ -z "$output_file" ]]; then
	echo "Output file is required."
	exit 1
fi

# Verify that the input directory contains image files
image_files=$(find "$input_dir" -type f -name '*.jpg')
if [[ -z "$image_files" ]]; then
	echo "No image files found in the input directory."
	exit 1
fi

# Use ffmpeg to merge the images into an MP4 file with the specified frame rate
ffmpeg -framerate "$frame_rate" -pattern_type glob -i "$input_dir/*.jpg" -c:v libx264 -pix_fmt yuv420p "$output_file"

# # Use ffmpeg with QSV to merge the images into an MP4 file with the specified frame rate
# ffmpeg -framerate "$frame_rate" -pattern_type glob -i "$input_dir/*.jpg" -c:v h264_qsv -pix_fmt yuv420p "$output_file"

# # Use ffmpeg with VAAPI to merge the images into an MP4 file with the specified frame rate
# ffmpeg -vaapi_device /dev/dri/renderD128 -framerate "$frame_rate" -pattern_type glob -i "$input_dir/*.jpg" -vf 'format=nv12,hwupload' -c:v h264_vaapi -pix_fmt yuv420p "$output_file"

echo "Merging completed: $output_file"