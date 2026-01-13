#!/bin/bash
set -euo pipefail

# Parse command line arguments
REPO_URL="${1:-}"

echo "=== Declare-sh First Run Initialization ==="
echo "This script will:"
echo "  1. Install Git and Btrfs tools"
echo "  2. Clone the declare-sh repository to /opt/declare-sh"
echo "  3. Install the daily cron job failsafe"
echo "  4. Install the systemd service"
echo "  5. Create a Btrfs snapshot for restore points"
echo "  6. Restart the system"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "ERROR: This script must be run as root"
    exit 1
fi

# Get repository URL if not provided
if [ -z "$REPO_URL" ]; then
    read -r -p "Enter the Git repository URL: " REPO_URL
    if [ -z "$REPO_URL" ]; then
        echo "ERROR: Repository URL cannot be empty"
        exit 1
    fi
fi

# Install git and btrfs-progs (Debian only)
echo "=== Installing Git and Btrfs tools ==="
apt-get update
apt-get install -y git btrfs-progs
echo "Git and Btrfs tools installed successfully."

# Clone repository to /opt/declare-sh
echo ""
echo "=== Cloning repository ==="
if [ -d "/opt/declare-sh" ]; then
    echo "WARNING: /opt/declare-sh already exists. Removing..."
    rm -rf /opt/declare-sh
fi

git clone "$REPO_URL" /opt/declare-sh
echo "Repository cloned successfully."

# Make scripts executable
echo ""
echo "=== Setting script permissions ==="
chmod +x /opt/declare-sh/*.sh
echo "Scripts made executable."

# Install daily cron job failsafe
echo ""
echo "=== Installing daily cron job failsafe ==="
CRON_JOB="0 0 * * * root /opt/declare-sh/trigger-restore.sh"
CRON_FILE="/etc/cron.d/declare-sh-restore"

cat > "$CRON_FILE" <<EOF
# Daily failsafe check for configuration updates
# Runs every day at midnight
$CRON_JOB
EOF

chmod 0644 "$CRON_FILE"
echo "Cron job installed to $CRON_FILE"

# Install systemd service
echo ""
echo "=== Installing systemd service ==="
cp /opt/declare-sh/run-after-restore.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable run-after-restore.service
echo "Systemd service installed and enabled."

# Create Btrfs snapshot
echo ""
echo "=== Creating Btrfs restore point ==="

# Detect root filesystem
ROOT_FS=$(findmnt -n -o SOURCE /)
ROOT_MOUNT=$(findmnt -n -o TARGET /)

echo "Root filesystem: $ROOT_FS"
echo "Root mount point: $ROOT_MOUNT"

# Check if root is on Btrfs
if ! btrfs filesystem show "$ROOT_FS" &>/dev/null; then
    echo "WARNING: Root filesystem is not Btrfs. Snapshot creation skipped."
    echo "You will need to manually configure restore functionality for your filesystem."
else
    # Create snapshot directory
    SNAPSHOT_DIR="/opt/snapshots"
    mkdir -p "$SNAPSHOT_DIR"

    # Create snapshot name with timestamp
    SNAPSHOT_NAME="clean-state-$(date +%Y%m%d-%H%M%S)"
    SNAPSHOT_PATH="$SNAPSHOT_DIR/$SNAPSHOT_NAME"

    echo "Creating snapshot: $SNAPSHOT_PATH"
    btrfs subvolume snapshot "$ROOT_MOUNT" "$SNAPSHOT_PATH"
    echo "Snapshot created successfully."

    # Create a symlink to latest snapshot
    ln -sf "$SNAPSHOT_PATH" "$SNAPSHOT_DIR/clean-state-latest"
    echo "Symlink created: $SNAPSHOT_DIR/clean-state-latest -> $SNAPSHOT_PATH"

    echo ""
    echo "NOTE: To restore from this snapshot on boot, configure your bootloader"
    echo "      to mount the snapshot subvolume instead of the current root."
    echo "      This typically involves modifying GRUB configuration or using"
    echo "      Btrfs snapshot boot tools like grub-btrfs or snapper."
fi

# Final message
echo ""
echo "=== Installation Complete ==="
echo "The system will now restart to begin the declarative management cycle."
echo ""
read -r -p "Press Enter to restart now, or Ctrl+C to cancel..."

systemctl reboot
