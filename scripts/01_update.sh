#!/usr/bin/env bash
set -euo pipefail
set -x

OS=$(uname -s)
SOURCE_REPO="https://github.com/ppetroskevicius/tiny-config.git"
TARGET_DIR="$HOME/fun/tiny-config"
OP_ACCOUNT="my"
OP_SSH_KEY_NAME="op://build/my-ssh-key/id_ed25519"
OP_WG_CONFIG_NAME="op://network/wireguard/conf"

NETPLAN_CONFIG="/etc/netplan/50-cloud-init.yaml"
OP_WIFI_SSID="op://network/wifi/ssid"
OP_WIFI_PASS="op://network/wifi/pass"

# Temp dir for downloads
tempdir=$(mktemp -d)
trap 'rm -rf "$tempdir"' EXIT

# ==========================================
# 1. Update packages
# ==========================================
install_homebrew() {
	if [ "$OS" = "Darwin" ]; then
		echo ">>> Checking Homebrew..."
		if ! command -v brew >/dev/null; then
			/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

			# Add Homebrew to PATH (for both Intel and Apple Silicon Macs)
			if [[ -d /opt/homebrew/bin ]]; then
				eval "$(/opt/homebrew/bin/brew shellenv)"
			elif [[ -d /usr/local/bin ]]; then
				eval "$(/usr/local/bin/brew shellenv)"
			fi
		fi
		# Ensure brew is in the path for this session
		if [[ -d /opt/homebrew/bin ]]; then eval "$(/opt/homebrew/bin/brew shellenv)"; fi
	fi
}

update_packages() {
	echo ">>> Updating system packages..."
	if [ "$OS" = "Darwin" ]; then
		install_homebrew
		brew update && brew upgrade
	else
		sudo apt update && sudo apt upgrade -y
	fi
}

setup_timezone() {
	echo ">>> Setting timezone to Asia/Tokyo..."
	if [ "$OS" = "Darwin" ]; then
		sudo systemsetup -settimezone Asia/Tokyo >/dev/null
	else
		sudo timedatectl set-timezone Asia/Tokyo
	fi
}

setup_macos_preferences() {
	if [ "$OS" = "Darwin" ]; then
		echo ">>> Setting macOS Preferences..."
		# Finder preferences
		defaults write com.apple.finder AppleShowAllFiles -bool true
		defaults write com.apple.finder ShowPathbar -bool true
		defaults write com.apple.finder ShowStatusBar -bool true

		# Dock preferences
		defaults write com.apple.dock autohide -bool true
		defaults write com.apple.dock tilesize -int 36

		# Keyboard preferences
		defaults write NSGlobalDomain KeyRepeat -int 2
		defaults write NSGlobalDomain InitialKeyRepeat -int 15

		# Restart affected applications
		for app in "Finder" "Dock" "SystemUIServer"; do
			killall "$app" >/dev/null 2>&1 || true
		done
	fi
}


