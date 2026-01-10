#!/usr/bin/env bash
set -euo pipefail
set -x

# ==========================================
# 4. Dotfiles (via Chezmoi)
# ==========================================
install_dotfiles_core() {
	echo ">>> Installing Core CLI Dotfiles via chezmoi..."
	install_dotfiles_via_chezmoi
}

install_dotfiles_desktop() {
	echo ">>> Installing Desktop GUI Dotfiles via chezmoi..."
	install_dotfiles_via_chezmoi
}

install_dotfiles_via_chezmoi() {
	# Ensure chezmoi is installed
	if ! command -v chezmoi >/dev/null; then
		echo "Error: chezmoi is not installed. Please run update_packages first."
		return 1
	fi

	# Ensure 1Password CLI is available (needed for encrypted templates)
	if ! command -v op >/dev/null; then
		echo "Warning: 1Password CLI not found. Some encrypted dotfiles may not apply correctly."
	fi

	# Initialize chezmoi if not already initialized
	if ! chezmoi verify >/dev/null 2>&1; then
		echo ">>> Initializing chezmoi from repository: $CHEZMOI_REPO"
		chezmoi init "$CHEZMOI_REPO"
	else
		echo ">>> Updating chezmoi repository..."
		chezmoi update
	fi

	# Apply dotfiles
	echo ">>> Applying dotfiles..."
	chezmoi apply --verbose
}
