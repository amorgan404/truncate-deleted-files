#!/bin/bash
# ------------------------------------------------------
# Script Name: truncate_deleted_files.sh
# Author: Ahmed Morgan
# Description: This script identifies and truncates deleted
#             files that are still being held by processes,
#             freeing up disk space without restarting services.
# ------------------------------------------------------

echo "Scanning for deleted files consuming space..."

# Get the list of processes with deleted open files
DELETED_FILES=$(lsof | grep deleted | awk '{print $2, $4}' | sed 's/[a-z]$//')

if [[ -z "$DELETED_FILES" ]]; then
    echo "No deleted files consuming space."
    exit 0
fi

# Process each PID and FD
while read -r PID FD; do
    FILE_PATH="/proc/$PID/fd/$FD"
    if [[ -e "$FILE_PATH" ]]; then
        echo "Truncating: $FILE_PATH"
        > "$FILE_PATH"
    fi
done <<< "$DELETED_FILES"

echo "Deleted files have been truncated successfully."
