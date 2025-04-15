# Minimal Mac or Ubuntu Server Setup with Sway on Wayland Setup

## Overview

This script provides a minimal and resource-efficient setup for a development machine running Mac or Ubuntu Server with Sway on Wayland. It automates system configuration, package installation, dotfiles setup, and various enhancements to create a streamlined, productive development environment. The whole setup with windows manager, editor, discord and browser running uses only 4GB of RAM (in case of Ubuntu setup).

![image](https://github.com/user-attachments/assets/7d46d21d-00f4-4f42-a362-13a5d8d0da49)

## Features

- **Base System Setup**: Updates system packages and installs essential tools.
- **Credential Management**: Uses 1Password CLI for SSH key and Wi-Fi credential retrieval.
- **Network Configuration**: Supports `systemd-networkd` with Wi-Fi and Ethernet auto-configuration.
- **Development Environment**: Installs Git, Rust, Python, and various development utilities.
- **Dotfiles Installation**: Links personal configuration files for terminal, shell, editor, and system utilities.
- **Desktop Environment**: Sets up Sway as a Wayland compositor, installs essential graphical tools, and configures fonts.
- **Power Management**: Includes power-saving configurations and brightness adjustments.
- **Audio & Bluetooth**: Installs and configures PulseAudio, Bluetooth utilities, and media control tools.
- **Japanese Input Support**: Installs and configures Fcitx5 for Japanese input.
- **NVIDIA and AMD GPU Support**: Installs and configures NVIDIA CUDA or AMD ROCm GPU drivers if applicable.
- **Additional Applications**: Installs Chrome, Discord, Spotify, Zotero, Zed, and other useful applications.
- **Cleanup & Optimization**: Removes unnecessary packages and ensures a clean system setup.

## Requirements

- Ubuntu Server (latest version recommended)
- Internet connection
- An active 1Password account (for credentials management)

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/ppetroskevicius/tiny-config.git ~/fun/tiny-config
cd ~/fun/tiny-config
```

### 2. Run the Setup Script

```bash
chmod +x ./setup_ubuntu.sh host  # for Ubuntu host installation
chmod +x ./setup_ubuntu.sh guest  # for Ubuntu guest installation
chmod +x ./setup_ubuntu.sh desktop  # for Ubuntu desktop (notebook) installation
./setup_ubuntu.sh
# or
chmod +x ./setup_mac.sh
./setup_mac.sh
```

### 3. Reboot the System

After installation, a reboot is required for changes to take effect:

```bash
sudo reboot
```

## Configuration Details

### Network Setup

This script configures networking based on your system’s available interfaces:

- **Wi-Fi**: Uses `networkd` with credentials retrieved from 1Password.
- **Ethernet**: Automatically detects and configures Ethernet connections.

### Dotfiles Management

Configuration files are linked from the cloned repository to maintain a consistent development environment. This includes:

- Shell (`zsh`, `bash`)
- Terminal (`tmux`, `vim`, `alacritty`)
- Wayland (`sway`, `mako`, `i3status-rust`, `kickoff`, `swaylock`, `swaybg`, `swayidle`, `swaynag`, `swaylock-effects`, `swaybg-effects`)

### Package Installation

The script installs and configures essential packages, including:

- **Development Tools**: `git`, `vim`, `tmux`, `python3`, `rust`
- **System Utilities**: `htop`, `jq`,
- **Wayland Compositor**: `sway`, `wayland-protocols`, `xwayland`
- **Audio & Media**: `pulseaudio`, `bluetooth`
- **Fonts**: Nerd Fonts for better terminal experience

### Additional Applications

Optional applications can be installed, including:

- **Browsers**: Google Chrome
- **Editors**: Zed
- **Messaging**: Discord
- **Research Tools**: Zotero
- **Music**: Spotify and `spotify-player`

## Contributing

Feel free to fork and contribute to this project by submitting a pull request.

## License

This script is open-source and available under the MIT License.
