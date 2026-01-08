#!/usr/bin/env bash
set -euo pipefail
set -x

# ==========================================
# 6. Hypervisor & Virtualization
# ==========================================
install_kvm() {
	if [ "$OS" != "Darwin" ]; then
		echo ">>> Installing KVM/Libvirt..."
		dpkg -l qemu-kvm >/dev/null 2>&1 ||
			sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager
		sudo systemctl enable --now libvirtd
		sudo usermod -aG libvirt "$USER"
	fi
}
