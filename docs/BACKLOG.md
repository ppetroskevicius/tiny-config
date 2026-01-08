# BACKLOG (TODO FOR LATER. DO NOT NEED TO DO NOW)

This is the backlog of things to do in the future. Do not need to do it now.


1. I would like to add the KVM setup into `bm-hypervisor`, as I did not have if before. I should be something like below:

```bash
sudo apt install qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager
sudo systemctl start libvirtd
sudo systemctl enable libvirtd
sudo systemctl status libvirtd
sudo usermod -aG libvirt $(whoami)
newgrp libvirt
export LIBVIRT_DEFAULT_URI="qemu:///system"

sudo kvm-ok # checking
```

4. I want to add a stand alone script to `setup_storage.sh` to setup zfs storage pools and RAID configurations on `spacex`, `canarywharth` and `oslo`. This also should configure the NFS. `oslo` host is currently down and unaccesible, so we will add the configuration later.

It should be something like below:

```bash
#!/bin/bash

# Install ZFS and NFS server
sudo apt install -y zfsutils-linux nfs-kernel-server nfs-common

# List all disks for verification
lsblk

# Reset and initialize second NVMe for data (1TB, standalone)
sudo zpool destroy nvmedata 2>/dev/null || true
sudo zpool create -f -O compression=lz4 nvmedata nvme1n1
sudo zfs destroy nvmedata/scratch 2>/dev/null || true
sudo zfs create nvmedata/scratch

# Reset and initialize 5 SSDs: sdc, sdd, sde, sdf, sdg (5x1TB, RAIDZ1)
sudo zpool destroy ssdpool 2>/dev/null || true
sudo zpool create -f -O compression=lz4 ssdpool raidz1 sdc sdd sde sdf sdg
sudo zfs destroy ssdpool/data 2>/dev/null || true
sudo zfs create ssdpool/data

# Reset and initialize 2 HDDs: sda, sdh (2x2TB, RAID 0 for speed)
sudo zpool destroy hddspeed 2>/dev/null || true
sudo zpool create -f -O compression=lz4 hddspeed sda sdh
sudo zfs destroy hddspeed/fast 2>/dev/null || true
sudo zfs create hddspeed/fast

# Reset and initialize 1 HDD: sdb (8TB, standalone)
sudo zpool destroy hddsingle 2>/dev/null || true
sudo zpool create -f -O compression=lz4 hddsingle sdb
sudo zfs destroy hddsingle/storage 2>/dev/null || true
sudo zfs create hddsingle/storage

# Clear manual NFS exports to avoid overrides
sudo bash -c 'echo "" > /etc/exports'

# Set NFS sharing for home network only
sudo zfs set sharenfs="rw=192.168.20.0/24" nvmedata/scratch ssdpool/data hddspeed/fast hddsingle/storage
sudo systemctl enable --now nfs-kernel-server rpcbind
sudo exportfs -ra

# Verify setup
echo "Disk usage:"
df -h | grep zfs || echo "No ZFS mounts yet"
echo "ZFS pools and mountpoints:"
sudo zfs list -o name,mountpoint
echo "ZFS pool status:"
sudo zpool status
echo "NFS exports:"
sudo exportfs -v

echo "ZFS exports:"
sudo zfs get sharenfs nvmedata/scratch ssdpool/data hddspeed/fast hddsingle/storage
```

5. I also have issues with my dotfiles for zsh and bash containing definitions for the packages or references to the packages (like starship, or GCP or AWS) that do not exist in particular environments, and then fail, when I login into the terminal. How to deal with that? May be it could check if starship is installed, or if Google Cloud CLI is installed and only run in that case.

6. I want to make sure I have scripts to install the development tools for the below languages: Python, Rust, Go, Java, Kotlin, Node.js.

7. I want to have development containers configuration examples for the development tools for the below languages: Python, Rust, Go, Java, Kotlin, Node.js.

8. I want to keep using shell scripts for the setup and configurations on the new machines and VMs. But I also want to start using the Terraform to create and manage the VMs on the 3 bare metal machines with the KVM running on them.

9. I want to have Kubernetes cluster configured on KVM VMs using k3s. I want one controll plane on one VM, and then 3 working nodes on other 3 VMs. Thus I need terraform sample on how to configure 4 VMs on KVM.
