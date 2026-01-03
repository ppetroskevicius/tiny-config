# tiny-config

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Introduction

**tiny-config** is a comprehensive automation toolkit for bootstrapping development environments on Linux (primarily Ubuntu) and macOS. Designed with minimalism and efficiency in mind, this repository provides setup scripts and configuration files that transform a fresh machine into a fully-configured development workstation in minutes.

### Key Benefits

- **Resource Efficiency**: Optimized for low-resource systems (e.g., 4GB RAM on Ubuntu with Sway on Wayland instead of heavier desktop environments like GNOME)
- **Cross-Platform Consistency**: Unified tooling and configurations across Ubuntu and macOS
- **Automation-First**: One-command setup scripts handle dependencies, configurations, and service setup
- **Productivity-Focused**: Pre-configured editors, terminals, version control, and cloud tools
- **Flexible Deployment**: Support for desktop, server (host), and container (guest) environments
- **Security-Conscious**: Integrated credential management with 1Password, SSH key handling, and WireGuard VPN

### Target Users

This repository is ideal for:

- Developers setting up new development machines
- Teams requiring consistent development environments
- Users seeking minimalistic, efficient setups
- Developers working with cloud services (AWS, GCP), containers, and GPU computing

## Features

### Shell & Terminal

- **Zsh with Oh-My-Zsh**: Enhanced shell with autosuggestions and plugin ecosystem
- **Starship**: Fast, customizable prompt with Git, cloud provider, and environment indicators
- **Alacritty**: GPU-accelerated terminal emulator with theme support
- **Tmux**: Terminal multiplexer for session management
- **Bash**: Fallback shell with optimized configurations

### Editors & IDEs

- **Vim**: Lightweight editor with optimized keybindings and plugins
- **Zed**: Modern, high-performance editor with Rust backend
- **Cursor**: AI-powered editor with MCP (Model Context Protocol) integration
- **Windsurf**: AI coding assistant with custom rules and MCP configuration
- **VS Code Compatibility**: Shared settings via `.vscode/settings.json` for Cursor and Windsurf

### Version Control

- **Git**: Multi-account SSH setup for personal and work repositories
- **GitHub CLI**: Enhanced GitHub workflow integration
- **Git LFS**: Large file storage support

### Cloud & DevOps

- **Google Cloud Platform**: CLI with multi-environment configuration (dev/test/prod/demo)
- **AWS**: CLI and CDK installation with configuration management
- **Firebase**: CLI tools for web and mobile development
- **Terraform**: Infrastructure as Code tooling
- **Docker**: Container runtime and management
- **Podman**: Alternative container runtime (installed on host and desktop, not in containers)

### Security & Networking

- **1Password CLI**: Secure credential storage and retrieval
- **SSH**: Automated key management with multi-account support
- **WireGuard**: VPN configuration for secure networking
- **systemd-networkd**: Network configuration management (Ubuntu)

### System Configuration

- **Power Management**: TLP for laptop power optimization
- **Brightness & Gamma Controls**: Display management utilities
- **Japanese Input**: Fcitx5 setup for international development
- **Audio**: Bluetooth and PulseAudio configuration
- **Timezone**: Automatic Asia/Tokyo configuration

### Development Tools

- **Languages**: Python (with uv), Rust, Node.js (via nvm), Java
- **Package Managers**: Homebrew (macOS), apt (Ubuntu), npm, pnpm, cargo, uv
- **Linters & Formatters**: Ruff (Python), Pylint, ESLint, Prettier, shfmt
- **GPU Computing**: ROCm support for AMD GPUs (two-part installation)
- **Fonts**: Nerd Fonts (Fira Code, Meslo LG) for enhanced terminal experience

### Desktop Applications (Ubuntu)

- **Web Browser**: Google Chrome
- **Communication**: Discord
- **Research**: Zotero
- **Media**: Spotify with CLI player (`spotify-player`)
- **Productivity**: 1Password, remote desktop tools
- **Window Manager**: Sway (Wayland compositor) with i3status-rust, Mako notifications, Kickoff launcher

### System Optimization

- **Memory Efficiency**: Minimal resource usage with Sway Wayland (~4GB RAM for full desktop)
- **Performance**: Optimized package selection and automatic cleanup
- **Snap Removal**: Optional removal of Snap packages for faster boot times
- **Kernel Management**: Automatic cleanup of old kernels

## Prerequisites

Before running the setup scripts, ensure you have:

- **Fresh Ubuntu Server 24.04+** (for Ubuntu setup) or **macOS** (for macOS setup)
- **Internet access** for downloading packages and dependencies
- **sudo privileges** (Ubuntu) or administrator access (macOS)
- **Active 1Password account** for credential management (SSH keys, WireGuard configs)
- **Git** installed (usually pre-installed on Ubuntu Server and macOS)

### Optional Prerequisites

- **AMD GPU** (for ROCm installation)
- **GCP project IDs** (for GCP configuration setup)
- **Existing SSH keys** in 1Password (or the setup will create them)

## Installation

### General Setup

1. **Clone the repository**:

```bash
git clone https://github.com/ppetroskevicius/tiny-config.git
cd tiny-config
```

### Ubuntu Installation

The Ubuntu setup script (`setup_ubuntu.sh`) supports three deployment modes:

#### Desktop Setup (Recommended for Development)

Full desktop environment with Sway Wayland, all development tools, and desktop applications:

```bash
chmod +x setup_ubuntu.sh
./setup_ubuntu.sh desktop
```

**What it installs:**

- Full desktop environment (Sway Wayland, i3status-rust, Mako, Kickoff)
- All development tools (Node.js, Python, Rust, Java)
- Cloud CLIs (AWS, GCP, Firebase, Terraform)
- Desktop applications (Chrome, Discord, Zotero, Spotify, 1Password, editors)
- Network configuration (systemd-networkd, WireGuard)
- Power management (TLP)
- Japanese input (Fcitx5)
- Bluetooth and audio setup

#### Host Setup (Minimal Server)

Minimal setup for headless servers or machines running containers:

```bash
chmod +x setup_ubuntu.sh
./setup_ubuntu.sh host
```

**What it installs:**

- Core dependencies and utilities
- Docker and Podman
- Basic development tools
- SSH and credential management

#### Guest Setup (Container Environment)

Development environment for containers or minimal guest systems:

```bash
chmod +x setup_ubuntu.sh
./setup_ubuntu.sh guest
```

**What it installs:**

- Rust toolchain
- Python with uv
- Linters and formatters (Ruff, Pylint)
- Starship prompt
- Yazi file manager
- Development utilities

#### Post-Installation

After running any Ubuntu setup, **reboot the system** for changes to take effect:

```bash
sudo reboot
```

### macOS Installation

Complete development environment setup for macOS:

```bash
chmod +x setup_mac.sh
./setup_mac.sh
```

**What it installs:**

- Homebrew package manager
- Core utilities (git, vim, tmux, htop, jq)
- Development tools (Node.js, Python, Rust, Java)
- Cloud CLIs (AWS, GCP, Firebase, Terraform)
- Desktop applications (1Password, Chrome, Firefox, Zed, Cursor, Windsurf, Discord, Zotero, Spotify)
- Nerd Fonts
- macOS preferences optimization (Finder, Dock, keyboard)

### Optional Scripts

#### ROCm GPU Setup (Ubuntu)

For AMD GPU support, install ROCm in two parts (requires reboot after part 1):

```bash
# Part 1: Install kernel drivers (requires reboot)
chmod +x install_rocm_part1.sh
./install_rocm_part1.sh
# System will reboot automatically

# After reboot, run part 2
chmod +x install_rocm_part2.sh
./install_rocm_part2.sh
```

**Note**: Part 1 installs kernel headers, adds user to render/video groups, and installs AMD GPU drivers. Part 2 completes the ROCm installation.

#### Python Dependencies

Install Python-specific tools independently:

```bash
chmod +x install_python_dependencies.sh
./install_python_dependencies.sh
```

Installs: uv (Python package manager), Ruff, Pylint, and Python development tools.

#### GCP Configuration

After running the main setup and authenticating with GCP:

```bash
# 1. Authenticate with Google Cloud
gcloud auth login

# 2. Set environment variables
export GCP_DEV_PROJECT_ID="your-dev-project"
export GCP_TEST_PROJECT_ID="your-test-project"
export GCP_PROD_PROJECT_ID="your-prod-project"
export GCP_DEMO_PROJECT_ID="your-demo-project"

# 3. Run the configuration script
chmod +x install_gcp_configs.sh
./install_gcp_configs.sh
```

Creates separate GCP configurations for dev, test, prod, and demo environments.

#### Snap Packages (Ubuntu)

Install Snap packages if needed:

```bash
chmod +x install_snap.sh
./install_snap.sh
```

**Note**: The desktop setup includes an option to remove Snap packages for faster boot times.

#### Cursor Extensions Sync

Synchronize Cursor extensions with `.vscode/extensions.json`:

```bash
chmod +x sync_cursor_extensions.sh
./sync_cursor_extensions.sh
```

This script:

- Compares installed extensions with recommendations
- Removes extensions not in the list
- Installs missing recommended extensions
- Provides a sync report

### Handling Existing Configurations

The setup scripts handle existing configurations gracefully:

- **Dotfiles**: Existing dotfiles are backed up (removed and symlinked)
- **SSH Keys**: Only creates keys if they don't exist
- **Services**: Enables and starts services without overwriting existing configs
- **Packages**: Uses package managers' built-in idempotency

### Troubleshooting Common Issues

#### Permission Errors

If you encounter permission errors:

```bash
# Ensure scripts are executable
chmod +x *.sh

# Check sudo access
sudo -v
```

#### Package Conflicts

If package installation fails:

```bash
# Update package lists
sudo apt update  # Ubuntu
brew update      # macOS

# Clean package cache
sudo apt clean   # Ubuntu
brew cleanup     # macOS
```

#### Wayland Compatibility

If applications don't work with Wayland:

- Some applications require XWayland (automatically installed)
- Check `~/.config/sway/config` for XWayland configuration
- Use `swaymsg` to debug window manager issues

#### ROCm Installation Issues

For AMD GPU setup problems:

- Ensure you have a supported AMD GPU
- Check kernel version compatibility
- Verify you're in the `render` and `video` groups: `groups`
- Review ROCm documentation for your specific GPU model

#### 1Password CLI Authentication

If credential retrieval fails:

```bash
# Re-authenticate with 1Password
op signin --account my

# Verify access
op read op://build/my-ssh-key/id_ed25519
```

## Configuration Files

All configuration files are symlinked from the repository to your home directory during setup. This ensures consistency and easy updates via Git.

### Shell Configurations

| File             | Purpose                                | Location                  |
| ---------------- | -------------------------------------- | ------------------------- |
| `.zshrc`         | Zsh shell configuration with Oh-My-Zsh | `~/.zshrc`                |
| `.zprofile`      | Zsh profile (login shell)              | `~/.zprofile`             |
| `.bashrc`        | Bash configuration                     | `~/.bashrc`               |
| `.bash_profile`  | Bash profile (login shell)             | `~/.bash_profile`         |
| `.starship.toml` | Starship prompt configuration          | `~/.config/starship.toml` |

### Terminal & Multiplexer

| File              | Purpose                          | Location            |
| ----------------- | -------------------------------- | ------------------- |
| `.alacritty.toml` | Alacritty terminal configuration | `~/.alacritty.toml` |
| `.tmux.conf`      | Tmux session manager config      | `~/.tmux.conf`      |
| `.vimrc`          | Vim editor configuration         | `~/.vimrc`          |

### Version Control

| File         | Purpose                  | Location        |
| ------------ | ------------------------ | --------------- |
| `.gitconfig` | Git global configuration | `~/.gitconfig`  |
| `.sshconfig` | SSH client configuration | `~/.ssh/config` |

### Editor Configurations

| File/Directory            | Purpose                          | Location                                                                                                           |
| ------------------------- | -------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| `.vscode/settings.json`   | VS Code/Cursor/Windsurf settings | `~/.config/Cursor/User/settings.json` (Linux) or `~/Library/Application Support/Cursor/User/settings.json` (macOS) |
| `.vscode/extensions.json` | Recommended extensions           | Repository only                                                                                                    |
| `zed/keymap.json`         | Zed keybindings                  | `~/.config/zed/keymap.json`                                                                                        |
| `zed/settings.json`       | Zed settings                     | `~/.config/zed/settings.json`                                                                                      |
| `.cursor_mcp.json`        | Cursor MCP configuration         | `~/.cursor/mcp.json`                                                                                               |
| `.cursorrules`            | Cursor AI rules                  | Repository only                                                                                                    |
| `.cursorignore`           | Cursor ignore patterns           | Repository only                                                                                                    |
| `.windsurfrules`          | Windsurf AI rules                | Repository only                                                                                                    |
| `.mcp_config.json`        | MCP tool configuration           | `~/.codeium/windsurf/mcp_config.json`                                                                              |

### Cloud & DevOps

| File          | Purpose               | Location        |
| ------------- | --------------------- | --------------- |
| `.aws_config` | AWS CLI configuration | `~/.aws/config` |

### Code Quality

| File         | Purpose                      | Location                   |
| ------------ | ---------------------------- | -------------------------- |
| `.ruff.toml` | Ruff linter/formatter config | `~/.config/ruff/ruff.toml` |
| `.pylintrc`  | Pylint configuration         | `~/.config/pylintrc`       |

### System Configuration (Ubuntu)

| File                  | Purpose                         | Location                              |
| --------------------- | ------------------------------- | ------------------------------------- |
| `.sway`               | Sway window manager config      | `~/.config/sway/config`               |
| `.mako`               | Mako notification daemon config | `~/.config/mako/config`               |
| `.i3status-rust.toml` | i3status-rust status bar config | `~/.config/i3status-rust/config.toml` |
| `.tlp.conf`           | TLP power management config     | `~/.config/tlp.conf` (if used)        |

### Customization

All configuration files can be customized after installation:

1. **Edit in repository**: Modify files in the cloned repository, then commit changes
2. **Edit symlinked files**: Changes are reflected in the repository (if editing the symlink target)
3. **Override locally**: Remove symlink and create your own file (not recommended for consistency)

**Best Practice**: Make customizations in the repository and commit them for version control and cross-machine consistency.

## Scripts Overview

### Main Setup Scripts

#### `setup_ubuntu.sh`

Primary Ubuntu setup script with three modes: `host`, `guest`, and `desktop`.

**Dependencies:**

- Sources `install_common_dependencies.sh`
- Sources `install_python_dependencies.sh`
- Sources `install_ubuntu_dependencies.sh`

**Usage:**

```bash
./setup_ubuntu.sh [host|guest|desktop]
```

**Outputs:**

- Installed packages and tools
- Symlinked configuration files
- Configured services
- System optimizations

#### `setup_mac.sh`

Primary macOS setup script.

**Dependencies:**

- Sources `install_common_dependencies.sh`
- Sources `install_python_dependencies.sh`

**Usage:**

```bash
./setup_mac.sh
```

**Outputs:**

- Homebrew packages and casks
- Symlinked configuration files
- macOS system preferences
- Development tools

### Dependency Installation Scripts

#### `install_common_dependencies.sh`

Shared functions for both Ubuntu and macOS:

- 1Password CLI setup
- Credential management (SSH keys, WireGuard)
- Zsh and Oh-My-Zsh installation
- Dotfile symlinking
- Node.js (via nvm) and pnpm
- AWS CLI and CDK
- GCP CLI
- Firebase CLI
- Terraform CLI
- Rust toolchain
- Starship prompt
- Docker and Podman
- Alacritty
- Claude Code app
- Yazi file manager

**When to use independently**: Rarely; typically sourced by main setup scripts.

#### `install_ubuntu_dependencies.sh`

Ubuntu-specific installations:

- Package management
- Desktop environment (Sway, Wayland)
- System services (networkd, Bluetooth, audio)
- Desktop applications
- Power management
- Japanese input

**When to use independently**: Only if you need to add Ubuntu-specific components after initial setup.

#### `install_python_dependencies.sh`

Python development tools:

- uv (Python package manager)
- Ruff (linter/formatter)
- Pylint
- Python development dependencies

**When to use independently**: If you need Python tools on a system that already has the base setup.

### Specialized Scripts

#### `install_rocm_part1.sh` & `install_rocm_part2.sh`

Two-part ROCm installation for AMD GPUs.

**Part 1** (`install_rocm_part1.sh`):

- Installs kernel headers
- Adds user to render/video groups
- Sets up AMD GPU repository
- Installs kernel driver (`amdgpu-dkms`)
- **Requires reboot**

**Part 2** (`install_rocm_part2.sh`):

- Completes ROCm installation
- Installs ROCm libraries and tools

**When to use**: On systems with AMD GPUs for GPU computing workloads.

#### `install_gcp_configs.sh`

Creates multiple GCP configurations (dev, test, prod, demo).

**Prerequisites:**

- `gcloud` CLI installed (via main setup)
- `gcloud auth login` completed
- Environment variables: `GCP_DEV_PROJECT_ID`, `GCP_TEST_PROJECT_ID`, `GCP_PROD_PROJECT_ID`, `GCP_DEMO_PROJECT_ID`

**Usage:**

```bash
export GCP_DEV_PROJECT_ID="..."
export GCP_TEST_PROJECT_ID="..."
export GCP_PROD_PROJECT_ID="..."
export GCP_DEMO_PROJECT_ID="..."
./install_gcp_configs.sh
```

**Outputs:**

- Four GCP configurations
- Dev set as default
- Project and account configured for each

**When to use**: After initial setup when you need multi-environment GCP access.

#### `install_snap.sh`

Installs Snap packages (Ubuntu).

**When to use**: If you need Snap packages that aren't installed by default (desktop setup can remove Snap).

#### `sync_cursor_extensions.sh`

Synchronizes Cursor extensions with `.vscode/extensions.json`.

**Usage:**

```bash
./sync_cursor_extensions.sh
```

**Outputs:**

- Extension sync report
- Removes non-recommended extensions
- Installs missing recommended extensions

**When to use**: To maintain consistency across machines or after updating `extensions.json`.

## Additional Guides

### CLAUDE.md

Guidance for Claude Code (claude.ai/code) when working with this repository. Includes:

- Repository purpose and structure
- Shell script commands (shellcheck, shfmt)
- Code style guidelines (Google Shell Style Guide)
- Testing and formatting instructions

**When to consult**: When contributing shell scripts or modifying existing ones.

### GCP.md

Complete guide for Google Cloud Platform setup. Covers:

- GCP CLI installation (via main setup)
- Authentication process (`gcloud auth login`)
- Multi-environment configuration (`install_gcp_configs.sh`)
- Verification steps
- Switching between environments

**When to consult**: When setting up GCP access or configuring multiple projects.

### SSH.md

SSH multi-account setup for GitHub. Explains:

- Adding SSH keys to ssh-agent
- Multi-account configuration (personal and work)
- Cloning repositories with different accounts
- Changing remote URLs for existing repositories

**When to consult**: When setting up multiple GitHub accounts or troubleshooting SSH access.

## Troubleshooting

### Common Issues

#### Script Execution Errors

**Problem**: Script fails with "command not found" or permission errors.

**Solution**:

```bash
# Ensure scripts are executable
chmod +x *.sh

# Verify shebang line
head -1 script.sh  # Should show #!/usr/bin/env bash

# Run with debug output
bash -x script.sh
```

#### Package Installation Failures

**Problem**: `apt` or `brew` commands fail.

**Solution**:

```bash
# Ubuntu: Update and fix broken packages
sudo apt update
sudo apt --fix-broken install
sudo apt upgrade

# macOS: Update Homebrew
brew update
brew doctor
```

#### Dotfile Symlink Issues

**Problem**: Configuration files not working or symlinks broken.

**Solution**:

```bash
# Check symlink status
ls -la ~ | grep tiny-config

# Re-run dotfile installation
cd ~/fun/tiny-config
source install_common_dependencies.sh
install_dotfiles
```

#### Wayland/Sway Issues

**Problem**: Applications not displaying or Wayland session not starting.

**Solution**:

```bash
# Check if running on Wayland
echo $XDG_SESSION_TYPE  # Should output "wayland"

# Check Sway configuration
swaymsg -t get_version

# Review Sway logs
journalctl --user -u sway

# Verify XWayland is installed
which Xwayland
```

#### ROCm GPU Issues

**Problem**: ROCm not detecting GPU or permission errors.

**Solution**:

```bash
# Verify GPU detection
rocminfo

# Check user groups
groups  # Should include "render" and "video"

# Add user to groups if missing
sudo usermod -a -G render,video $USER
# Log out and back in

# Check kernel modules
lsmod | grep amdgpu
```

#### 1Password CLI Authentication

**Problem**: Cannot retrieve credentials from 1Password.

**Solution**:

```bash
# Re-authenticate
op signin --account my

# Verify access to specific item
op read op://build/my-ssh-key/id_ed25519

# Check 1Password CLI version
op --version
```

#### Network Configuration (Ubuntu)

**Problem**: WiFi or Ethernet not working after setup.

**Solution**:

```bash
# Check networkd status
systemctl status systemd-networkd

# Review network configuration
cat /etc/netplan/*.yaml

# Test networkd configuration
sudo netplan try

# Check interface status
ip addr show
```

### Platform-Specific Issues

#### Ubuntu: Snap Package Conflicts

If Snap removal causes issues:

```bash
# Reinstall Snap if needed
sudo apt install snapd

# Or keep Snap but disable automatic updates
sudo systemctl disable snapd.refresh.timer
```

#### macOS: Homebrew Permission Issues

```bash
# Fix Homebrew permissions
sudo chown -R $(whoami) /opt/homebrew  # Apple Silicon
sudo chown -R $(whoami) /usr/local     # Intel

# Reinstall Homebrew if needed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Getting Help

1. **Check script output**: All scripts use `set -x` for verbose output
2. **Review logs**: Use `journalctl` (Ubuntu) or `Console.app` (macOS)
3. **Verify prerequisites**: Ensure all prerequisites are met
4. **Test incrementally**: Run individual script functions if possible
5. **Check GitHub Issues**: Search for similar problems in the repository

## Contributing

Contributions are welcome! This project benefits from community input and improvements.

### How to Contribute

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/your-feature-name`
3. **Make your changes**: Follow the code style guidelines (see `CLAUDE.md`)
4. **Test your changes**: Run scripts on a test machine or VM
5. **Commit with clear messages**: Use descriptive commit messages
6. **Push to your fork**: `git push origin feature/your-feature-name`
7. **Open a Pull Request**: Provide a clear description of changes

### Contribution Guidelines

#### Code Style

- **Shell Scripts**: Follow Google Shell Style Guide (see `CLAUDE.md`)
  - Use 2-space indentation
  - Include `set -euo pipefail` at script start
  - Quote all variables
  - Use meaningful function and variable names
- **Python**: Follow PEP 8 (if adding Python scripts)
- **Documentation**: Update README.md and relevant guide files

#### Testing

- Test scripts on fresh Ubuntu Server 24.04+ or macOS installations
- Verify idempotency (scripts should be safe to run multiple times)
- Check error handling for edge cases
- Test on both platforms if changes affect common dependencies

#### Adding New Features

- **New platforms**: Create `setup_<platform>.sh` following existing patterns
- **New tools**: Add installation functions to appropriate dependency script
- **New configs**: Add dotfiles and symlink logic in `install_dotfiles()`
- **Documentation**: Update README.md, add guides if needed

#### Reporting Issues

When reporting issues, include:

- Operating system and version
- Setup type (host/guest/desktop)
- Full error messages and logs
- Steps to reproduce
- Expected vs. actual behavior

## License

This project is licensed under the MIT License. See the repository for the full license text.

## Acknowledgments

### Tools & Technologies

- **Sway**: Wayland compositor (https://swaywm.org)
- **Oh-My-Zsh**: Zsh framework (https://ohmyz.sh)
- **Starship**: Cross-shell prompt (https://starship.rs)
- **Alacritty**: Terminal emulator (https://alacritty.org)
- **1Password**: Credential management (https://1password.com)
- **Homebrew**: macOS package manager (https://brew.sh)
- **ROCm**: AMD GPU computing platform (https://rocm.docs.amd.com)

### Inspiration

This repository is inspired by the dotfiles and setup automation practices of the developer community, emphasizing:

- Minimalism and resource efficiency
- Automation and reproducibility
- Cross-platform consistency
- Security and best practices

---

**Happy coding!** 🚀
