#!/bin/bash -e

# ROCm post-installation:
# https://rocm.docs.amd.com/projects/install-on-linux/en/latest/how-to/native-install/post-install.html

# Configure PATH
export PATH=$PATH:/opt/rocm/bin

# Verify kernel-mode driver installation
dkms status

# Verify ROCm installation
/opt/rocm/bin/rocminfo

# Verify package installation
sudo apt list --installed | grep amdgpu-dkms
sudo apt list --installed | grep rocm-hip-libraries
