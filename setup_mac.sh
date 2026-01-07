#!/usr/bin/env bash
set -euo pipefail
set -x

SECONDS=0

# shellcheck source=/dev/null
source ./install_common_dependencies.sh
# shellcheck source=/dev/null
source ./install_python_dependencies.sh

install_homebrew() {
	if ! command -v brew >/dev/null; then
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

		# Add Homebrew to PATH (for both Intel and Apple Silicon Macs)
		if [[ -d /opt/homebrew/bin ]]; then
			eval "$(/opt/homebrew/bin/brew shellenv)"
		elif [[ -d /usr/local/bin ]]; then
			eval "$(/usr/local/bin/brew shellenv)"
		fi
	fi

	brew update
}

install_brew_packages() {
	brew install git gh vim tmux htop coreutils netcat jq git-lfs inxi
}

install_brew_apps() {
	brew install --cask 1password google-chrome firefox zed cursor windsurf discord zotero spotify font-fira-code-nerd-font font-meslo-lg-nerd-font font-meslo-lg-nerd-font || true
}

setup_macos_preferences() {
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
}

main() {
	install_homebrew
	install_brew_packages
	# Common setup
	setup_1password_cli
	setup_credentials
	install_zsh
	install_dotfiles
	install_node
	install_playwright_cli
	install_java
	install_aws_cli
	install_gcp_cli
	install_firebase_cli
	install_terraform_cli
	install_rust
	install_nerd_fonts
	install_starship
	install_docker
	install_podman
	install_alacritty_app
	install_claude_code_app
	install_yazi
	# Python setup
	install_uv
	install_linters_formatters
	# macOS-specific setup
	install_brew_apps
	setup_macos_preferences
}

main
echo "[ ] macOS setup completed in t=$SECONDS seconds"
