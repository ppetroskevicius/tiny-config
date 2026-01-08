#!/usr/bin/env bash
set -euo pipefail
set -x

# ==========================================
# 12. Desktop Applications
# ==========================================
install_desktop_apps() {
	echo ">>> Installing Desktop Apps..."
	install_starship
	install_alacritty_app
	install_1password_app
	install_zed_app
	install_cursor_app
	install_claude_code_app
	install_chrome_app
	install_firefox_app
	install_discord_app
	install_zotero_app
	install_spotify_app

	if [ "$OS" != "Darwin" ]; then
		install_remote_desktop
	fi
}

install_starship() { curl -sS https://starship.rs/install.sh | sh -s -- -y; }

install_alacritty_app() {
	if ! command -v alacritty >/dev/null; then
		if [ "$OS" = "Darwin" ]; then
			brew install alacritty
		else
			sudo apt install -y cmake g++ pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev
			git clone https://github.com/alacritty/alacritty.git /tmp/alacritty
			cd /tmp/alacritty && cargo install alacritty && cd - && rm -rf /tmp/alacritty
		fi
	fi
}
install_1password_app() {
	if [ "$OS" = "Darwin" ]; then brew install --cask 1password; else sudo apt install -y 1password; fi
}
install_zed_app() {
	if [ "$OS" = "Darwin" ]; then brew install --cask zed; else curl -f https://zed.dev/install.sh | sh; fi
}
install_cursor_app() {
	if [ "$OS" = "Darwin" ]; then
		brew install --cask cursor
	else
		sudo apt install libnotify-bin
		curl -fsSL https://raw.githubusercontent.com/mxsteini/cursor_patch/main/cursor-install.sh | bash
	fi
}
install_claude_code_app() { pnpm add -g @anthropic-ai/claude-code; }
install_chrome_app() {
	if [ "$OS" = "Darwin" ]; then
		brew install --cask google-chrome
	else
		wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/chrome.deb
		sudo apt install -y fonts-liberation xdg-utils && sudo dpkg -i /tmp/chrome.deb && rm /tmp/chrome.deb
	fi
}
install_firefox_app() {
	if [ "$OS" = "Darwin" ]; then brew install --cask firefox; else sudo apt install -y firefox; fi
}
install_discord_app() {
	if [ "$OS" = "Darwin" ]; then
		brew install --cask discord
	else
		wget -O /tmp/discord.deb "https://discord.com/api/download?platform=linux&format=deb"
		sudo dpkg -i /tmp/discord.deb && rm /tmp/discord.deb
	fi
}
install_zotero_app() {
	if [ "$OS" = "Darwin" ]; then
		brew install --cask zotero
	else
		wget -qO- https://raw.githubusercontent.com/retorquere/zotero-deb/master/install.sh | sudo bash
		sudo apt update && sudo apt install -y zotero
	fi
}
install_spotify_app() {
	if [ "$OS" = "Darwin" ]; then
		brew install --cask spotify
	else
		curl -sS https://download.spotify.com/debian/pubkey_C85668DF69375001.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
		echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
		sudo apt update && sudo apt install -y spotify-client
	fi
}
install_remote_desktop() { sudo apt install -y remmina; }
