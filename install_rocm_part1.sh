#!/usr/bin/env bash
set -euo pipefail
set -x

# https://rocm.docs.amd.com/projects/install-on-linux/en/latest/install/install-methods/package-manager/package-manager-ubuntu.html

# Install Linux kernel headers and modules
sudo apt update
sudo apt install "linux-headers-$(uname -r)" "linux-modules-extra-$(uname -r)" -y

# Add yourself to the render and video groups to access GPU resources
sudo usermod -a -G render,video $LOGNAME

# Download and convert the package signing key

# Make the directory if it doesn't exist yet.
# This location is recommended by the distribution maintainers.
sudo mkdir --parents --mode=0755 /etc/apt/keyrings

# Download the key, convert the signing-key to a full
# keyring required by apt and store in the keyring directory
wget https://repo.radeon.com/rocm/rocm.gpg.key -O - \
  | gpg --dearmor | sudo tee /etc/apt/keyrings/rocm.gpg > /dev/null

# Register kernel-mode driver
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/rocm.gpg] https://repo.radeon.com/amdgpu/6.4/ubuntu jammy main" \
  | sudo tee /etc/apt/sources.list.d/amdgpu.list
sudo apt update

# Register ROCm packages
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/rocm.gpg] https://repo.radeon.com/rocm/apt/6.4 noble main" \
  | sudo tee --append /etc/apt/sources.list.d/rocm.list
echo -e 'Package: *\nPin: release o=repo.radeon.com\nPin-Priority: 600' \
  | sudo tee /etc/apt/preferences.d/rocm-pin-600
sudo apt update

# Install kernel driver
sudo apt install amdgpu-dkms -y
sudo reboot
