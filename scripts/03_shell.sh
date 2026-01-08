#!/usr/bin/env bash
set -euo pipefail
set -x

# ==========================================
# 3. Setup Zsh
# ==========================================
install_zsh() {
	echo ">>> Installing Zsh..."
	if ! command -v zsh >/dev/null; then
		if [ "$OS" = "Darwin" ]; then
			brew install zsh
		else
			sudo apt install -y zsh
			chsh -s /usr/bin/zsh "$USER"
		fi
	fi
	if [ ! -d "$HOME/.oh-my-zsh" ]; then
		git clone https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
		git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
	fi
}
