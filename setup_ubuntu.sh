#!/usr/bin/env bash
set -euo pipefail
set -x

# Timer for completion tracking
SECONDS=0
SETUP_TYPE=${1:-"bm-hypervisor"} # Options: bm-hypervisor, vm-k8s-node, vm-dev-container, vm-service, dt-dev

# shellcheck source=/dev/null
source ./install_common_dependencies.sh
# shellcheck source=/dev/null
source ./install_ubuntu_dependencies.sh

# Main execution
main() {

	# Common packges
	update_packages
	install_packages_common
	setup_1password_cli
	setup_credentials
	install_zsh
	install_dotfiles
	setup_timezone

	case "$SETUP_TYPE" in
	"bm-hypervisor")
		echo "Performing bare metal hypervisor setup..."
		install_packages_bm_hypervisor
		remove_snap
		;;
	"vm-k8s-node")
		echo "Performing Kubernetes VM node setup..."
		install_packages_vm_k8s_node
		install_k3s
		remove_snap
		;;
	"vm-dev-container")
		echo "Performing development container VM setup..."
		install_packages_vm_dev_container
		install_docker
		install_dev_container_cli
		remove_snap
		;;
	"vm-service")
		echo "Performing service VM setup..."
		install_packages_vm_service
		remove_snap
		;;
	"dt-dev")
		echo "Performing development desktop setup..."
		# Install base packages
		install_packages_dt_dev
		# Setup desktop environment
		setup_netplan
		install_wireguard
		# Development languages and tools
		install_node
		install_playwright_cli
		install_rust
		install_uv
		install_linters_formatters
		install_java
		install_kotlin
		install_golang
		# Cloud CLIs
		install_aws_cli
		install_gcp_cli
		install_firebase_cli
		install_terraform_cli
		install_github_cli
		# Desktop environment
		install_alacritty_app
		setup_bluetooth_audio
		setup_sway_wayland
		install_nerd_fonts
		install_i3status-rs
		install_screenshots
		install_notifications
		install_kickoff
		install_yazi
		setup_power_management
		setup_brightness
		setup_gamma
		setup_japanese
		# Prompt and containers
		install_starship
		install_docker
		install_dev_container_cli
		remove_snap
		# Desktop applications
		install_1password_app
		install_zed_app
		install_cursor_app
		install_claude_code_app
		install_chrome_app
		install_discord_app
		install_zotero_app
		install_spotify_app
		install_spotify_player
		install_remote_desktop
		;;
	"gpu")
		# Legacy GPU setup option (for ROCm installation)
		install_ollama
		;;
	*)
		echo "Error: Please specify one of: bm-hypervisor, vm-k8s-node, vm-dev-container, vm-service, dt-dev"
		exit 1
		;;
	esac

	cleanup_all
}

main
echo "[ ] Ubuntu setup completed in t=$SECONDS seconds"
