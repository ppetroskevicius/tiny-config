#!/usr/bin/env bash
set -euo pipefail
set -x

SECONDS=0
SOURCE_REPO="https://github.com/ppetroskevicius/tiny-config.git"
TARGET_DIR="$HOME/fun/tiny-config"
NETPLAN_CONFIG="/etc/netplan/50-cloud-init.yaml"
OP_ACCOUNT="my"
OP_SSH_KEY_NAME="op://build/my-ssh-key/id_ed25519"
OP_WIFI_SSID="op://network/wifi/ssid"
OP_WIFI_PASS="op://network/wifi/pass"
OP_OPENVPN_CONFIG_NAME="op://network/openvpn/conf"

tempdir=$(mktemp -d)
trap 'rm -rf $tempdir' EXIT

update_packages() {
  sudo apt update && sudo apt upgrade -y
}

setup_git() {
  sudo apt install -y git vim tmux htop unzip jq keychain
}

setup_1password_cli() {
  if ! command -v op > /dev/null; then
    # install
    curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg
    echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/amd64 stable main' | sudo tee /etc/apt/sources.list.d/1password.list
    sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/
    curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol
    sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22
    curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg
    sudo apt update && sudo apt install -y 1password-cli
  else
    # login
    eval "$(op signin --account $OP_ACCOUNT)"
  fi
}

setup_credentials() {
  if ! [ -f "$HOME/.ssh/id_ed25519" ]; then
    mkdir -p ~/.ssh && chmod 700 ~/.ssh
    op read -f --out-file ~/.ssh/id_ed25519 $OP_SSH_KEY_NAME
    chmod 600 ~/.ssh/id_ed25519
    ssh-keygen -y -f ~/.ssh/id_ed25519 > ~/.ssh/id_ed25519.pub
    cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys
    chmod 600 ~/.ssh/authorized_keys
    ssh-keyscan github.com >> ~/.ssh/known_hosts
    systemctl --user enable --now ssh-agent.service
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_ed25519
  fi

  if ! [ -f "/etc/openvpn/client.conf" ]; then
    sudo mkdir -p /etc/openvpn
    op read -f --out-file /tmp/openvpn.ovpn "$OP_OPENVPN_CONFIG_NAME"
    sudo mv /tmp/openvpn.ovpn /etc/openvpn/client/client.conf
    sudo chmod 600 /etc/openvpn/client.conf
  fi
}

install_dotfiles() {
  if [ ! -d "$TARGET_DIR" ]; then
    git clone "$SOURCE_REPO" "$TARGET_DIR"
  fi
  cd "$TARGET_DIR"

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

  ln -sf "$TARGET_DIR"/.starship.toml "$HOME"/.config/starship.toml

  mkdir -p "$HOME"/.config/sway
  ln -sf "$TARGET_DIR"/.sway "$HOME"/.config/sway/config

  mkdir -p "$HOME"/.config/mako
  ln -sf "$TARGET_DIR"/.mako "$HOME"/.config/mako/config

  mkdir -p "$HOME"/.config/i3status-rust
  ln -sf "$TARGET_DIR"/.i3status-rust.toml "$HOME"/.config/i3status-rust/config.toml

  mkdir -p "$HOME"/.config/zed
  ln -sf "$TARGET_DIR"/zed/keymap.json "$HOME"/.config/zed/
  ln -sf "$TARGET_DIR"/zed/settings.json "$HOME"/.config/zed/

  rm -rf "$HOME"/.config/alacritty
  git clone https://github.com/alacritty/alacritty-theme "$HOME"/.config/alacritty/themes

  mkdir -p "$HOME"/.config/ruff
  ln -sf "$TARGET_DIR"/.ruff.toml "$HOME"/.config/ruff/ruff.toml

  ln -sf "$TARGET_DIR"/.pylintrc "$HOME"/.config/pylintrc

  mkdir -p "$HOME"/.aws
  ln -sf "$TARGET_DIR"/.aws_config "$HOME"/.aws/config
}

setup_wifi_in_networkmanager() {
  if nmcli device status | grep -q "wifi"; then
    nmcli device wifi list
    WIFI_SSID=$(op read "$OP_WIFI_SSID")
    export WIFI_SSID
    WIFI_PASS=$(op read "$OP_WIFI_PASS")
    export WIFI_PASS
    nmcli device wifi connect "$WIFI_SSID" password "$WIFI_PASS"
  fi
}

setup_wifi_in_netplan() {
  if ip link | grep -q "wl"; then
    WIFI_SSID=$(op read "$OP_WIFI_SSID")
    WIFI_PASS=$(op read "$OP_WIFI_PASS")
    WIFI_INTERFACE=$(ip link | grep "wl" | awk '{print $2}' | sed 's/://')
  fi

  if ip link | grep -q "en"; then
    ETHERNET_INTERFACE=$(ip link | grep "en" | awk '{print $2}' | grep "en" | sed 's/://')
  fi

  sudo tee "$NETPLAN_CONFIG" > /dev/null << EOL
network:
  version: 2
  renderer: networkd
  wifis:
    ${WIFI_INTERFACE:-""}:
      dhcp4: true
      dhcp6: true
      access-points:
        "${WIFI_SSID:-""}":
          password: "${WIFI_PASS:-""}"
  ethernets:
    ${ETHERNET_INTERFACE:-""}:
      dhcp4: true
      dhcp6: true
EOL

  sudo netplan apply
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

setup_openvpn() {
  sudo apt install -y openvpn

}

setup_timezone() {
  sudo timedatectl set-timezone Asia/Tokyo
  timedatectl
}

install_python3() {
  sudo apt install -y python3
}

install_node() {
  sudo apt install -y nodejs npm
  sudo npm install -g n
  # sudo n latest
  sudo n 22.0.0 # aws-cdk supports <=22.0.0
}

install_aws_cli() {
  # https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
  # install AWS CLI
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install
  aws --version
  rm -rf awscliv2.zip aws
  # install CDK
  sudo npm install -g aws-cdk
  cdk --version
}

install_rust() {
  if ! [ -f "$HOME/.cargo/bin/cargo" ]; then
    # curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    # curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
  fi
}

setup_bluetooth_audio() {
  sudo apt install -y bluez blueman bluetooth
  sudo apt install -y pulseaudio pulseaudio-module-bluetooth
  sudo systemctl enable --now bluetooth
  systemctl --user enable --now pulseaudio
  sudo apt install -y pavucontrol alsa-utils
  sudo apt install -y playerctl
  echo "Setup complete! You can now configure Bluetooth devices and audio settings."
  echo "Use 'blueman-manager' (GUI) or 'bluetoothctl' (CLI) for managing Bluetooth devices."
  echo "For audio management:"
  echo "- Run 'pavucontrol' for a graphical audio control panel."
  echo "- Use 'alsamixer' to unmute and adjust hardware audio settings in the terminal."
}

setup_sway_wayland() {
  sudo apt install -y sway wayland-protocols xwayland swayidle swaylock
}

install_i3status-rs() {
  # https://greshake.github.io/i3status-rust/i3status_rs/blocks/index.html
  if ! [ -f "$HOME/.cargo/bin/i3status-rs" ]; then
    sudo apt install -y libssl-dev libsensors-dev libpulse-dev libnotmuch-dev pandoc
    git clone https://github.com/greshake/i3status-rust "$tempdir/i3status-rust"
    cd "$tempdir/i3status-rust"
    cargo install --path . --locked
    ./install.sh
  fi
}

install_screenshots() {
  if ! command -v shotman > /dev/null; then
    sudo apt install -y slurp scdoc
    git clone https://git.sr.ht/~whynothugo/shotman "$tempdir/shotman"
    cd "$tempdir/shotman"
    cargo build --release
    sudo make install
  fi
}

install_notifications() {
  pkill dunst || true
  sudo apt purge dunst
  sudo apt install -y mako-notifier
}

install_kickoff() {
  # dmenu did not display properly with nvidia drivers
  cargo install kickoff
}

setup_power_management() {
  sudo apt install -y tlp tlp-rdw
  sudo systemctl enable --now tlp
  sudo rm -f /etc/tlp.conf
  sudo ln -sf "$TARGET_DIR"/.tlp.conf /etc/tlp.conf
  tlp-stat -c
  tlp-stat --cdiff
}

setup_brightness() {
  sudo apt install -y brightnessctl
  sudo usermod -aG video "$USER"
}

setup_gamma() {
  cargo install wl-gammarelay-rs --locked
}

install_nerd_fonts() {
  # https://github.com/ryanoasis/nerd-fonts

  declare -a fonts=("0xProto" "FiraCode" "Hack" "Meslo" "AnonymousPro" "IntelOneMono")
  font_dir="${HOME}/.local/share/fonts"
  mkdir -p "$font_dir"
  rm -rf "${font_dir}*"
  version=$(curl -s "https://api.github.com/repos/ryanoasis/nerd-fonts/tags" | jq -r '.[0].name')

  for font in "${fonts[@]}"; do
    zip_file="$font.zip"
    download_url="https://github.com/ryanoasis/nerd-fonts/releases/download/${version}/${zip_file}"
    wget --quiet "$download_url" -O "$zip_file"
    unzip -qo "$zip_file" -d "$font_dir"
    rm "$zip_file"
    echo "'$font' installed successfully."
  done

  fc-cache -fv
  # fc-list | grep "Nerd"

  # install Noto fonts for math symbols and so
  sudo apt install fonts-noto
  # fc-list | grep "Noto"
}

setup_japanese() {
  # According to the official Fcitx5 documentation (https://fcitx-im.org/wiki/Fcitx_5) we should be:
  # 1. Install:
  #    `fcitx5` - main program
  #    `fcitx5-configtool` - the GUI configuration program
  #    `fcitx5-mozc` - the input method engine for Japanese
  # 2. Configure:
  #    Run: `fcitx5-configtool`, search for `Mozc` and add it.
  # 3. Diagnose (if any issues):
  #    Run: `fcitx5-diagnose`
  #
  # https://gihyo.jp/admin/serial/01/ubuntu-recipe/0689
  # (https://gihyo.jp/admin/serial/01/ubuntu-recipe/0794)
  #
  # Sway supports Wayland text-input-v3, but google-chrome only supports wayland text-input-v1 in the Wayland mode:
  #    (https://fcitx-im.org/wiki/Using_Fcitx_5_on_Wayland#Chromium_.2F_Electron)
  # Google Chrome Japanese input only works when google-chrome is run in X11 mode for now.
  #    (this patch might be fixing it: https://github.com/swaywm/sway/pull/7226)

  sudo apt install -y fcitx5 fcitx5-mozc fcitx5-configtool
  im-config -n fcitx5 # switch default input method (IM) for Japanese to fcitx5

  # Patch sway, as in: https://gihyo.jp/admin/serial/01/ubuntu-recipe/0794
  sudo add-apt-repository ppa:ikuya-fruitsbasket/sway
  sudo apt upgrade -y
}

remove_snap() {
  if command -v snap > /dev/null; then
    snap list || true
    sudo apt purge -y snapd
    sudo rm -rf /var/cache/snapd
    sudo rm -rf /snap
    echo -e "Package: snapd\nPin: release a=*\nPin-Priority: -10" | sudo tee /etc/apt/preferences.d/nosnap.pref
    sudo systemctl stop snapd.socket || true
    sudo systemctl stop snapd.service snapd.seeded.service || true
    sudo systemctl mask snapd.socket snapd.service snapd.seeded.service
  fi
}

install_zsh() {
  sudo apt install -y zsh
  chsh -s /usr/bin/zsh
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    git clone https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  fi
}

install_starship() {
  curl -sS https://starship.rs/install.sh | sh
}

install_other() {
  sudo apt install -y neofetch btop direnv
}

install_uv() {
  if ! command -v uv > /dev/null; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
    uv self update
    uv tool install ruff
    uv tool install mypy
    uv tool install pyright
    uv tool install pylint
    uv tool install pytest
    uv tool install pre-commit
    # uv pip3 install torch torchvision torchaudio
  fi
}

install_1password_app() {
  sudo apt install -y 1password
}

install_alacritty_app() {
  if ! [ -f "$HOME/.cargo/bin/alacritty" ]; then
    rustup override set stable
    rustup update stable
    sudo apt install -y cmake g++ pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev
    git clone https://github.com/alacritty/alacritty.git "$tempdir/alacritty"
    cd "$tempdir/alacritty"
    cargo install alacritty
    cd "$TARGET_DIR"
    # But, alacritty does not use Nerd fonts: https://github.com/alacritty/alacritty/issues/8050#issuecomment-2559262078
  fi
}

install_zed_app() {
  if ! command -v zed > /dev/null; then
    sudo apt install -y shellcheck shfmt
    curl -f https://zed.dev/install.sh | sh
  fi
}

install_chrome_app() {
  if ! command -v google-chrome > /dev/null; then
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo apt install -y fonts-liberation xdg-utils
    sudo dpkg -i ./google-chrome-stable_current_amd64.deb
    rm ./google-chrome-stable_current_amd64.deb
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
  wget -qO- https://raw.githubusercontent.com/retorquere/zotero-deb/master/install.sh | sudo bash
  sudo apt update
  sudo apt install zotero
}

install_spotify_app() {
  # https://www.spotify.com/us/download/linux/
  # If it stops working, update the link below from the above url
  curl -sS https://download.spotify.com/debian/pubkey_C85668DF69375001.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
  echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
  sudo apt update && sudo apt install -y spotify-client
}

install_spotify_player() {
  # https://github.com/aome510/spotify-player?tab=readme-ov-file#examples
  sudo apt install -y libssl-dev libasound2-dev libdbus-1-dev
  cargo install spotify_player --locked
}

cleanup_all() {
  sudo apt autoremove -y
  sudo apt clean -y
}

install_nvidia_gpu() {
  # install nvidia drivers
  # https://linuxconfig.org/how-to-install-nvidia-drivers-on-ubuntu-24-04
  ubuntu-drivers devices                # check what drivers are installed (see recommended one)
  sudo apt install -y nvidia-driver-550 # install the above recommended driver
  sudo reboot                           # reboot is required
}

setup_server() {
  update_packages
  setup_git
  setup_1password_cli
  setup_credentials
  install_dotfiles
  setup_netplan "networkd"
  setup_openvpn
  setup_timezone
  install_python3
  install_node
  install_aws_cli
}

setup_desktop() {
  install_rust
  install_alacritty_app
  setup_bluetooth_audio
  setup_sway_wayland
  install_nerd_fonts
  install_i3status-rs
  install_screenshots
  install_notifications
  install_kickoff
  setup_power_management
  setup_brightness
  setup_gamma
  setup_japanese
  remove_snap
  install_zsh
  install_starship
  install_other
}

setup_apps() {
  install_uv
  install_1password_app
  install_zed_app
  install_chrome_app
  install_discord_app
  install_zotero_app
  install_spotify_app
  install_spotify_player
  cleanup_all
}

require_reboot() {
  # run this the last
  install_nvidia_gpu
}

setup_server
setup_desktop
setup_apps
require_reboot

echo "[ ] completed in t=$SECONDS"
