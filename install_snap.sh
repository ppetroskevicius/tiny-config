#!/usr/bin/env bash
#
# install_snap.sh — Re‑enable and validate Snap support on Ubuntu Server 24.04+
# Usage:  sudo ./install_snap.sh

set -euo pipefail

# 1. Remove any APT pin that blocks snapd
PIN_FILE="/etc/apt/preferences.d/nosnap.pref"
if [[ -f "$PIN_FILE" ]]; then
  echo "Removing APT pin at $PIN_FILE ..."
  sudo rm -f "$PIN_FILE"
fi

# 2. Unmask snapd services (if previously masked)
echo "Unmasking snapd systemd units ..."
sudo systemctl unmask snapd.socket snapd.service snapd.seeded.service 2>/dev/null || true

# 3. Refresh APT metadata
echo "Updating package lists ..."
sudo apt update -y

# 4. Install snapd
echo "Installing snapd ..."
sudo apt install -y snapd

# 5. Enable and start socket activation
echo "Enabling snapd.socket ..."
sudo systemctl enable --now snapd.socket

# 6. Ensure /snap symlink exists (handy for CLI‑only servers)
[[ -e /snap ]] || sudo ln -s /var/lib/snapd/snap /snap

# 7. Validate installation
echo "Validating Snap installation ..."
if snap version >/dev/null 2>&1; then
  echo -e "\e[32mSnap installed successfully!\e[0m"
  snap version           # show versions to the user
else
  echo -e "\e[31mSnap installation failed.\e[0m"
  exit 1
fi

