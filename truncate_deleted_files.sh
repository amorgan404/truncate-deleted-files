#!/bin/bash
# ------------------------------------------------------
# Script Name: truncate_deleted_files.sh
# Author: Ahmed Morgan
# Description: This script identifies and truncates deleted
#              files that are still being held by processes,
#              freeing up disk space without restarting services.
# Supports     --dry-run to preview affected files before
#              performing truncation.
# ------------------------------------------------------
SCRIPT_PID=$$
DRY_RUN=false

# Enable dry-run if passed as argument
if [ "$1" == "--dry-run" ]; then
    DRY_RUN=true
    echo "🧪 Dry-run mode enabled. No files will be truncated."
fi

# Get list of deleted files held by java processes
lsof -nP | grep '(deleted)' | grep java | awk '{print $2, $4}' | while read -r PID FD; do
    # Skip if PID is invalid or matches this script
    [[ "$PID" =~ ^[0-9]+$ ]] || continue
    if [ "$PID" -eq "$SCRIPT_PID" ]; then
        continue
    fi

    # Extract numeric file descriptor only
    FD_NUM=$(echo "$FD" | sed -n 's/^\([0-9]\+\)[rwu]*$/\1/p')

    # Skip if FD_NUM is empty (invalid format)
    if [ -z "$FD_NUM" ]; then
        continue
    fi

    FD_PATH="/proc/$PID/fd/$FD_NUM"

    if [ -e "$FD_PATH" ] && [ ! -d "$FD_PATH" ]; then
        if [ "$DRY_RUN" = true ]; then
            echo "Would truncate: $FD_PATH"
        else
            echo "Truncating: $FD_PATH"
            : > "$FD_PATH"
        fi
    fi
done
