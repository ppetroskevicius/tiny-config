# tiny-config

## Introduction

**tiny-config** is a comprehensive automation toolkit for bootstrapping development environments on Linux (primarily Ubuntu) and macOS. Designed with minimalism and efficiency in mind, this repository provides setup scripts and configuration files that transform a fresh machine into a fully-configured development workstation in minutes.

### Key Benefits

- **Resource Efficiency**: Optimized for low-resource systems (e.g., 4GB RAM on Ubuntu with Sway on Wayland instead of heavier desktop environments like GNOME)
- **Cross-Platform Consistency**: Unified tooling and configurations across Ubuntu and macOS
- **Automation-First**: One-command setup scripts handle dependencies, configurations, and service setup
- **Productivity-Focused**: Pre-configured editors, terminals, version control, and cloud tools
- **Flexible Deployment**: Support for desktop, server (host), and container (guest) environments
- **Security-Conscious**: Integrated credential management with 1Password, SSH key handling, and WireGuard VPN

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
- **VS Code Compatibility**: Shared settings via `.vscode/settings.json` for Cursor

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

The Ubuntu setup script (`setup_ubuntu.sh`) supports five machine types as defined in [INVENTORY.md](docs/INVENTORY.md):

#### Development Desktop (`dt-dev`)

Full desktop environment with Sway Wayland, all development tools, and desktop applications:

```bash
chmod +x setup_ubuntu.sh
./setup_ubuntu.sh dt-dev
```

**What it installs:**

- Full desktop environment (Sway Wayland, i3status-rust, Mako, Kickoff)
- All development tools (Node.js, Python via uv, Rust, Java)
- Cloud CLIs (AWS, GCP, Firebase, Terraform)
- Desktop applications (Chrome, Firefox, Discord, Zotero, Spotify, 1Password, editors)
- Network configuration (systemd-networkd, WireGuard)
- Power management (TLP)
- Japanese input (Fcitx5)
- Bluetooth and audio setup
- Docker, Dev Container CLI
- Starship prompt
- Kotlin and Golang development tools

#### Bare Metal Hypervisor (`bm-hypervisor`)

Physical servers dedicated to running KVM for hosting VMs:

```bash
chmod +x setup_ubuntu.sh
./setup_ubuntu.sh bm-hypervisor
```

**What it installs:**

- KVM and libvirt (qemu-kvm, libvirt, bridge-utils)
- Storage tools (ZFS, mdadm, fio, nvme-cli, pciutils)
- NFS server (nfs-kernel-server, nfs-common)
- Hardware monitoring (lm-sensors)
- Core utilities and SSH management
- **Excludes**: Docker, development tools, Starship, cloud CLIs

#### Kubernetes VM Node (`vm-k8s-node`)

Virtual machines configured as Kubernetes nodes (k3s):

```bash
chmod +x setup_ubuntu.sh
./setup_ubuntu.sh vm-k8s-node
```

**What it installs:**

- k3s (lightweight Kubernetes)
- containerd (container runtime via k3s)
- Monitoring tools (btop, nvtop, inxi)
- File/text utilities (jq, ripgrep, fd-find, csvtool)
- System info tools (lshw, lsof, man-db, parallel)
- Network tools (infiniband-diags, ipmitool, rclone, rdma-core)
- Python base (python3, pip, venv)
- Core utilities and SSH management
- **Excludes**: Docker, Rust, Python via uv, Starship, cloud CLIs, desktop apps

#### Development Container VM (`vm-dev-container`)

VMs dedicated to running Dev Containers for isolated development:

```bash
chmod +x setup_ubuntu.sh
./setup_ubuntu.sh vm-dev-container
```

**What it installs:**

- Docker (container runtime)
- Dev Container CLI
- Monitoring tools (btop, nvtop, inxi)
- File/text utilities (jq, ripgrep, fd-find, csvtool)
- System info tools (lshw, lsof, man-db, parallel)
- Python base (python3, pip, venv)
- Core utilities and SSH management
- **Excludes**: Kubernetes, Rust, Python via uv, Starship, cloud CLIs, network tools (infiniband, ipmitool, rdma)

#### Service VM (`vm-service`)

Clean VMs for standalone services (NFS, databases, etc.):

```bash
chmod +x setup_ubuntu.sh
./setup_ubuntu.sh vm-service
```

**What it installs:**

- Minimal core utilities
- Basic file tools (file, rsync, jq, man-db)
- NFS client (nfs-common)
- Service-specific packages (install separately as needed)
- Core utilities and SSH management
- **Excludes**: Docker, Kubernetes, development tools, monitoring tools, Starship, cloud CLIs

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
- Development tools (Node.js, Python, Rust, Java, Kotlin, Golang)
- Cloud CLIs (AWS, GCP, Firebase, Terraform)
- Desktop applications (1Password, Chrome, Firefox, Zed, Cursor, Discord, Zotero, Spotify)
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

| File/Directory            | Purpose                  | Location                                                                                                           |
| ------------------------- | ------------------------ | ------------------------------------------------------------------------------------------------------------------ |
| `.vscode/settings.json`   | VS Code/Cursor settings  | `~/.config/Cursor/User/settings.json` (Linux) or `~/Library/Application Support/Cursor/User/settings.json` (macOS) |
| `.vscode/extensions.json` | Recommended extensions   | Repository only                                                                                                    |
| `zed/keymap.json`         | Zed keybindings          | `~/.config/zed/keymap.json`                                                                                        |
| `zed/settings.json`       | Zed settings             | `~/.config/zed/settings.json`                                                                                      |
| `.cursor_mcp.json`        | Cursor MCP configuration | `~/.cursor/mcp.json`                                                                                               |
| `.cursorrules`            | Cursor AI rules          | Repository only                                                                                                    |
| `.cursorignore`           | Cursor ignore patterns   | Repository only                                                                                                    |

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

Primary Ubuntu setup script with five machine types: `bm-hypervisor`, `vm-k8s-node`, `vm-dev-container`, `vm-service`, and `dt-dev`.

**Dependencies:**

- Sources `install_common_dependencies.sh`
- Sources `install_ubuntu_dependencies.sh`

**Usage:**

```bash
./setup_ubuntu.sh [bm-hypervisor|vm-k8s-node|vm-dev-container|vm-service|dt-dev]
```

**Machine Types:**

- `bm-hypervisor`: Bare metal hypervisor hosts (KVM, storage tools)
- `vm-k8s-node`: Kubernetes VM nodes (k3s, containerd)
- `vm-dev-container`: Development container VM hosts (Docker, Dev Container CLI)
- `vm-service`: Service-specific VMs (minimal, service packages)
- `dt-dev`: Development desktops (full-featured, all tools)

**Outputs:**

- Installed packages and tools
- Symlinked configuration files
- Configured services
- System optimizations

#### `setup_mac.sh`

Primary macOS setup script.

**Dependencies:**

- Sources `install_common_dependencies.sh`
- Sources `install_mac_dependencies.sh`

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
- Kotlin (via SDKMAN)
- Golang (official installer)
- Starship prompt
- Docker
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

#### `install_mac_dependencies.sh`

macOS-specific installation functions:

- Homebrew installation and setup
- Homebrew packages (git, gh, vim, tmux, etc.)
- Homebrew applications (1Password, Chrome, Firefox, etc.)
- macOS system preferences configuration

**When to use independently**: Only if you need to add macOS-specific components after initial setup.

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
