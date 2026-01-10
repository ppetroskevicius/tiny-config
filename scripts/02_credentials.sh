#!/usr/bin/env bash
set -euo pipefail
set -x

# ==========================================
# 2. Setup Credentials
# ==========================================
setup_1password_cli() {
	echo ">>> Setting up 1Password CLI..."
	if ! command -v op >/dev/null; then
		if [ "$OS" = "Darwin" ]; then
			brew install 1password-cli
		else
			curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg
			echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/amd64 stable main' | sudo tee /etc/apt/sources.list.d/1password.list
			sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/
			curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol
			sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22
			curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg
			sudo apt update && sudo apt install -y 1password-cli
		fi
	fi
	# Only sign in if not already signed in
	if ! op account get >/dev/null 2>&1; then
		eval "$(op signin --account $OP_ACCOUNT)"
	fi
}

setup_ssh_credentials() {
	echo ">>> SSH keys are managed by chezmoi (encrypted templates)"
	echo ">>> They will be set up when chezmoi applies dotfiles"
	# Ensure SSH directory exists with correct permissions
	mkdir -p ~/.ssh && chmod 700 ~/.ssh
	# SSH keys and setup will be handled by chezmoi run_after scripts
}

setup_wireguard_client() {
	echo ">>> Wireguard config is managed by chezmoi (encrypted templates)"
	echo ">>> It will be set up when chezmoi applies dotfiles"
	# Wireguard installation and config will be handled by chezmoi
	if [ "$OS" != "Darwin" ]; then
		if ! dpkg -l wireguard >/dev/null 2>&1; then
			sudo apt install -y wireguard
		fi
	fi
}
