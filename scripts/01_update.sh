#!/usr/bin/env bash
set -euo pipefail
set -x

# Global variables are defined in setup.sh before this module is sourced
# This ensures all modules have access to them regardless of source order

# Temp dir for downloads (initialize if not already set)
if [ -z "${tempdir:-}" ]; then
	tempdir=$(mktemp -d)
	trap 'rm -rf "$tempdir"' EXIT
fi

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

install_chezmoi() {
	echo ">>> Installing chezmoi..."
	if ! command -v chezmoi >/dev/null; then
		if [ "$OS" = "Darwin" ]; then
			install_homebrew
			brew install chezmoi
		else
			# Install chezmoi on Linux
			chezmoi_bin="$HOME/.local/bin/chezmoi"
			if [ ! -f "$chezmoi_bin" ]; then
				mkdir -p "$HOME/.local/bin"
				sh -c "$(curl -fsLS https://chezmoi.io/get)" -- -b "$HOME/.local/bin"
				# Add to PATH if not already there
				if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
					export PATH="$HOME/.local/bin:$PATH"
				fi
			fi
		fi
	fi
	# Ensure chezmoi is in PATH
	if [ "$OS" != "Darwin" ] && [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
		export PATH="$HOME/.local/bin:$PATH"
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
	install_chezmoi
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
