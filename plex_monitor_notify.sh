#!/bin/bash
# v0.4

# Log file containing new file paths.  Must match monitor script.
LOG_FILE="/tmp/monitor_plex_tube.log"
# Plex server details
PLEX_URL="https://10.55.55.55:32400"
PLEX_TOKEN="ohfdsaigeauihgn"
# The library section ID for videos (Find this in Plex settings or via API)
# Find out the ID with: curl -k https://your_server:32400/library/sections&X-Plex-Token=your_server_token
# More info: https://support.plex.tv/articles/201638786-plex-media-server-url-commands/
LIBRARY_SECTION_ID="6"

# Check if the log file exists and is readable
if [[ ! -f "$LOG_FILE" || ! -r "$LOG_FILE" ]]; then
    echo "No logs: $LOG_FILE" >&2
    exit 1
fi

# Function to Encode path to be URL compatible for curl command
function url_encode() {
    echo "$@" \
    | sed \
        -e 's/%/%25/g' \
        -e 's/ /%20/g' \
        -e 's/!/%21/g' \
        -e 's/"/%22/g' \
        -e "s/'/%27/g" \
        -e 's/#/%23/g' \
        -e 's/(/%28/g' \
        -e 's/)/%29/g' \
        -e 's/+/%2b/g' \
        -e 's/,/%2c/g' \
        -e 's/-/%2d/g' \
        -e 's/:/%3a/g' \
        -e 's/;/%3b/g' \
        -e 's/?/%3f/g' \
        -e 's/@/%40/g' \
        -e 's/\$/%24/g' \
        -e 's/\&/%26/g' \
        -e 's/\*/%2a/g' \
        -e 's/\./%2e/g' \
        -e 's/\//%2f/g' \
        -e 's/\[/%5b/g' \
        -e 's/\\/%5c/g' \
        -e 's/\]/%5d/g' \
        -e 's/\^/%5e/g' \
        -e 's/_/%5f/g' \
        -e 's/`/%60/g' \
        -e 's/{/%7b/g' \
        -e 's/|/%7c/g' \
        -e 's/}/%7d/g' \
        -e 's/~/%7e/g'
}

# Process each line in the log file
while IFS= read -r FILE_PATH || [[ -n "$FILE_PATH" ]]; do
    # Skip empty lines
    [[ -z "$FILE_PATH" ]] && continue

    # Call URL encode function to URL encode the file path
    URL_ENCODED_FILE_PATH=$(url_encode "$FILE_PATH")
    # echo encoded path: $URL_ENCODED_FILE_PATH # enable for troubleshooting

    # Notify Plex to scan the file folder
    response=$(curl -k -X POST "$PLEX_URL/library/sections/$LIBRARY_SECTION_ID/refresh?path=$URL_ENCODED_FILE_PATH&X-Plex-Token=$PLEX_TOKEN"  -o /dev/null -w "%{http_code}\n")
    echo curl response: $response

    # Check if the HTTP status code indicates success by plex server
    if [[ "$response" == "200" ]]; then
        # Remove the processed line from the log only if the request was successful
        if sed -i '1d' "$LOG_FILE"; then
            echo "Successfully notified Plex and removed from log for file:" 
            echo "$FILE_PATH"
            echo "_________________________________________________________"
        else
            log_error "Failed to remove file path from log: $FILE_PATH"
        fi
    else
        echo "Failed to notify Plex for file: $FILE_PATH. HTTP status: $response" >&2
    fi

done < "$LOG_FILE"
