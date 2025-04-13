#!/usr/bin/env bash
set -euo pipefail
set -x

OS=$(uname -s)
ARCH=$(uname -m)
SOURCE_REPO="https://github.com/ppetroskevicius/tiny-config.git"
TARGET_DIR="$HOME/fun/tiny-config"
OP_ACCOUNT="my"
OP_SSH_KEY_NAME="op://build/my-ssh-key/id_ed25519"
OP_WG_CONFIG_NAME="op://network/wireguard/conf"

setup_1password_cli() {
  if ! command -v op > /dev/null; then
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
    ssh-keygen -y -f ~/.ssh/id_ed25519 > ~/.ssh/id_ed25519.pub
    cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys
    chmod 600 ~/.ssh/authorized_keys
    ssh-keyscan github.com >> ~/.ssh/known_hosts 2> /dev/null
    systemctl --user enable --now ssh-agent.service 2> /dev/null || true
    eval "$(ssh-agent -s)" > /dev/null
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
  if ! command -v zsh > /dev/null; then
    if [ "$OS" = "Darwin" ]; then
      brew install zsh
    else
      sudo apt install -y zsh
    fi
  fi
  chsh -s "$(which zsh)"
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
  ln -sf "$TARGET_DIR/.pylintrc" "$HOME/.config/pylintrc"
  mkdir -p "$HOME/.aws"
  ln -sf "$TARGET_DIR/.aws_config" "$HOME/.aws/config"
}

setup_timezone() {
  if [ "$OS" = "Darwin" ]; then
    sudo systemsetup -settimezone Asia/Tokyo > /dev/null
  else
    sudo timedatectl set-timezone Asia/Tokyo
    timedatectl
  fi
}

install_node() {
  if ! command -v node > /dev/null; then
    if [ "$OS" = "Darwin" ]; then
      brew install node
    else
      sudo apt install -y nodejs npm
    fi
  fi
  if ! command -v n > /dev/null; then
    sudo npm install -g n
  fi
  sudo n 22.0.0 # aws-cdk supports <=22.0.0
}

install_aws_cli() {
  if ! command -v aws > /dev/null; then
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

    # Install AWS CDK
    sudo npm install -g aws-cdk
    cdk --version
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
    declare -a fonts=("0xProto" "FiraCode" "Hack" "Meslo" "AnonymousPro" "IntelOneMono")
    font_dir="$HOME/.local/share/fonts"
    mkdir -p "$font_dir"
    rm -rf "${font_dir:?}/*"
    version=$(curl -s "https://api.github.com/repos/ryanoasis/nerd-fonts/tags" | jq -r '.[0].name')
    for font in "${fonts[@]}"; do
      zip_file="$font.zip"
      download_url="https://github.com/ryanoasis/nerd-fonts/releases/download/${version}/${zip_file}"
      wget --quiet "$download_url" -O "$zip_file" || {
        echo "Failed to download $font"
        exit 1
      }
      unzip -qo "$zip_file" -d "$font_dir"
      rm "$zip_file"
    done
    if [ "$OS" = "Darwin" ]; then
      brew install fontconfig
    else
      # install Noto fonts for math symbols and so
      sudo apt install fonts-noto
      # fc-list | grep "Noto"
    fi
    fc-cache -fv > /dev/null
    # fc-list | grep "Nerd"
  fi
}

install_starship() {
  if ! command -v starship > /dev/null; then
    curl -sS https://starship.rs/install.sh | sh -s -- -y
  fi
}

install_docker() {
  if ! command -v docker > /dev/null; then
    if [ "$OS" = "Darwin" ]; then
      brew install --cask docker
    else
      sudo apt-get update
      sudo apt-get install -y ca-certificates curl
      sudo install -m 0755 -d /etc/apt/keyrings
      sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
      sudo chmod a+r /etc/apt/keyrings/docker.asc
      echo "deb [arch=$ARCH signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$UBUNTU_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
      sudo apt-get update
      sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    fi
  fi
}

install_alacritty_app() {
  if ! command -v alacritty > /dev/null; then
    if [ "$OS" = "Darwin" ]; then
      brew install alacritty
    else
      rustup override set stable
      rustup update stable
      sudo apt install -y cmake g++ pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev
      git clone https://github.com/alacritty/alacritty.git /tmp/alacritty
      cd /tmp/alacritty
      cargo install alacritty
      cd - > /dev/null
      rm -rf /tmp/alacritty
    fi
  fi
}

install_spotify_player() {
  if ! command -v spotify_player > /dev/null; then
    if [ "$OS" = "Darwin" ]; then
      brew install libssl-dev libasound2-dev libdbus-1-dev
    else
      sudo apt install -y libssl-dev libasound2-dev libdbus-1-dev
    fi
    cargo install spotify_player --locked
  fi
}
