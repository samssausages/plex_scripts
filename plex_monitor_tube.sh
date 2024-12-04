#!/bin/bash

# Host path to monitor
HOST_DIR="/mnt/wpool/media_tube"
# Container path (what Plex sees)
PLEX_DIR="/mnt/media/tube"

# Log file to store detected file paths
LOG_FILE="/tmp/monitor_plex_tube.log"

# video file extensions (case-insensitive)
VIDEO_EXTENSIONS="mp4|mkv|m4v|mov|mpeg|mpg|avi|wmv|asf|ts|m2ts|mts|mjpg|mjpeg|webm|mxf"

# Function to translate host path to container path for the log file
translate_path() {
    local host_path=$1
    # Check if the path starts with the host directory
    if [[ "$host_path" == "$HOST_DIR"* ]]; then
        # Replace the host directory with the container directory
        echo "${PLEX_DIR}${host_path#$HOST_DIR}"
    else
        # If the path doesn't match, just return it as is
        echo "$host_path"
    fi
}

# Start monitoring the folder recursively
inotifywait -m -r -e create --format '%w%f' "$HOST_DIR" | while read NEW_FILE
do
    # Check if the new file has a valid video extension
    if [[ "$NEW_FILE" =~ \.($VIDEO_EXTENSIONS)$ ]]; then
        # Extract the directory path and translate it
        DIR_PATH=$(dirname "$NEW_FILE")
        CONTAINER_PATH=$(translate_path "$DIR_PATH")
        # Adding timestamp
        TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
        # Log the container path
        echo "$CONTAINER_PATH" >> "$LOG_FILE"
        echo "$TIMESTAMP" added "$CONTAINER_PATH"
        # Sort and remove duplicates in one go
        sort -u "$LOG_FILE" -o "$LOG_FILE"
    fi
done
