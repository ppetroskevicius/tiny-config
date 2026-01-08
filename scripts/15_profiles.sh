#!/usr/bin/env bash
set -euo pipefail
set -x

# ==========================================
# 15. Profiles (Controller)
# ==========================================

profile_bm_hypervisor() {
	# Force Linux check
	[ "$OS" == "Darwin" ] && {
		echo "BM-Hypervisor profile not supported on macOS"
		exit 1
	}
	echo "=== Provisioning BM-Hypervisor ==="
	update_packages
	setup_timezone
	setup_1password_cli
	setup_ssh_credentials
	install_zsh
	install_dotfiles_core
	install_basic_utilities
	install_system_monitoring
	install_storage_utilities
	install_kvm
	setup_raid
	cleanup_all
}

profile_vm_k8s_node() {
	[ "$OS" == "Darwin" ] && {
		echo "VM-K8s-Node profile not supported on macOS"
		exit 1
	}
	echo "=== Provisioning VM-K8s-Node ==="
	update_packages
	setup_timezone
	setup_1password_cli
	setup_ssh_credentials
	install_zsh
	install_dotfiles_core
	install_basic_utilities
	install_system_monitoring
	install_file_text_utilities
	install_system_info_utilities
	install_network_utilities
	install_python_base
	install_k3s
	cleanup_all
}

profile_vm_dev_container() {
	echo "=== Provisioning VM-Dev-Container ==="
	update_packages
	setup_timezone
	setup_1password_cli
	setup_ssh_credentials
	install_zsh
	install_dotfiles_core
	install_basic_utilities
	install_system_monitoring
	install_file_text_utilities
	install_system_info_utilities
	install_network_utilities
	install_python_base
	install_docker
	install_node # Required for DevContainer CLI
	install_dev_container_cli
	cleanup_all
}

profile_vm_service() {
	echo "=== Provisioning VM-Service ==="
	update_packages
	setup_timezone
	setup_1password_cli
	setup_ssh_credentials
	install_zsh
	install_dotfiles_core
	install_basic_utilities
	install_system_monitoring
	install_file_text_utilities
	if [ "$OS" != "Darwin" ]; then sudo apt install -y nfs-common; fi
	cleanup_all
}

profile_dt_dev() {
	echo "=== Provisioning DT-Dev (Desktop: $OS) ==="
	update_packages
	setup_timezone
	setup_1password_cli
	setup_ssh_credentials
	setup_wireguard_client # DT-Dev specific (skips on Mac)

	install_zsh
	install_dotfiles_core
	install_dotfiles_desktop

	install_basic_utilities
	install_system_monitoring
	install_file_text_utilities
	install_system_info_utilities
	install_network_utilities
	install_python_base
	install_build_tools

	install_docker
	install_rust
	install_uv
	install_linters_formatters
	install_node
	install_java
	install_kotlin
	install_golang
	install_cloud_tools
	install_yazi
	install_playwright_cli
	install_nerd_fonts

	if [ "$OS" != "Darwin" ]; then
		install_desktop_env_linux
		setup_netplan
	else
		setup_macos_preferences
	fi

	install_desktop_apps
	install_gpu_ml_tools
	cleanup_all
}
