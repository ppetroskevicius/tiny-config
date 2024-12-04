#!/usr/bin/env bash
set -euo pipefail
set -x

SECONDS=0
SOURCE_REPO="https://github.com/ppetroskevicius/tiny-config.git"
TARGET_DIR="$HOME/fun/tiny-config"
NETPLAN_CONFIG="/etc/netplan/50-cloud-init.yaml"

update_packages() {
  sudo apt update && sudo apt upgrade -y
}

setup_git() {
  GIT_USERNAME="ppetroskevicius"
  GIT_EMAIL="p.petroskevicius@gmail.com"
  sudo apt install -y git tmux htop vim unzip
  git config --global user.name "$GIT_USERNAME"
  git config --global user.email "$GIT_EMAIL"
}

install_1password_cli() {
  if ! command -v op > /dev/null; then
    curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg
    echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/amd64 stable main' | sudo tee /etc/apt/sources.list.d/1password.list
    sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/
    curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol
    sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22
    curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg
    sudo apt update && sudo apt install -y 1password-cli
  fi
}

setup_credentials() {
  OP_ACCOUNT="my"
  OP_SSH_KEY_NAME="op://build/my-ssh-key/id_ed25519"
  eval "$(op signin --account $OP_ACCOUNT)"
  mkdir -p ~/.ssh && chmod 700 ~/.ssh
  op read --out-file ~/.ssh/id_ed25519 $OP_SSH_KEY_NAME
  echo "Successfully retrieved SSH key."
  chmod 600 ~/.ssh/id_ed25519
  ssh-keygen -y -f ~/.ssh/id_ed25519 > ~/.ssh/id_ed25519.pub
  cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys
  chmod 600 ~/.ssh/authorized_keys
  ssh-keyscan github.com >> ~/.ssh/known_hosts
  systemctl --user enable --now ssh-agent.service
  eval "$(ssh-agent -s)"
  ssh-add ~/.ssh/id_ed25519
}

install_dotfiles() {
  if [ ! -d "$TARGET_DIR" ]; then
    git clone "$SOURCE_REPO" "$TARGET_DIR"
  fi
  cd "$TARGET_DIR"
  git switch dev
  mkdir -p "$HOME"/.config/
  rm -f "$HOME"/.bash_profile "$HOME"/.bashrc "$HOME"/.zprofile "$HOME"/.zshrc
  ln -sf "$TARGET_DIR"/.sshconfig "$HOME"/.ssh/config
  ln -sf "$TARGET_DIR"/.bash_profile "$HOME"
  ln -sf "$TARGET_DIR"/.bashrc "$HOME"
  ln -sf "$TARGET_DIR"/.zprofile "$HOME"
  ln -sf "$TARGET_DIR"/.zshrc "$HOME"
  ln -sf "$TARGET_DIR"/.tmux.conf "$HOME"
  ln -sf "$TARGET_DIR"/.vimrc "$HOME"
  ln -sf "$TARGET_DIR"/.gitconfig "$HOME"
  ln -sf "$TARGET_DIR"/.alacritty.toml "$HOME"
  ln -sf "$TARGET_DIR"/.xinitrc "$HOME"
  ln -sf "$TARGET_DIR"/.xinputrc "$HOME"
  ln -sf "$TARGET_DIR"/start_i3.sh "$HOME"
  ln -sf "$TARGET_DIR"/start_gnome.sh "$HOME"
  mkdir -p "$HOME"/.config/i3
  mkdir -p "$HOME"/.config/sway
  ln -sf "$TARGET_DIR"/.sway "$HOME"/.config/sway/config
  mkdir -p "$HOME"/.config/mako
  ln -sf "$TARGET_DIR"/.mako "$HOME"/.config/mako/config
  mkdir -p "$HOME"/.config/waybar
  ln -sf "$TARGET_DIR"/.waybar.jsonc "$HOME"/.config/waybar/config
  ln -sf "$TARGET_DIR"/.waybar_style.css "$HOME"/.config/waybar/style.css
  mkdir -p "$HOME"/.config/zed
  ln -sf "$TARGET_DIR"/zed/keymap.json "$HOME"/.config/zed/
  ln -sf "$TARGET_DIR"/zed/settings.json "$HOME"/.config/zed/
  rm -rf "$HOME"/.config/alacritty
  git clone https://github.com/alacritty/alacritty-theme "$HOME"/.config/alacritty/themes
}

setup_wifi_in_networkmanager() {
  if nmcli device status | grep -q "wifi"; then
    nmcli device wifi list
    OP_WIFI_SSID="op://build/wifi/ssid"
    OP_WIFI_PASS="op://build/wifi/pass"
    WIFI_SSID=$(op read "$OP_WIFI_SSID")
    export WIFI_SSID
    WIFI_PASS=$(op read "$OP_WIFI_PASS")
    export WIFI_PASS
    nmcli device wifi connect "$WIFI_SSID" password "$WIFI_PASS"
  fi
}

setup_wifi_in_netplan() {
  if ip link | grep -q "wl"; then
    OP_WIFI_SSID="op://build/wifi/ssid"
    OP_WIFI_PASS="op://build/wifi/pass"
    WIFI_SSID=$(op read "$OP_WIFI_SSID")
    WIFI_PASS=$(op read "$OP_WIFI_PASS")
    WIFI_INTERFACE=$(ip link | grep "wl" | awk '{print $2}' | sed 's/://')
    sudo tee "$NETPLAN_CONFIG" > /dev/null << EOL
network:
  version: 2
  renderer: networkd
  wifis:
    $WIFI_INTERFACE:
      dhcp4: true
      access-points:
        "$WIFI_SSID":
          password: "$WIFI_PASS"
EOL
    sudo netplan apply
  fi
}

setup_netplan() {
  RENDERER="$1"
  sudo apt install -y network-manager
  if [ "$RENDERER" == "networkd" ]; then
    if systemctl is-enabled --quiet NetworkManager; then
      sudo systemctl stop NetworkManager
    fi
    sudo systemctl disable NetworkManager
    sudo systemctl enable --now systemd-networkd
    sudo sed -i 's/renderer: NetworkManager/renderer: networkd/' "$NETPLAN_CONFIG"
    setup_wifi_in_netplan
    echo "Configured Netplan to use networkd."
  elif [ "$RENDERER" == "NetworkManager" ]; then
    if systemctl is-active --quiet systemd-networkd; then
      sudo systemctl stop systemd-networkd
    fi
    sudo systemctl restart wpa_supplicant
    sudo systemctl disable systemd-networkd
    sudo systemctl enable --now NetworkManager
    sudo sed -i 's/renderer: networkd/renderer: NetworkManager/' "$NETPLAN_CONFIG"
    echo "Configured Netplan to use NetworkManager."
    setup_wifi_in_networkmanager
  else
    echo "Invalid argument. Please specify either 'networkd' or 'NetworkManager'."
    return 1
  fi
  sudo netplan apply
  echo "Netplan configuration applied."
}

setup_bluetooth_audio() {
  echo "Setting up Bluetooth and audio..."
  sudo apt install -y bluez blueman bluetooth
  sudo apt install -y pulseaudio pulseaudio-module-bluetooth
  sudo systemctl enable --now bluetooth
  systemctl --user enable --now pulseaudio
  sudo apt install -y pavucontrol alsa-utils
  sudo apt install -y pactl playerctl
  echo "Setup complete! You can now configure Bluetooth devices and audio settings."
  echo "Use 'blueman-manager' (GUI) or 'bluetoothctl' (CLI) for managing Bluetooth devices."
  echo "For audio management:"
  echo "- Run 'pavucontrol' for a graphical audio control panel."
  echo "- Use 'alsamixer' to unmute and adjust hardware audio settings in the terminal."
}

setup_i3() {
  sudo apt install -y i3 i3status i3lock dmenu xinit polybar
}

setup_sway_wayland() {
  sudo apt install -y sway wayland-protocols waybar xwayland swayidle swaylock
}

build_waybar() {
  sudo apt remove waybar
  hash -r
  sudo apt install -y \
    cava \
    clang-tidy \
    gobject-introspection \
    libdbusmenu-gtk3-dev \
    libevdev-dev \
    libfmt-dev \
    libgirepository1.0-dev \
    libgtk-3-dev \
    libgtkmm-3.0-dev \
    libinput-dev \
    libjsoncpp-dev \
    libmpdclient-dev \
    libnl-3-dev \
    libnl-genl-3-dev \
    libpulse-dev \
    libsigc++-2.0-dev \
    libspdlog-dev \
    libwayland-dev \
    scdoc \
    upower \
    libxkbregistry-dev
  rm -rf /tmp/waybar
  git clone https://github.com/Alexays/Waybar /tmp/waybar
  cd /tmp/waybar
  meson setup build
  sudo ninja -C build install
  which -a waybar
  waybar --version
}

install_screenshots() {
  tempdir=$(mktemp -d)
  trap 'rm -rf $tempdir' EXIT
  git clone https://git.sr.ht/~whynothugo/shotman "$tempdir"
  cd "$tempdir"
  cargo build --release
  sudo make install
  sudo apt install -y slurp
}

install_notifications() {
  pkill dunst
  sudo apt remove dunst
  sudo apt install -y mako-notifier
}

install_nerd_font() {
  mkdir -p "$HOME"/.local/share/fonts
  rm -rf "$HOME"/.local/share/fonts/*
}

setup_timezone() {
  sudo timedatectl set-timezone Asia/Tokyo
  timedatectl
}

setup_japanese() {
  sudo wget https://www.ubuntulinux.jp/sources.list.d/noble.sources -O /etc/apt/sources.list.d/ubuntu-ja.sources
  sudo apt -U upgrade
  sudo apt install -y ubuntu-defaults-ja
  sudo apt install -y fcitx5 fcitx5-mozc fcitx5-config-qt
}

install_zsh() {
  sudo apt install -y zsh
  chsh -s /usr/bin/zsh
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi
  ZSH_AUTOSUGGESTIONS_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
  if [ ! -d "$ZSH_AUTOSUGGESTIONS_DIR" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_AUTOSUGGESTIONS_DIR"
  fi
}

setup_power() {
  sudo apt install -y tlp tlp-rdw
  sudo systemctl enable --now tlp
  sudo rm -f /etc/tlp.conf
  sudo ln -sf "$TARGET_DIR"/.tlp.conf /etc/tlp.conf
  tlp-stat -c
  tlp-stat --cdiff
}

setup_brightness() {
  sudo apt install brightnessctl
  sudo usermod -aG video "$USER"
}

remove_snap() {
  snap list
  sudo apt purge snapd
  sudo rm -rf /var/cache/snapd
  sudo rm -rf /snap
  echo -e "Package: snapd\nPin: release a=*\nPin-Priority: -10" | sudo tee /etc/apt/preferences.d/nosnap.pref
  sudo systemctl stop snapd.socket
  sudo systemctl stop snapd.service snapd.seeded.service
  sudo systemctl mask snapd.socket snapd.service snapd.seeded.service
}

install_other() {
  sudo apt install -y neofetch btop
}

install_kvm() {
  sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager virt-viewer
  sudo kvm-ok
  sudo usermod -aG libvirt "$(whoami)"
  newgrp libvirt
}

install_uv() {
  curl -LsSf https://astral.sh/uv/install.sh | sh
  source "$HOME"/.cargo/env
  uv self update
}

install_1password_app() {
  sudo apt install -y 1password
}

install_alacritty_app() {
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  . "$HOME/.cargo/env"
  rustup override set stable
  rustup update stable
  sudo apt install -y cmake g++ pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3
  tempdir=$(mktemp -d)
  trap 'rm -rf $tempdir' EXIT
  git clone https://github.com/alacritty/alacritty.git "$tempdir"
  cd "$tempdir"
  cargo install alacritty
  cd "$TARGET_DIR"
}

install_zed_app() {
  sudo apt install -y shellcheck shfmt
  curl -f https://zed.dev/install.sh | sh
}

install_chrome_app() {
  wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  sudo apt install -y fonts-liberation xdg-utils
  sudo dpkg -i ./google-chrome-stable_current_amd64.deb
  rm ./google-chrome-stable_current_amd64.deb
}

install_discord_app() {
  wget -O /tmp/discord.deb "https://discord.com/api/download?platform=linux&format=deb"
  sudo dpkg -i /tmp/discord.deb
  rm /tmp/discord.deb
}

install_spotify_app() {
  curl -sS https://download.spotify.com/debian/pubkey_6224F9941A8AA6D1.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
  echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
  sudo apt update && sudo apt install -y spotify-client
}

setup_server() {
  update_packages
  setup_git
  install_1password_cli
  setup_credentials
  install_dotfiles
  setup_timezone
}

setup_desktop() {
  setup_i3
  setup_bluetooth_audio
  setup_japanese
  install_zsh
  install_power_profiles
  setup_brightness
  remove_snap
}

setup_apps() {
  install_kvm
  install_uv
  install_1password_app
  install_alacritty_app
  install_zed_app
  install_chrome_app
  install_discord_app
  install_spotify_app
}

install_dotfiles
echo "[ ] completed in t=$SECONDS"
