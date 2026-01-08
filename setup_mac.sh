#!/usr/bin/env bash
set -euo pipefail
set -x

SECONDS=0

# shellcheck source=/dev/null
source ./install_common_dependencies.sh
# shellcheck source=/dev/null
source ./install_mac_dependencies.sh

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
	install_kotlin
	install_golang
	install_aws_cli
	install_gcp_cli
	install_firebase_cli
	install_terraform_cli
	install_rust
	install_nerd_fonts
	install_starship
	install_docker
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
