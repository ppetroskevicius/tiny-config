#!/usr/bin/env bash
set -euo pipefail
# set -x # Uncomment for debugging

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

# ==========================================
# 4. Dotfiles (Split: Core vs Desktop)
# ==========================================
clone_dotfiles_repo() {
	if [ ! -d "$TARGET_DIR" ]; then
		git clone "$SOURCE_REPO" "$TARGET_DIR"
	else
		git -C "$TARGET_DIR" pull
	fi
}

install_dotfiles_core() {
	echo ">>> Installing Core CLI Dotfiles..."
	clone_dotfiles_repo
	cd "$TARGET_DIR" || exit 1
	mkdir -p "$HOME/.config"
	rm -f "$HOME/.bash_profile" "$HOME/.bashrc" "$HOME/.zprofile" "$HOME/.zshrc"

	ln -sf "$TARGET_DIR/.sshconfig" "$HOME/.ssh/config"
	ln -sf "$TARGET_DIR/.bash_profile" "$HOME"
	ln -sf "$TARGET_DIR/.bashrc" "$HOME"
	ln -sf "$TARGET_DIR/.zprofile" "$HOME"
	ln -sf "$TARGET_DIR/.zshrc" "$HOME"
	ln -sf "$TARGET_DIR/.tmux.conf" "$HOME"
	ln -sf "$TARGET_DIR/.vimrc" "$HOME"
	ln -sf "$TARGET_DIR/.gitconfig" "$HOME"
	ln -sf "$TARGET_DIR/.starship.toml" "$HOME/.config/starship.toml"

	# Editors (headless configs)
	ln -sf "$TARGET_DIR/.pylintrc" "$HOME/.config/pylintrc"
	mkdir -p "$HOME/.config/ruff"
	ln -sf "$TARGET_DIR/.ruff.toml" "$HOME/.config/ruff/ruff.toml"
}

install_dotfiles_desktop() {
	echo ">>> Installing Desktop GUI Dotfiles..."
	clone_dotfiles_repo

	# Terminal & Window Manager
	ln -sf "$TARGET_DIR/.alacritty.toml" "$HOME"

	if [ "$OS" != "Darwin" ]; then
		mkdir -p "$HOME/.config/sway" "$HOME/.config/mako" "$HOME/.config/i3status-rust"
		ln -sf "$TARGET_DIR/.sway" "$HOME/.config/sway/config"
		ln -sf "$TARGET_DIR/.mako" "$HOME/.config/mako/config"
		ln -sf "$TARGET_DIR/.i3status-rust.toml" "$HOME/.config/i3status-rust/config.toml"
	fi

	rm -rf "$HOME/.config/alacritty"
	git clone https://github.com/alacritty/alacritty-theme "$HOME/.config/alacritty/themes"

	# Editors (GUI)
	mkdir -p "$HOME/.config/zed" "$HOME/.cursor"
	ln -sf "$TARGET_DIR/zed/keymap.json" "$HOME/.config/zed/"
	ln -sf "$TARGET_DIR/zed/settings.json" "$HOME/.config/zed/"
	ln -sf "$TARGET_DIR/.cursor_mcp.json" "$HOME/.cursor/mcp.json"

	if [ "$OS" = "Darwin" ]; then
		mkdir -p "$HOME/Library/Application Support/Cursor/User"
		ln -sf "$TARGET_DIR/.vscode/settings.json" "$HOME/Library/Application Support/Cursor/User/settings.json"
	else
		mkdir -p "$HOME/.config/Cursor/User"
		ln -sf "$TARGET_DIR/.vscode/settings.json" "$HOME/.config/Cursor/User/settings.json"
	fi

	# Cloud Configs (Desktop only)
	mkdir -p "$HOME/.aws"
	ln -sf "$TARGET_DIR/.aws_config" "$HOME/.aws/config"
}

# ==========================================
# 5. Core System Packages
# ==========================================
install_basic_utilities() {
	echo ">>> Installing Basic Utilities..."
	if [ "$OS" = "Darwin" ]; then
		brew install vim tmux git htop unzip netcat jq coreutils
	else
		dpkg -l vim tmux git keychain htop unzip netcat-openbsd locales direnv >/dev/null 2>&1 ||
			sudo apt install -y vim tmux git keychain htop unzip netcat-openbsd locales direnv
	fi
}

install_system_monitoring() {
	echo ">>> Installing System Monitoring..."
	if [ "$OS" = "Darwin" ]; then
		brew install inxi
		# btop, nvtop can be brew installed if desired: brew install btop nvtop
	else
		dpkg -l btop nvtop inxi lm-sensors >/dev/null 2>&1 ||
			sudo apt install -y btop nvtop inxi lm-sensors
	fi
}

install_file_text_utilities() {
	if [ "$OS" = "Darwin" ]; then
		brew install ripgrep fd git-lfs jq
	else
		dpkg -l csvtool fd-find file ripgrep rsync jq jc >/dev/null 2>&1 ||
			sudo apt install -y csvtool fd-find file ripgrep rsync jq jc
	fi
}

install_system_info_utilities() {
	if [ "$OS" != "Darwin" ]; then
		dpkg -l lshw lsof man-db parallel time >/dev/null 2>&1 ||
			sudo apt install -y lshw lsof man-db parallel time
	fi
}

install_network_utilities() {
	if [ "$OS" != "Darwin" ]; then
		dpkg -l infiniband-diags ipmitool rclone rdma-core systemd-journal-remote >/dev/null 2>&1 ||
			sudo apt install -y infiniband-diags ipmitool rclone rdma-core systemd-journal-remote
	fi
}

install_python_base() {
	if [ "$OS" != "Darwin" ]; then
		dpkg -l python3 python3-pip python3-venv python-is-python3 >/dev/null 2>&1 ||
			sudo apt install -y python3 python3-pip python3-venv python-is-python3
	fi
}

install_build_tools() {
	if [ "$OS" != "Darwin" ]; then
		dpkg -l build-essential clang >/dev/null 2>&1 ||
			sudo apt install -y build-essential clang
	fi
}

# ==========================================
# 6. Hypervisor & Virtualization
# ==========================================
install_kvm() {
	if [ "$OS" != "Darwin" ]; then
		echo ">>> Installing KVM/Libvirt..."
		dpkg -l qemu-kvm >/dev/null 2>&1 ||
			sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager
		sudo systemctl enable --now libvirtd
		sudo usermod -aG libvirt "$USER"
	fi
}

# ==========================================
# 7. Storage & Filesystems
# ==========================================
install_storage_utilities() {
	if [ "$OS" != "Darwin" ]; then
		echo ">>> Installing Storage Utilities..."
		dpkg -l zfsutils-linux mdadm fio nvme-cli pciutils nfs-kernel-server >/dev/null 2>&1 ||
			sudo apt install -y zfsutils-linux mdadm fio nvme-cli pciutils nfs-kernel-server
	fi
}

setup_raid() {
	if [ "$OS" != "Darwin" ]; then
		echo ">>> Setting up RAID (BM-Hypervisor only)..."
		if [ -b /dev/md0 ]; then
			echo "RAID array /dev/md0 found, skipping creation..."
		else
			# WARNING: Hardcoded devices! Verify before running.
			echo "WARNING: Attempting to create RAID on nvme[1-4]n1. Press Ctrl+C to abort in 5s..."
			sleep 5
			sudo mdadm --create --verbose /dev/md0 --level=0 --raid-devices=4 /dev/nvme1n1 /dev/nvme2n1 /dev/nvme3n1 /dev/nvme4n1
			sudo mkfs.ext4 /dev/md0
			sudo mkdir -p /mnt/raid0
			sudo mount /dev/md0 /mnt/raid0
			sudo chown fastctl:fastctl /mnt/raid0
			sudo chmod 755 /mnt/raid0
			sudo sh -c 'uuid=$(blkid -s UUID -o value /dev/md0); grep -q "$uuid" /etc/fstab || echo "UUID=$uuid /mnt/raid0 ext4 defaults 0 2" >> /etc/fstab'
			sudo mdadm --detail --scan | sudo tee -a /etc/mdadm/mdadm.conf
			sudo update-initramfs -u
		fi
	fi
}

# ==========================================
# 8. Container & Orchestration
# ==========================================
install_docker() {
	echo ">>> Installing Docker..."
	if ! command -v docker >/dev/null; then
		if [ "$OS" = "Darwin" ]; then
			brew install --cask docker
		else
			sudo apt-get update
			sudo apt-get install -y ca-certificates curl
			sudo install -m 0755 -d /etc/apt/keyrings
			sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
			sudo chmod a+r /etc/apt/keyrings/docker.asc

			echo \
				"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" |
				sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
			sudo apt update

			sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

			sudo groupadd docker || true
			sudo usermod -aG docker "$USER"
			sudo systemctl enable --now docker
		fi
	fi
}

install_k3s() {
	if [ "$OS" != "Darwin" ]; then
		echo ">>> Installing K3s..."
		if ! command -v k3s >/dev/null; then
			curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode 644
			sudo systemctl enable k3s
			sudo systemctl start k3s
		fi
	fi
}

install_dev_container_cli() {
	if ! command -v devcontainer >/dev/null; then
		if command -v pnpm >/dev/null; then
			pnpm add -g @devcontainers/cli
		elif command -v npm >/dev/null; then
			npm install -g @devcontainers/cli
		fi
	fi
}

# ==========================================
# 9. Development Languages & Tools
# ==========================================
install_rust() {
	if ! [ -f "$HOME/.cargo/bin/cargo" ]; then
		curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
		. "$HOME/.cargo/env"
	fi
}

install_uv() {
	if ! command -v uv >/dev/null; then
		curl -LsSf https://astral.sh/uv/install.sh | sh
		source "$HOME/.local/bin/env" 2>/dev/null || true
		uv self update
	fi
}

install_linters_formatters() {
	uv tool install ruff
	uv tool install mypy
	uv tool install pyright
	uv tool install pylint
	uv tool install pytest
	uv tool install pre-commit
	if [ "$OS" = "Darwin" ]; then
		if ! command -v shellcheck >/dev/null; then brew install shellcheck shfmt; fi
	else
		sudo apt install -y shellcheck shfmt
	fi
}

install_node() {
	if ! command -v nvm >/dev/null; then
		curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
	fi
	export NVM_DIR="$HOME/.nvm"
	[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

	nvm install --lts

	if ! command -v pnpm >/dev/null; then
		curl -fsSL https://get.pnpm.io/install.sh | sh -
	fi
	install_playwright_cli
}

install_java() {
	if command -v java >/dev/null; then return 0; fi
	if [ "$OS" = "Darwin" ]; then
		brew install openjdk
		sudo ln -sfn "$(brew --prefix)/opt/openjdk/libexec/openjdk.jdk" /Library/Java/JavaVirtualMachines/openjdk.jdk || true
	else
		sudo apt install -y default-jdk
	fi
}

install_kotlin() {
	if [ ! -d "$HOME/.sdkman" ]; then
		curl -s "https://get.sdkman.io" | bash
	fi
	source "$HOME/.sdkman/bin/sdkman-init.sh"
	if ! command -v kotlin >/dev/null; then sdk install kotlin; fi
}

install_golang() {
	if ! command -v go >/dev/null; then
		if [ "$OS" = "Darwin" ]; then
			brew install go
		else
			sudo apt install -y golang-go
		fi
	fi
}

# ==========================================
# 10. Cloud CLIs and Dev Tools
# ==========================================
install_cloud_tools() {
	# AWS
	if ! command -v aws >/dev/null; then
		if [ "$OS" = "Darwin" ]; then
			curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "awscliv2.pkg"
			sudo installer -pkg awscliv2.pkg -target /
			rm -f awscliv2.pkg
		else
			curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
			unzip awscliv2.zip
			sudo ./aws/install
			rm -rf awscliv2.zip aws
		fi
	fi

	# GCP
	if ! command -v gcloud >/dev/null; then
		if [ "$OS" = "Darwin" ]; then
			brew install --cask google-cloud-sdk
		else
			echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list >/dev/null
			curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor --yes -o /usr/share/keyrings/cloud.google.gpg
			sudo apt-get update && sudo apt-get install -y google-cloud-cli
		fi
	fi

	# Firebase
	if ! command -v firebase >/dev/null; then
		if command -v pnpm >/dev/null; then pnpm add -g firebase-tools; fi
	fi

	# Terraform & GitHub
	if ! command -v terraform >/dev/null; then
		if [ "$OS" = "Darwin" ]; then
			brew tap hashicorp/tap
			brew install hashicorp/tap/terraform
		else
			wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
			echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
			sudo apt update && sudo apt install terraform
		fi
	fi

	if ! command -v gh >/dev/null; then
		if [ "$OS" = "Darwin" ]; then brew install gh; else sudo apt install gh -y; fi
	fi

	if [ "$OS" != "Darwin" ]; then sudo apt install ansible -y; fi
}

install_yazi() {
	if ! command -v yazi >/dev/null; then
		if [ "$OS" = "Darwin" ]; then
			brew install yazi ffmpeg sevenzip jq poppler fd ripgrep fzf zoxide resvg imagemagick font-symbols-only-nerd-font
		else
			sudo apt install -y ffmpeg p7zip jq poppler-utils fd-find ripgrep fzf zoxide imagemagick
			cargo install --force yazi-build
		fi
	fi
}

install_playwright_cli() {
	if [ "$(uname -s)" != "Darwin" ]; then
		if ! dpkg -s libwoff1 >/dev/null 2>&1; then
			sudo apt-get update && sudo apt-get install -y libwoff1 libevent-2.1-7 libsecret-1-0 libhyphen0 libmanette-0.2-0
		fi
	fi
	if ! command -v playwright >/dev/null; then
		pnpm add -g playwright
		playwright install chromium firefox webkit || true
	fi
}

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

# ==========================================
# 13. GPU & ML Tools
# ==========================================
install_gpu_ml_tools() {
	# Only if NVIDIA card is present
	if [ "$OS" != "Darwin" ]; then
		if lspci | grep -i nvidia >/dev/null; then
			sudo apt install -y nvidia-driver-550
		fi
	fi
	# Ollama
	curl -fsSL https://ollama.com/install.sh | sh
}

# ==========================================
# 14. Cleanup
# ==========================================
cleanup_all() {
	if [ "$OS" = "Darwin" ]; then
		brew cleanup
	else
		sudo apt autoremove -y
		sudo apt clean -y
		# Remove snap
		if command -v snap >/dev/null; then
			sudo apt purge -y snapd
			sudo rm -rf /var/cache/snapd /snap
		fi
	fi
}

# ==========================================
# 15. Profiles (Controller)
# ==========================================

profile_bm_hypervisor() {
	# Force Linux check
	[ "$OS" == "Darwin" ] && {
		echo "BM-Hypervisor profile not supported on macOS"
		exit 1
	}
	echo "=== Provisioning BM-Hypervisor ==="
	update_packages
	setup_timezone
	setup_1password_cli
	setup_ssh_credentials
	install_zsh
	install_dotfiles_core
	install_basic_utilities
	install_system_monitoring
	install_storage_utilities
	install_kvm
	setup_raid
	cleanup_all
}

profile_vm_k8s_node() {
	[ "$OS" == "Darwin" ] && {
		echo "VM-K8s-Node profile not supported on macOS"
		exit 1
	}
	echo "=== Provisioning VM-K8s-Node ==="
	update_packages
	setup_timezone
	setup_1password_cli
	setup_ssh_credentials
	install_zsh
	install_dotfiles_core
	install_basic_utilities
	install_system_monitoring
	install_file_text_utilities
	install_system_info_utilities
	install_network_utilities
	install_python_base
	install_k3s
	cleanup_all
}

profile_vm_dev_container() {
	echo "=== Provisioning VM-Dev-Container ==="
	update_packages
	setup_timezone
	setup_1password_cli
	setup_ssh_credentials
	install_zsh
	install_dotfiles_core
	install_basic_utilities
	install_system_monitoring
	install_file_text_utilities
	install_system_info_utilities
	install_network_utilities
	install_python_base
	install_docker
	install_node # Required for DevContainer CLI
	install_dev_container_cli
	cleanup_all
}

profile_vm_service() {
	echo "=== Provisioning VM-Service ==="
	update_packages
	setup_timezone
	setup_1password_cli
	setup_ssh_credentials
	install_zsh
	install_dotfiles_core
	install_basic_utilities
	install_system_monitoring
	install_file_text_utilities
	if [ "$OS" != "Darwin" ]; then sudo apt install -y nfs-common; fi
	cleanup_all
}

profile_dt_dev() {
	echo "=== Provisioning DT-Dev (Desktop: $OS) ==="
	update_packages
	setup_timezone
	setup_1password_cli
	setup_ssh_credentials
	setup_wireguard_client # DT-Dev specific (skips on Mac)

	install_zsh
	install_dotfiles_core
	install_dotfiles_desktop

	install_basic_utilities
	install_system_monitoring
	install_file_text_utilities
	install_system_info_utilities
	install_network_utilities
	install_python_base
	install_build_tools

	install_docker
	install_rust
	install_uv
	install_linters_formatters
	install_node
	install_java
	install_kotlin
	install_golang
	install_cloud_tools
	install_yazi
	install_playwright_cli
	install_nerd_fonts

	if [ "$OS" != "Darwin" ]; then
		install_desktop_env_linux
		setup_netplan
	else
		setup_macos_preferences
	fi

	install_desktop_apps
	install_gpu_ml_tools
	cleanup_all
}

# ==========================================
# MAIN EXECUTION
# ==========================================

if [ $# -eq 0 ]; then
	echo "Error: No machine type specified."
	echo "Usage: $0 {bm-hypervisor|vm-k8s-node|vm-dev-container|vm-service|dt-dev}"
	exit 1
fi

case "$1" in
"bm-hypervisor")
	profile_bm_hypervisor
	;;
"vm-k8s-node")
	profile_vm_k8s_node
	;;
"vm-dev-container")
	profile_vm_dev_container
	;;
"vm-service")
	profile_vm_service
	;;
"dt-dev")
	profile_dt_dev
	;;
*)
	echo "Error: Invalid machine type '$1'"
	echo "Usage: $0 {bm-hypervisor|vm-k8s-node|vm-dev-container|vm-service|dt-dev}"
	exit 1
	;;
esac
