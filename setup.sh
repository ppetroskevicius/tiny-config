#/bin/bash
set -e
set -x

# run this script with:
# wget https://raw.githubusercontent.com/ppetroskevicius/tiny-config/dev/setup.sh

SOURCE_REPO="https://github.com/ppetroskevicius/tiny-config.git"
TARGET_DIR="$HOME/fun/tiny-config"

update_packages() {
  sudo apt update && sudo apt upgrade -y
}

setup_git() {
  GIT_USERNAME="ppetroskevicius"
  GIT_EMAIL="p.petroskevicius@gmail.com"

  sudo apt install -y git tmux htop vim
  git config --global user.name "$GIT_USERNAME"
  git config --global user.email "$GIT_EMAIL"
}

install_1password_cli() {
  if ! command -v op >/dev/null; then
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

  systemctl --user enable ssh-agent.service
  systemctl --user restart ssh-agent.service
}

install_dotfiles() {
  rm -rf $TARGET_DIR
  git clone "$SOURCE_REPO" "$TARGET_DIR"
  cd $TARGET_DIR
  git switch dev
  mkdir -p $HOME/.config/

  rm -f $HOME/.bash_profile $HOME/.bashrc $HOME/.zprofile $HOME/.zshrc

  ln -sf $TARGET_DIR/.sshconfig $HOME/.ssh/config
  ln -sf $TARGET_DIR/.bash_profile $HOME
  ln -sf $TARGET_DIR/.bashrc $HOME
  ln -sf $TARGET_DIR/.zprofile $HOME
  ln -sf $TARGET_DIR/.zshrc $HOME
  ln -sf $TARGET_DIR/.tmux.conf $HOME
  ln -sf $TARGET_DIR/.vimrc $HOME
  ln -sf $TARGET_DIR/.gitconfig $HOME
  ln -sf $TARGET_DIR/.alacritty.toml $HOME
  ln -sf $TARGET_DIR/.xinitrc $HOME
  ln -sf $TARGET_DIR/.xinputrc $HOME
  ln -sf $TARGET_DIR/start_i3.sh $HOME
  ln -sf $TARGET_DIR/start_gnome.sh $HOME

  mkdir -p $HOME/.config/i3/
  ln -sf $TARGET_DIR/.i3 $HOME/.config/i3/config
  ln -sf $TARGET_DIR/status.toml $HOME/.config/i3/status.toml

  mkdir -p $HOME/.config/zed/
  ln -sf $TARGET_DIR/zed/keymap.json $HOME/.config/zed/
  ln -sf $TARGET_DIR/zed/settings.json $HOME/.config/zed/

  rm -rf $HOME/.config/alacritty
  mkdir -p $HOME/.config/alacritty/themes
  git clone https://github.com/alacritty/alacritty-theme $HOME/.config/alacritty/themes
}

setup_network_manager() {
  # enable NetworkManager to be used with gnome, as it has more functionality, like LAN, VPN, WiFi
  sudo sed -i 's/managed=false/managed=true/' /etc/NetworkManager/NetworkManager.conf
  sudo systemctl enable NetworkManager
  sudo systemctl restart NetworkManager
  # disable netplan
  # sudo mkdir -p /etc/netplan/backup
  # sudo mv /etc/netplan/*.yaml /etc/netplan/backup/
  # sudo netplan apply
  sudo systemctl stop systemd-networkd
  sudo systemctl disable systemd-networkd
  sudo systemctl mask systemd-networkd
  # this is not required as we use network manager, or otheriwise it causes timeout at the boot
  sudo systemctl disable systemd-networkd-wait-online.service
}

setup_wifi() {
  if nmcli device status | grep -q "wifi"; then
    nmcli device wifi list
    OP_WIFI_SSID="op://build/wifi/ssid"
    OP_WIFI_PASS="op://build/wifi/pass"
    export WIFI_SSID=$(op read "$OP_WIFI_SSID")
    export WIFI_PASS=$(op read "$OP_WIFI_PASS")
    nmcli device wifi connect $WIFI_SSID password $WIFI_PASS
  fi
}

setup_bluetooth() {
  sudo systemctl enable bluetooth
  sudo systemctl restart bluetooth
  sudo apt install -y blueman
}

setup_i3() {
  sudo apt install -y i3 i3status i3lock dmenu xinit
  # startx /usr/bin/i3
}

install_gnome() {
  sudo apt install -y gnome-session gnome-screenshot

  # to make a screenshot:
  # gnome-screenshot --area -c

  # sudo apt install -y gnome-extensions-app
  # sudo apt install -y gnome-tweaks
  # sudo apt install -y gnome-desktop
  #startx /usr/bin/gnome-session
}

setup_japanese() {
  # https://www.ubuntulinux.jp/News/ubuntu2404-ja-remix
  sudo wget https://www.ubuntulinux.jp/sources.list.d/noble.sources -O /etc/apt/sources.list.d/ubuntu-ja.sources
  sudo apt -U upgrade
  sudo apt install -y ubuntu-defaults-ja
  sudo apt install -y ibus
}

install_zsh() {
  sudo apt install -y zsh
  chsh -s /usr/bin/zsh
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
}

remove_snap() {
  snap list
  # purge snaps that do not have dependencies
  sudo snap remove cups gnome-42-2204 gtk-common-themes
  # remove base snaps and snapd
  sudo snap remove bare
  sudo snap remove core22
  sudo snap remove snapd
  # purge snapd and cleanup
  sudo apt purge snapd
  sudo rm -rf /var/cache/snapd
  sudo rm -rf /snap
  # prevent snapd from being reinstalled
  echo -e "Package: snapd\nPin: release a=*\nPin-Priority: -10" | sudo tee /etc/apt/preferences.d/nosnap.pref
  # stop snapd services and prevent from being restarted
  sudo systemctl stop snapd.socket
  sudo systemctl stop snapd.service snapd.seeded.service
  sudo systemctl mask snapd.socket snapd.service snapd.seeded.service
  # TODO: Below removed a lot of packages including gdm
  # sudo apt purge snapd libsnapd-glib-2-1
}

install_kvm() {
  sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager virt-viewer
  sudo kvm-ok
  # sudo systemctl enble libvirtd
  # sudo systemctl restart libvirtd
  # sudo systemctl status libvirtd
  sudo usermod -aG libvirt $(whoami)
  newgrp libvirt
  # virt-manager
}

install_uv() {
  curl -LsSf https://astral.sh/uv/install.sh | sh
  source $HOME/.cargo/env
  uv self update
}

# install applications

install_1password_app() {
  sudo apt install -y 1password
}

install_alacritty_app() {
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  rustup override set stable
  rustup update stable
  sudo apt install -y cmake g++ pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3
  rm -rf /tmp/alacritty
  git clone https://github.com/alacritty/alacritty.git /tmp/alacritty
  cd /tmp/alacritty
  cargo install alacritty
  cd $TARGET_DIR
}

install_zed_app() {
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



update_packages
setup_git
install_1password_cli
setup_credentials
install_dotfiles

setup_network_manager
setup_wifi
setup_bluetooth
setup_i3
install_gnome
setup_japanese
install_zsh
remove_snap

# install_kvm
# install_uv

# install_1password_app
# install_alacrity_app
# install_zed_app
# install_chrome_app
# install_discord_app
# install_spotify_app
