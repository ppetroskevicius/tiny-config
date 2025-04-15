#!/usr/bin/env bash
set -euo pipefail
set -x

# Install ROCm packages
sudo apt install rocm -y

# Post install steps:

# Configure the system linker by indicating where to find the shared objects (.so files) for the ROCm applications
sudo tee --append /etc/ld.so.conf.d/rocm.conf << EOF
/opt/rocm/lib
/opt/rocm/lib64
EOF
sudo ldconfig

# Configure the path to the ROCm binary
update-alternatives --list rocm

# Verify the kernel-mode driver installation
dkms status

# Verify the ROCm installation
sudo rocminfo
clinfo

# Show available memory
rocm-smi --showmeminfo vram

# Verify the package installation
sudo apt list --installed | grep amdgpu-dkms
sudo apt list --installed | grep rocm-hip-libraries

sudo apt install rocm-bandwidth-test -y
rocm-bandwidth-test

# Monitor GPU
watch -n 1 rocm-smi
