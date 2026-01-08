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
	echo ">>> Setting up SSH keys..."
	if ! [ -f "$HOME/.ssh/id_ed25519" ]; then
		mkdir -p ~/.ssh && chmod 700 ~/.ssh
		op read -f --out-file ~/.ssh/id_ed25519 "$OP_SSH_KEY_NAME"
		chmod 600 ~/.ssh/id_ed25519
		ssh-keygen -y -f ~/.ssh/id_ed25519 >~/.ssh/id_ed25519.pub
		cat ~/.ssh/id_ed25519.pub >>~/.ssh/authorized_keys
		chmod 600 ~/.ssh/authorized_keys
		ssh-keyscan github.com >>~/.ssh/known_hosts 2>/dev/null
		# Start agent
		if [ "$OS" != "Darwin" ]; then
			systemctl --user enable --now ssh-agent.service 2>/dev/null || true
		fi
		eval "$(ssh-agent -s)" >/dev/null
		ssh-add ~/.ssh/id_ed25519
	fi
}

setup_wireguard_client() {
	# Wireguard logic (Linux only for CLI config)
	echo ">>> Setting up Wireguard Client..."
	if [ "$OS" != "Darwin" ]; then
		if ! dpkg -l wireguard >/dev/null 2>&1; then
			sudo apt install -y wireguard
		fi

		if ! [ -f "/etc/wireguard/gw0.conf" ]; then
			sudo mkdir -p /etc/wireguard
			op read -f --out-file /tmp/gw0.conf "$OP_WG_CONFIG_NAME"
			sudo mv /tmp/gw0.conf /etc/wireguard/
			sudo chmod 600 /etc/wireguard/gw0.conf
			sudo chown root: /etc/wireguard/gw0.conf
			echo "Wireguard config placed. Enable with: sudo wg-quick up gw0"
		fi
	else
		echo "Skipping CLI Wireguard setup on macOS (use App Store client)."
	fi
}
