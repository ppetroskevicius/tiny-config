#!/usr/bin/env bash
set -euo pipefail
set -x

# ==========================================
# 11. Desktop Environment (Linux)
# ==========================================
install_desktop_env_linux() {
	setup_sway_wayland
	install_i3status-rs
	install_notifications
	install_kickoff
	setup_bluetooth_audio
	install_screenshots
	setup_japanese
	setup_power_management
	setup_brightness
	setup_gamma
	install_wireguard
	install_nerd_fonts
}

setup_sway_wayland() {
	sudo apt install -y sway wayland-protocols xwayland swayidle swaylock swayimg desktop-file-utils \
		xdg-desktop-portal xdg-desktop-portal-wlr pipewire-audio-client-libraries
	systemctl --user enable --now xdg-desktop-portal.service 2>/dev/null || true
}

install_i3status-rs() {
	if ! [ -f "$HOME/.cargo/bin/i3status-rs" ]; then
		sudo apt install -y libssl-dev libsensors-dev libpulse-dev libnotmuch-dev pandoc
		git clone https://github.com/greshake/i3status-rust "$tempdir/i3status-rust"
		cd "$tempdir/i3status-rust"
		cargo install --path . --locked
		./install.sh
		cd - >/dev/null
	fi
}

install_notifications() { sudo apt install -y mako-notifier; }
install_kickoff() { cargo install kickoff; }

setup_bluetooth_audio() {
	sudo apt install -y bluez blueman bluetooth pavucontrol alsa-utils playerctl pulsemixer fzf \
		pipewire pipewire-pulse pipewire-audio wireplumber pipewire-alsa pulseaudio-module-bluetooth
	sudo systemctl enable --now bluetooth
	systemctl --user enable --now pipewire pipewire-pulse wireplumber 2>/dev/null || true
}

install_screenshots() {
	if ! command -v shotman >/dev/null; then
		sudo apt install -y slurp scdoc libxcb-shape0-dev libxcb-xfixes0-dev libgtk-3-dev libasound2-dev nasm cmake
		git clone https://git.sr.ht/~whynothugo/shotman "$tempdir/shotman"
		cd "$tempdir/shotman" && cargo build --release && sudo make install && cd -
		cargo install oculante
	fi
}

setup_japanese() {
	sudo apt install -y fcitx5 fcitx5-mozc fcitx5-configtool
	im-config -n fcitx5
}

setup_power_management() {
	sudo apt install -y tlp tlp-rdw
	sudo systemctl enable --now tlp
	sudo rm -f /etc/tlp.conf
	sudo ln -sf "$HOME/fun/tiny-config/.tlp.conf" /etc/tlp.conf
}

setup_brightness() {
	sudo apt install -y brightnessctl
	sudo usermod -aG video "$USER"
}

setup_gamma() {
	if ! command -v wl-gammarelay-rs >/dev/null; then
		cargo install wl-gammarelay-rs --locked
	fi
}

setup_netplan() {
	# Caution: Only call this if you are sure about network interfaces
	if systemctl is-enabled --quiet NetworkManager; then
		sudo systemctl stop NetworkManager && sudo systemctl disable NetworkManager
	fi
	sudo systemctl enable --now systemd-networkd
}

install_wireguard() { sudo apt install -y wireguard; }

install_nerd_fonts() {
	echo ">>> Installing Fonts..."
	if [ "$OS" = "Darwin" ]; then
		brew install --cask font-fira-code-nerd-font font-meslo-lg-nerd-font
	else
		if ! fc-list | grep -q "Nerd"; then
			sudo apt install -y fonts-noto
			declare -a fonts=("0xProto" "FiraCode" "Hack" "Meslo" "AnonymousPro" "IntelOneMono")
			font_dir="$HOME/.local/share/fonts"
			mkdir -p "$font_dir"
			version=$(curl -s "https://api.github.com/repos/ryanoasis/nerd-fonts/tags" | jq -r '.[0].name')
			for font in "${fonts[@]}"; do
				wget --quiet "https://github.com/ryanoasis/nerd-fonts/releases/download/${version}/${font}.zip" -O "$font.zip"
				unzip -qo "$font.zip" -d "$font_dir" && rm "$font.zip"
			done
			fc-cache -fv >/dev/null
		fi
	fi
}
