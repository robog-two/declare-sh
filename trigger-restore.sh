#!/bin/bash
set -euo pipefail

REPO_DIR="/opt/declare-sh"
FLAG_FILE="/run/apply-config"

cd "$REPO_DIR"

echo "[$(date)] Checking for configuration updates..."

# Fetch latest changes from Git
git fetch origin

# Get current and remote HEAD commits
LOCAL_HEAD=$(git rev-parse HEAD)
REMOTE_HEAD=$(git rev-parse origin/main)

echo "[$(date)] Local HEAD:  $LOCAL_HEAD"
echo "[$(date)] Remote HEAD: $REMOTE_HEAD"

# Compare commits
if [ "$LOCAL_HEAD" != "$REMOTE_HEAD" ]; then
    echo "[$(date)] Changes detected. Setting restore flag and rebooting..."

    # Create flag file to signal restore is needed
    touch "$FLAG_FILE"

    # Trigger system reboot
    systemctl reboot
else
    echo "[$(date)] No changes detected. System is up to date."
fi
