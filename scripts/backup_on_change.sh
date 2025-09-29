#!/bin/sh

# Configuration
WATCHED_DIRS="/etc/config /etc/init.d /etc/rc.d"
REF_FILE="/root/scripts/.last_backup"
BACKUP_PATH="/mnt/sda1/bkps"
LOG_TAG="backup_watch"
INTERVAL=600 # Scan interval in seconds

# --- Configuration Loading ---

# Check for successful execution of the previous command
check_success() {
    if [ $? -eq 0 ]; then
        logger -t $LOG_TAG "$1"
    else
        logger -t $LOG_TAG "ERROR: $2" >&2
        # Exit status 1 means failure, output to stderr/log
    fi
}

# --- Main Logic ---

logger -t $LOG_TAG "Starting change watcher with interval of ${INTERVAL} seconds."

# Create reference file if it does not exist
if [ ! -f "$REF_FILE" ]; then
    touch "$REF_FILE"
    check_success "Created new reference file: $REF_FILE" "Failed to create reference file"
fi

while true; do
    # logger -t $LOG_TAG "Checking for changes..." # Too verbose

    # Check if there are any files modified since the last backup
    # Suppress permission errors
    CHANGED_FILES=$(find $WATCHED_DIRS -type f -newer "$REF_FILE" 2>&1 | grep -v 'Permission denied')

    if [ -z "$CHANGED_FILES" ]; then
        sleep $INTERVAL
        continue
    fi

    TIMESTAMP=$(date +'%Y%m%d-%H%M%S')
    BACKUP_FILE="$BACKUP_PATH/backup-${HOSTNAME}-${TIMESTAMP}.tar.gz"

    logger -t $LOG_TAG "Changes detected, creating backup: $BACKUP_FILE"

    # Ensure backup directory exists
    mkdir -p "$BACKUP_PATH"

    # Attempt to create the backup
    if sysupgrade -b "$BACKUP_FILE"; then
        # Only update the reference file if the backup command succeeded
        touch "$REF_FILE"
        check_success "Backup SUCCESSFUL: $BACKUP_FILE" "Backup FAILED during sysupgrade"
    else
        logger -t $LOG_TAG "Backup FAILED. sysupgrade returned an error."
        # Optional cleanup for a failed backup file
        rm -f "$BACKUP_FILE" 2>/dev/null
    fi

    # Wait for the configured interval before checking again
    sleep $INTERVAL
done
