#!/usr/bin/env bash
set -euo pipefail
set -x

NETPLAN_CONFIG="/etc/netplan/50-cloud-init.yaml"
OP_WIFI_SSID="op://network/wifi/ssid"
OP_WIFI_PASS="op://network/wifi/pass"
tempdir=$(mktemp -d)
trap 'rm -rf "$tempdir"' EXIT

install_packages_common() {
  dpkg -l vim tmux git > /dev/null 2>&1 \
    || sudo apt install -y vim tmux git keychain htop unzip netcat-openbsd
}

install_packages_host() {
  dpkg -l zfsutils-linux > /dev/null 2>&1 \
    || sudo apt install -y zfsutils-linux nfs-kernel-server nfs-common mdadm fio nvme-cli pciutils
}

install_packages_guest() {
  dpkg -l nfs-common build-essential > /dev/null 2>&1 \
    || sudo apt install -y nfs-common bash-completion locales direnv btop nvtop neofetch lm-sensors \
      build-essential clang csvtool fd-find file infiniband-diags ipmitool jc jq lshw lsof \
      man-db parallel rclone rdma-core ripgrep rsync systemd-journal-remote time \
      python-is-python3 python3 python3-pip python3-venv avahi-daemon
}

install_github_cli() {
  # Install GitHub CLI using the official repository if not already installed
  if ! command -v gh > /dev/null; then
    (type -p wget > /dev/null || (sudo apt update && sudo apt-get install wget -y)) \
      && sudo mkdir -p -m 755 /etc/apt/keyrings \
      && out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      && cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
      && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
      && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
      && sudo apt update \
      && sudo apt install gh -y
  fi
}

setup_wifi_in_netplan() {
  if ip link | grep -q "wl"; then
    WIFI_SSID=$(op read "$OP_WIFI_SSID")
    WIFI_PASS=$(op read "$OP_WIFI_PASS")
    WIFI_INTERFACE=$(ip link | grep "wl" | awk '{print $2}' | sed 's/://')
  fi

  # Get all Ethernet interfaces (including USB adapters)
  ETHERNET_INTERFACES=$(ip link | grep -E "en|eth" | awk '{print $2}' | sed 's/://' | tr '\n' ' ')

  # Start building the netplan configuration
  CONFIG="network:\n  version: 2\n  renderer: networkd\n"

  # Add WiFi configuration if interface exists
  if [ -n "${WIFI_INTERFACE:-}" ]; then
    CONFIG="${CONFIG}  wifis:\n    ${WIFI_INTERFACE}:\n      dhcp4: true\n      dhcp6: true\n      access-points:\n        \"${WIFI_SSID:-}\":\n          password: \"${WIFI_PASS:-}\"\n"
  fi

  # Add Ethernet configuration for all detected interfaces
  CONFIG="${CONFIG}  ethernets:\n"
  for iface in $ETHERNET_INTERFACES; do
    CONFIG="${CONFIG}    ${iface}:\n      dhcp4: true\n      dhcp6: true\n      optional: true\n"
  done

  # Write the configuration
  echo -e "$CONFIG" | sudo tee "$NETPLAN_CONFIG" > /dev/null

  sudo netplan apply
}

setup_netplan() {
  if systemctl is-enabled --quiet NetworkManager; then
    sudo systemctl stop NetworkManager
    sudo systemctl disable NetworkManager
  fi
  sudo systemctl enable --now systemd-networkd
  sudo sed -i 's/renderer: NetworkManager/renderer: networkd/' "$NETPLAN_CONFIG"
  setup_wifi_in_netplan
  sudo netplan apply
}

install_wireguard() {
  dpkg -l wireguard > /dev/null 2>&1 \
    || sudo apt install -y wireguard
  umask 077
}

setup_bluetooth_audio() {
  dpkg -l bluez pulseaudio > /dev/null 2>&1 \
    || sudo apt install -y bluez blueman bluetooth pulseaudio pulseaudio-module-bluetooth pavucontrol alsa-utils playerctl
  sudo systemctl enable --now bluetooth
  systemctl --user enable --now pulseaudio
}

setup_sway_wayland() {
  dpkg -l sway > /dev/null 2>&1 \
    || sudo apt install -y sway wayland-protocols xwayland swayidle swaylock swayimg
}

install_i3status-rs() {
  if ! [ -f "$HOME/.cargo/bin/i3status-rs" ]; then
    sudo apt install -y libssl-dev libsensors-dev libpulse-dev libnotmuch-dev pandoc
    git clone https://github.com/greshake/i3status-rust "$tempdir/i3status-rust"
    cd "$tempdir/i3status-rust"
    cargo install --path . --locked
    ./install.sh
    cd - > /dev/null
  fi
}

install_screenshots() {
  if ! command -v shotman > /dev/null; then
    sudo apt install -y slurp scdoc
    git clone https://git.sr.ht/~whynothugo/shotman "$tempdir/shotman"
    cd "$tempdir/shotman"
    cargo build --release
    sudo make install
    cd - > /dev/null

    # install oculante for image editing (compiling takes time)
    sudo apt-get install libxcb-shape0-dev libxcb-xfixes0-dev libgtk-3-dev libasound2-dev nasm cmake
    # migth require nightly release
    rustup install nightly
    rustup default nightly

    cargo install oculante
  fi
}

install_notifications() {
  pkill dunst || true
  dpkg -l dunst > /dev/null 2>&1 && sudo apt purge -y dunst
  dpkg -l mako-notifier > /dev/null 2>&1 \
    || sudo apt install -y mako-notifier
}

install_kickoff() {
  if ! command -v kickoff > /dev/null; then
    cargo install kickoff
  fi
}

setup_power_management() {
  dpkg -l tlp > /dev/null 2>&1 \
    || sudo apt install -y tlp tlp-rdw
  sudo systemctl enable --now tlp
  sudo rm -f /etc/tlp.conf
  sudo ln -sf "$HOME/fun/tiny-config/.tlp.conf" /etc/tlp.conf
  tlp-stat -c
}

setup_brightness() {
  dpkg -l brightnessctl > /dev/null 2>&1 \
    || sudo apt install -y brightnessctl
  sudo usermod -aG video "$USER"
}

setup_gamma() {
  if ! command -v wl-gammarelay-rs > /dev/null; then
    cargo install wl-gammarelay-rs --locked
  fi
}

setup_japanese() {
  dpkg -l fcitx5 > /dev/null 2>&1 \
    || sudo apt install -y fcitx5 fcitx5-mozc fcitx5-configtool
  im-config -n fcitx5
  sudo add-apt-repository -y ppa:ikuya-fruitsbasket/sway
  sudo apt upgrade -y
}

remove_snap() {
  if command -v snap > /dev/null; then
    snap list || true
    sudo apt purge -y snapd
    sudo rm -rf /var/cache/snapd /snap
    echo -e "Package: snapd\nPin: release a=*\nPin-Priority: -10" | sudo tee /etc/apt/preferences.d/nosnap.pref
    sudo systemctl stop snapd.socket snapd.service snapd.seeded.service || true
    sudo systemctl mask snapd.socket snapd.service snapd.seeded.service
  fi
}

install_remote_desktop() {
  dpkg -l remmina > /dev/null 2>&1 \
    || sudo apt install -y remmina
}

install_llvm_mlir() {
  dpkg -l cmake clang > /dev/null 2>&1 \
    || sudo apt install -y cmake ninja-build python3 python3-pip g++ zlib1g-dev libedit-dev libxml2-dev clang llvm lldb lld
}

install_nvidia_gpu() {
  if ! dpkg -l nvidia-driver-550 > /dev/null 2>&1; then
    sudo apt install -y nvidia-driver-550
    echo "NVIDIA driver installed. Reboot required."
  fi
}

install_1password_app() {
  dpkg -l 1password > /dev/null 2>&1 \
    || sudo apt install -y 1password
}

install_zed_app() {
  if ! command -v zed > /dev/null; then
    curl -f https://zed.dev/install.sh | sh
  fi
}

install_windsurf_app() {
  if ! dpkg -l windsurf > /dev/null 2>&1; then
    curl -fsSL "https://windsurf-stable.codeiumdata.com/wVxQEIWkwPUEAGf3/windsurf.gpg" | sudo gpg --dearmor -o /usr/share/keyrings/windsurf-stable-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/windsurf-stable-archive-keyring.gpg arch=amd64] https://windsurf-stable.codeiumdata.com/wVxQEIWkwPUEAGf3/apt stable main" | sudo tee /etc/apt/sources.list.d/windsurf.list > /dev/null
    sudo apt update
    sudo apt install -y windsurf
  fi
}

install_chrome_app() {
  if ! command -v google-chrome > /dev/null; then
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/chrome.deb
    sudo apt install -y fonts-liberation xdg-utils
    sudo dpkg -i /tmp/chrome.deb
    rm /tmp/chrome.deb
  fi
}

install_discord_app() {
  if ! command -v discord > /dev/null; then
    wget -O /tmp/discord.deb "https://discord.com/api/download?platform=linux&format=deb"
    sudo dpkg -i /tmp/discord.deb
    rm /tmp/discord.deb
  fi
}

install_zotero_app() {
  if ! dpkg -l zotero > /dev/null 2>&1; then
    wget -qO- https://raw.githubusercontent.com/retorquere/zotero-deb/master/install.sh | sudo bash
    sudo apt update
    sudo apt install -y zotero
  fi
}

install_spotify_app() {
  if ! dpkg -l spotify-client > /dev/null 2>&1; then
    curl -sS https://download.spotify.com/debian/pubkey_C85668DF69375001.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
    echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
    sudo apt update && sudo apt install -y spotify-client
  fi
}

setup_raid() {
  if [ -b /dev/md0 ]; then
    echo "RAID array /dev/md0 found, skipping creation..."
  else
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
}

setup_server_host() {
  install_packages_host
}

setup_server_guest() {
  install_packages_guest
  install_github_cli
}

setup_desktop() {
  setup_netplan
  install_wireguard
  setup_bluetooth_audio
  setup_sway_wayland
  install_i3status-rs
  install_screenshots
  install_notifications
  install_kickoff
  setup_power_management
  setup_brightness
  setup_gamma
  setup_japanese
  remove_snap
}

setup_apps() {
  install_1password_app
  install_zed_app
  install_chrome_app
  install_discord_app
  install_zotero_app
  install_spotify_app
}

require_reboot() {
  install_nvidia_gpu
}
