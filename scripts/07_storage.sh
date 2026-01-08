#!/usr/bin/env bash
set -euo pipefail
set -x

# ==========================================
# 7. Storage & Filesystems
# ==========================================
install_storage_utilities() {
	if [ "$OS" != "Darwin" ]; then
		echo ">>> Installing Storage Utilities..."
		dpkg -l zfsutils-linux mdadm fio nvme-cli pciutils nfs-kernel-server >/dev/null 2>&1 ||
			sudo apt install -y zfsutils-linux mdadm fio nvme-cli pciutils nfs-kernel-server
	fi
}

setup_raid() {
	if [ "$OS" != "Darwin" ]; then
		echo ">>> Setting up RAID (BM-Hypervisor only)..."
		if [ -b /dev/md0 ]; then
			echo "RAID array /dev/md0 found, skipping creation..."
		else
			# WARNING: Hardcoded devices! Verify before running.
			echo "WARNING: Attempting to create RAID on nvme[1-4]n1. Press Ctrl+C to abort in 5s..."
			sleep 5
			sudo mdadm --create --verbose /dev/md0 --level=0 --raid-devices=4 /dev/nvme1n1 /dev/nvme2n1 /dev/nvme3n1 /dev/nvme4n1
			sudo mkfs.ext4 /dev/md0
			sudo mkdir -p /mnt/raid0
			sudo mount /dev/md0 /mnt/raid0
			sudo chown fastctl:fastctl /mnt/raid0
			sudo chmod 755 /mnt/raid0
			sudo sh -c 'uuid=$(blkid -s UUID -o value /dev/md0); grep -q "$uuid" /etc/fstab || echo "UUID=$uuid /mnt/raid0 ext4 defaults 0 2" >> /etc/fstab'
			sudo mdadm --detail --scan | sudo tee -a /etc/mdadm/mdadm.conf
			sudo update-initramfs -u
		fi
	fi
}
