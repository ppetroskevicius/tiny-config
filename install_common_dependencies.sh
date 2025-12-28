#!/usr/bin/env bash
set -euo pipefail
set -x

OS=$(uname -s)
SOURCE_REPO="https://github.com/ppetroskevicius/tiny-config.git"
TARGET_DIR="$HOME/fun/tiny-config"
OP_ACCOUNT="my"
OP_SSH_KEY_NAME="op://build/my-ssh-key/id_ed25519"
OP_WG_CONFIG_NAME="op://network/wireguard/conf"

setup_1password_cli() {
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
	eval "$(op signin --account $OP_ACCOUNT)"
}

setup_credentials() {
	if ! [ -f "$HOME/.ssh/id_ed25519" ]; then
		mkdir -p ~/.ssh && chmod 700 ~/.ssh
		op read -f --out-file ~/.ssh/id_ed25519 "$OP_SSH_KEY_NAME"
		chmod 600 ~/.ssh/id_ed25519
		ssh-keygen -y -f ~/.ssh/id_ed25519 >~/.ssh/id_ed25519.pub
		cat ~/.ssh/id_ed25519.pub >>~/.ssh/authorized_keys
		chmod 600 ~/.ssh/authorized_keys
		ssh-keyscan github.com >>~/.ssh/known_hosts 2>/dev/null
		systemctl --user enable --now ssh-agent.service 2>/dev/null || true
		eval "$(ssh-agent -s)" >/dev/null
		ssh-add ~/.ssh/id_ed25519
	fi
	# Wireguard is Ubuntu-specific
	if [ "$OS" != "Darwin" ] && ! [ -f "/etc/wireguard/gw0.conf" ]; then
		sudo mkdir -p /etc/wireguard
		op read -f --out-file /tmp/gw0.conf "$OP_WG_CONFIG_NAME"
		sudo mv /tmp/gw0.conf /etc/wireguard/
		sudo chmod 600 /etc/wireguard/gw0.conf
		sudo chown root: /etc/wireguard/gw0.conf
	fi
}

install_zsh() {
	if ! command -v zsh >/dev/null; then
		if [ "$OS" = "Darwin" ]; then
			brew install zsh
			chsh -s "$(which zsh)"
		else
			sudo apt install -y zsh
			chsh -s /usr/bin/zsh
		fi
	fi
	if [ ! -d "$HOME/.oh-my-zsh" ]; then
		git clone https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
		git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
	fi
}

install_dotfiles() {
	if [ ! -d "$TARGET_DIR" ]; then
		git clone "$SOURCE_REPO" "$TARGET_DIR"
	fi
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
	ln -sf "$TARGET_DIR/.alacritty.toml" "$HOME"
	ln -sf "$TARGET_DIR/.starship.toml" "$HOME/.config/starship.toml"
	# Ubuntu-specific dotfiles
	if [ "$OS" != "Darwin" ]; then
		mkdir -p "$HOME/.config/sway" "$HOME/.config/mako" "$HOME/.config/i3status-rust"
		ln -sf "$TARGET_DIR/.sway" "$HOME/.config/sway/config"
		ln -sf "$TARGET_DIR/.mako" "$HOME/.config/mako/config"
		ln -sf "$TARGET_DIR/.i3status-rust.toml" "$HOME/.config/i3status-rust/config.toml"
	fi
	rm -rf "$HOME/.config/alacritty"
	git clone https://github.com/alacritty/alacritty-theme "$HOME/.config/alacritty/themes"
	mkdir -p "$HOME/.config/ruff" "$HOME/.config/zed"
	ln -sf "$TARGET_DIR/.ruff.toml" "$HOME/.config/ruff/ruff.toml"
	ln -sf "$TARGET_DIR/zed/keymap.json" "$HOME/.config/zed/"
	ln -sf "$TARGET_DIR/zed/settings.json" "$HOME/.config/zed/"

	# Setup Cursor configuration
	mkdir -p "$HOME/.cursor"
	ln -sf "$TARGET_DIR/.cursor_mcp.json" "$HOME/.cursor/mcp.json"
	# Setup Cursor settings.json symlink
	if [ "$OS" = "Darwin" ]; then
		mkdir -p "$HOME/Library/Application Support/Cursor/User"
		ln -sf "$TARGET_DIR/.vscode/settings.json" "$HOME/Library/Application Support/Cursor/User/settings.json"
	else
		mkdir -p "$HOME/.config/Cursor/User"
		ln -sf "$TARGET_DIR/.vscode/settings.json" "$HOME/.config/Cursor/User/settings.json"
	fi

	# Setup MCP configuration
	mkdir -p "$HOME/.codeium/windsurf"
	ln -sf "$TARGET_DIR/.mcp_config.json" "$HOME/.codeium/windsurf/mcp_config.json"

	# Setup other configurations
	ln -sf "$TARGET_DIR/.pylintrc" "$HOME/.config/pylintrc"
	mkdir -p "$HOME/.aws"
	ln -sf "$TARGET_DIR/.aws_config" "$HOME/.aws/config"
}

setup_timezone() {
	if [ "$OS" = "Darwin" ]; then
		sudo systemsetup -settimezone Asia/Tokyo >/dev/null
	else
		sudo timedatectl set-timezone Asia/Tokyo
		timedatectl
	fi
}

install_node() {
	# Install Node via nvm
	# https://nodejs.org/en/download/
	if ! command -v nvm >/dev/null; then
		curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
	fi

	# in lieu of restarting the shell
	. "$HOME/.nvm/nvm.sh"

	# Download and install Node.js:
	nvm install --lts

	# Verify the Node.js version:
	node -v # Should print "v24.11.1".

	# Install pnpm package manager using standalone installer
	# https://pnpm.io/installation
	# Note: PATH configuration is handled in .zshrc/.bashrc dotfiles
	if ! command -v pnpm >/dev/null; then
		curl -fsSL https://get.pnpm.io/install.sh | sh -
		# Verify pnpm installation
		pnpm -v
	fi

	# Install Playwright CLI and browsers
	install_playwright_cli

}

# Install Playwright CLI and browsers for frontend testing
install_playwright_cli() {
	# Install Playwright browser libraries on Ubuntu
	if [ "$(uname -s)" != "Darwin" ]; then
		if ! dpkg -s libwoff1 >/dev/null 2>&1; then
			sudo apt-get update
			sudo apt-get install -y \
				libwoff1 \
				libevent-2.1-7 \
				libsecret-1-0 \
				libhyphen0 \
				libmanette-0.2-0
		fi
	fi
	if ! command -v playwright >/dev/null; then
		pnpm add -g playwright
		# Install browsers in user scope
		playwright install chromium firefox webkit || true
	fi
}

install_claude_code_app() {
	if ! command -v claude >/dev/null; then
		# Install Claude Code using pnpm
		pnpm add -g @anthropic-ai/claude-code
	fi
}

install_aws_cli() {
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
		aws --version

		# Install AWS CDK in user directory
		pnpm add -g aws-cdk
		cdk --version
	fi
}

install_gcp_cli() {
	if ! command -v gcloud >/dev/null; then
		if [ "$OS" = "Darwin" ]; then
			brew install --cask google-cloud-sdk
		else
			sudo apt-get update
			sudo apt-get install -y apt-transport-https ca-certificates gnupg curl
			echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" |
				sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list >/dev/null
			curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg |
				sudo gpg --dearmor --yes -o /usr/share/keyrings/cloud.google.gpg
			sudo apt-get update && sudo apt-get install -y google-cloud-cli
		fi
		gcloud --version
	fi
}

install_firebase_cli() {
	if ! command -v firebase >/dev/null || ! firebase --version >/dev/null 2>&1; then
		# Remove any broken installation first
		if [ -f "/usr/local/bin/firebase" ]; then
			sudo rm -f /usr/local/bin/firebase
		fi

		# Install Firebase CLI using pnpm
		# Note: PATH configuration is handled in .zshrc/.bashrc dotfiles
		if command -v pnpm >/dev/null; then
			pnpm add -g firebase-tools
		else
			echo "pnpm not found. Please install Node.js and pnpm first."
			return 1
		fi

		# Verify the installation works
		if command -v firebase >/dev/null && firebase --version >/dev/null 2>&1; then
			firebase --version
		else
			echo "Firebase CLI installation failed. Please check the installation manually."
			return 1
		fi
	fi
}

install_terraform_cli() {
	if ! command -v terraform >/dev/null; then
		if [ "$OS" = "Darwin" ]; then
			brew tap hashicorp/tap
			brew install hashicorp/tap/terraform
		else
			wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
			echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
			sudo apt update && sudo apt install terraform
		fi
		terraform -version
	fi
}

install_rust() {
	if ! [ -f "$HOME/.cargo/bin/cargo" ]; then
		curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
		source "$HOME/.cargo/env"
	fi
}

install_nerd_fonts() {
	if ! fc-list | grep -q "Nerd"; then
		if [ "$OS" = "Darwin" ]; then
			brew install --cask font-fira-code-nerd-font font-jetbrains-mono-nerd-font font-meslo-lg-nerd-font
			brew install fontconfig
		else
			declare -a fonts=("0xProto" "FiraCode" "Hack" "Meslo" "AnonymousPro" "IntelOneMono")
			font_dir="$HOME/.local/share/fonts"
			mkdir -p "$font_dir"
			rm -rf "${font_dir:?}/*"
			version=$(curl -s "https://api.github.com/repos/ryanoasis/nerd-fonts/tags" | jq -r '.[0].name')
			for font in "${fonts[@]}"; do
				zip_file="$font.zip"
				download_url="https://github.com/ryanoasis/nerd-fonts/releases/download/${version}/${zip_file}"
				wget --quiet "$download_url" -O "$zip_file"
				unzip -qo "$zip_file" -d "$font_dir"
				rm "$zip_file"
			done
			# install Noto fonts for math symbols and so
			sudo apt install -y fonts-noto
		# fc-list | grep "Noto"
		fi
		fc-cache -fv >/dev/null
		# fc-list | grep "Nerd"
	fi
}

install_java() {
	if command -v java >/dev/null; then
		return 0
	fi

	if [ "$OS" = "Darwin" ]; then
		# Install latest OpenJDK via Homebrew
		brew install openjdk
		# Ensure Java binaries are on PATH for immediate use
		sudo ln -sfn $(brew --prefix)/opt/openjdk/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk || true
		export PATH="$(brew --prefix)/opt/openjdk/bin:$PATH"
	else
		# Use default-jdk meta-package to allow easy version switching later
		sudo apt install -y default-jdk
	fi

	java -version
}

install_starship() {
	if ! command -v starship >/dev/null; then
		curl -sS https://starship.rs/install.sh | sh -s -- -y
	fi
}

install_docker() {
	if ! command -v docker >/dev/null; then
		if [ "$OS" = "Darwin" ]; then
			brew install --cask docker
		else
			# https://docs.docker.com/engine/install/ubuntu/
			# Add Docker's official GPG key:
			sudo apt-get update
			sudo apt-get install ca-certificates curl
			sudo install -m 0755 -d /etc/apt/keyrings
			sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
			sudo chmod a+r /etc/apt/keyrings/docker.asc

			# Add the repository to Apt sources:
			echo \
				"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" |
				sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
			sudo apt update

			sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

			# to run docker without root privileges
			sudo groupadd docker
			sudo usermod -aG docker $USER
			newgrp docker
			sudo docker run hello-world

			sudo systemctl enable docker
			sudo systemctl start docker
		fi
	fi
}

install_podman() {
	if ! command -v podman >/dev/null; then
		if [ "$OS" = "Darwin" ]; then
			brew install podman
		else
			# https://podman.io/docs/installation
			sudo apt update
			sudo apt -y install podman

			sudo apt install -y uidmap
			sudo usermod --add-subuids 100000-165536 --add-subgids 100000-165536 $USER

			sudo systemctl enable podman
			sudo systemctl start podman

			# Test installation
			podman --version
			podman info --debug
			podman run hello-world
		fi
	fi
}

install_ollama() {
	if ! command -v ollama >/dev/null; then
		if [ "$OS" = "Darwin" ]; then
			brew install ollama
		else
			curl -fsSL https://ollama.com/install.sh | sh
			sudo systemctl status ollama
			sudo systemctl stop ollama
			mkdir -p /mnt/raid0/ollama_models
			mv /home/fastctl/.ollama/models /mnt/raid0/ollama_models
			ln -s /mnt/raid0/ollama_models /home/fastctl/.ollama/models
			sudo systemctl start ollama
		fi
	fi
	ollama --version
}

install_alacritty_app() {
	if ! command -v alacritty >/dev/null; then
		if [ "$OS" = "Darwin" ]; then
			brew install alacritty
		else
			rustup override set stable
			rustup update stable
			sudo apt install -y cmake g++ pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev
			git clone https://github.com/alacritty/alacritty.git /tmp/alacritty
			cd /tmp/alacritty
			cargo install alacritty
			cd - >/dev/null
			rm -rf /tmp/alacritty
		fi
	fi
}

install_spotify_player() {
	if ! command -v spotify_player >/dev/null; then
		if [ "$OS" = "Darwin" ]; then
			brew install libssl-dev libasound2-dev libdbus-1-dev
		else
			sudo apt install -y libssl-dev libasound2-dev libdbus-1-dev
		fi
		cargo install spotify_player --locked
	fi
}

install_yazi() {
	if ! command -v yazi >/dev/null; then
		if [ "$OS" = "Darwin" ]; then
			# macOS: Install via Homebrew with optional dependencies
			brew install yazi ffmpeg sevenzip jq poppler fd ripgrep fzf zoxide resvg imagemagick font-symbols-only-nerd-font
		else
			# Ubuntu: Install system dependencies first
			sudo apt install -y ffmpeg p7zip jq poppler-utils fd-find ripgrep fzf zoxide imagemagick
			# Install yazi-build which installs yazi-fm and yazi-cli
			cargo install --force yazi-build
		fi
	fi
}
