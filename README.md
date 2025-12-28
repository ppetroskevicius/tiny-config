# Minimalistic Ubuntu with Sway on Wayland Setup for Development

## Overview

This repository provides comprehensive automation for setting up development environments across multiple platforms. It's designed for developers who need a consistent, efficient, and well-configured development setup that can be deployed quickly on new machines.

**For Ubuntu**: The setup starts with a minimal Ubuntu Server 24.04 installation and builds up a complete development environment from there. Instead of using the standard Ubuntu Desktop with GNOME, this configuration uses **Sway on Wayland** - a lightweight, tiling window manager that provides a modern desktop experience with significantly better resource efficiency. The entire desktop environment with window manager, editor, and browser typically uses only **4GB of RAM**, compared to the much higher resource usage of traditional desktop environments.

The repository includes scripts for Ubuntu (with Sway Wayland desktop), macOS, and specialized configurations for different use cases (desktop development, server hosting, container environments, and GPU computing). The entire setup is optimized for productivity with minimal resource usage.

![image](https://github.com/user-attachments/assets/7d46d21d-00f4-4f42-a362-13a5d8d0da49)

## Key Features

### **Multi-Platform Support**

- **Ubuntu**: Full desktop setup with Sway Wayland, server configurations, and container environments
- **macOS**: Complete development environment with Homebrew and native applications
- **Cross-platform**: Consistent tooling and configurations across all platforms

### **Development Environment**

- **Shell & Terminal**: Zsh with Oh-My-Zsh, Starship prompt, Alacritty terminal, and Tmux
- **Editors & IDEs**: Vim, Zed, Cursor, and Windsurf with optimized configurations
- **Version Control**: Git with multi-account SSH setup for GitHub
- **Package Managers**: Homebrew (macOS), apt (Ubuntu), npm, cargo, and uv (Python)

### **Cloud & DevOps Tools**

- **Google Cloud Platform**: CLI installation and multi-environment configuration (dev/test/prod)
- **AWS**: CLI and CDK installation with configuration management
- **Firebase**: CLI tools for web and mobile development
- **Docker**: Container runtime and management tools

### **System Configuration**

- **Credential Management**: 1Password CLI integration for secure credential storage
- **Network Setup**: Automated WiFi and Ethernet configuration with systemd-networkd
- **Security**: WireGuard VPN setup and SSH key management
- **Power Management**: Optimized power settings and brightness controls

### **Development Tools**

- **Languages**: Python, Rust, Node.js with version management
- **Linters & Formatters**: Ruff, Pylint, and code quality tools
- **GPU Computing**: ROCm support for AMD GPUs and CUDA alternatives
- **Fonts**: Nerd Fonts for enhanced terminal experience

### **Desktop Applications** (Ubuntu)

- **Web Browser**: Google Chrome
- **Communication**: Discord
- **Research**: Zotero
- **Media**: Spotify with CLI player
- **Productivity**: 1Password, remote desktop tools

### **System Optimization**

- **Memory Efficiency**: Minimal resource usage with Sway Wayland
- **Performance**: Optimized package selection and system cleanup
- **Japanese Input**: Fcitx5 setup for international development
- **Audio**: Bluetooth and PulseAudio configuration

## Requirements

- Ubuntu Server (latest version recommended)
- An active 1Password account (for credentials management)

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/ppetroskevicius/tiny-config.git
cd tiny-config
```

### 2. Run the Setup Script

```bash
chmod +x ./setup_ubuntu.sh host  # for minimal host setup
chmod +x ./setup_ubuntu.sh guest  # for guest (containers) setup
chmod +x ./setup_ubuntu.sh desktop  # for desktop setup (recommended for development machines)
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

### Setup Options

#### Desktop Setup (Recommended for Development)

```bash
./setup_ubuntu.sh desktop
```

- Full desktop environment with Sway Wayland
- All development tools and applications
- Gcloud CLI and other cloud tools
- Desktop applications (Chrome, Discord, Spotify, etc.)

#### Host Setup (Minimal)

```bash
./setup_ubuntu.sh host
```

- Minimal setup for servers or headless machines
- Basic tools and Docker
- Core dependencies

#### Guest Setup

```bash
./setup_ubuntu.sh guest
```

- Development environment setup
- Rust, Python tools, linters

## Configuration Details

### Network Setup

This script configures networking based on your system's available interfaces:

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
- **Editors**: Zed, Cursor, Windsurf
- **Messaging**: Discord
- **Research Tools**: Zotero
- **Music**: Spotify and `spotify-player`

## Contributing

Feel free to fork and contribute to this project by submitting a pull request.

## License

This script is open-source and available under the MIT License.
