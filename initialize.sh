#!/bin/bash
set -euo pipefail

echo "=== Starting one-time system initialization ==="

# Example: Create users (customize as needed)
# if ! id -u appuser &>/dev/null; then
#     echo "Creating appuser..."
#     useradd -m -s /bin/bash appuser
# fi

# Example: Install packages (customize as needed)
# echo "Installing required packages..."
# apt-get update
# apt-get install -y curl git btrfs-progs

# Example: Configure services (customize as needed)
# echo "Configuring services..."
# systemctl enable some-service
# systemctl start some-service

# NOTE: Cron job is already installed by firstrun/declare.sh
# Add your custom initialization logic here

echo "=== One-time initialization complete ==="
