# Package Inventory

This document maps all packages, tools, and configurations to the 5 machine types defined in [TODO.md](docs/TODO.md).

## Machine Types

- **bm-hypervisor**: Bare Metal Hypervisor Hosts (KVM hosts for running VMs)
- **vm-k8s-node**: Kubernetes VM Nodes (k3s master/worker nodes)
- **vm-dev-container**: Development Container VM Hosts (for Dev Containers)
- **vm-service**: Service-Specific VMs (standalone services like NFS, databases)
- **dt-dev**: Development Desktops (physical desktops for interactive work)

## Legend

- ✓ = Included
- ✗ = Excluded (per requirements)

## 1. Update packages (common)

| Package/Tool    | bm-hypervisor | vm-k8s-node | vm-dev-container | vm-service | dt-dev | Notes             |
| --------------- | ------------- | ----------- | ---------------- | ---------- | ------ | ----------------- |
| Update packages | ✓             | ✓           | ✓                | ✓          | ✓      | Update packages   |
| Timezone setup  | ✓             | ✓           | ✓                | ✓          | ✓      | Set to Asia/Tokyo |

## 2. Setup Credentials (common)

| Package/Tool           | bm-hypervisor | vm-k8s-node | vm-dev-container | vm-service | dt-dev | Notes                |
| ---------------------- | ------------- | ----------- | ---------------- | ---------- | ------ | -------------------- |
| 1Password CLI          | ✓             | ✓           | ✓                | ✓          | ✓      | Password manager CLI |
| Credentials (SSH keys) | ✓             | ✓           | ✓                | ✓          | ✓      | From 1Password       |

## 3. Setup Zsh

| Package/Tool | bm-hypervisor | vm-k8s-node | vm-dev-container | vm-service | dt-dev | Notes         |
| ------------ | ------------- | ----------- | ---------------- | ---------- | ------ | ------------- |
| zsh          | ✓             | ✓           | ✓                | ✓          | ✓      | Z shell       |
| oh-my-zsh    | ✓             | ✓           | ✓                | ✓          | ✓      | Zsh framework |

## 4. Dotfiles (common)

| Package/Tool         | bm-hypervisor | vm-k8s-node | vm-dev-container | vm-service | dt-dev | Notes                                 |
| -------------------- | ------------- | ----------- | ---------------- | ---------- | ------ | ------------------------------------- |
| Dotfiles (all)       | ✓             | ✓           | ✓                | ✓          | ✓      | All dotfiles (per user preference)    |
| SSH config           | ✓             | ✓           | ✓                | ✓          | ✓      | SSH configuration                     |
| Git config           | ✓             | ✓           | ✓                | ✓          | ✓      | Git configuration                     |
| Zsh config           | ✓             | ✓           | ✓                | ✓          | ✓      | Zsh configuration                     |
| Tmux config          | ✓             | ✓           | ✓                | ✓          | ✓      | Tmux configuration                    |
| Vim config           | ✓             | ✓           | ✓                | ✓          | ✓      | Vim configuration                     |
| Alacritty config     | ✗             | ✗           | ✗                | ✗          | ✓      | Terminal config                       |
| Starship config      | ✗             | ✗           | ✗                | ✗          | ✓      | Prompt config (if Starship installed) |
| Sway config          | ✗             | ✗           | ✗                | ✗          | ✓      | Window manager config                 |
| Mako config          | ✗             | ✗           | ✗                | ✗          | ✓      | Notification config                   |
| i3status-rust config | ✗             | ✗           | ✗                | ✗          | ✓      | Status bar config                     |
| Ruff config          | ✗             | ✗           | ✗                | ✗          | ✓      | Python linter config                  |
| Zed config           | ✗             | ✗           | ✗                | ✗          | ✓      | Editor config                         |
| Cursor config        | ✗             | ✗           | ✗                | ✗          | ✓      | Editor config                         |
| AWS config           | ✗             | ✗           | ✗                | ✗          | ✓      | AWS configuration                     |
| GCP configs          | ✗             | ✗           | ✗                | ✗          | ✓      | GCP configurations                    |

## 5. Core System Packages

| Package/Tool            | bm-hypervisor | vm-k8s-node | vm-dev-container | vm-service | dt-dev | Notes                  |
| ----------------------- | ------------- | ----------- | ---------------- | ---------- | ------ | ---------------------- |
| **Basic Utilities**     |
| vim                     | ✓             | ✓           | ✓                | ✓          | ✓      | Text editor            |
| tmux                    | ✓             | ✓           | ✓                | ✓          | ✓      | Terminal multiplexer   |
| git                     | ✓             | ✓           | ✓                | ✓          | ✓      | Version control        |
| keychain                | ✓             | ✓           | ✓                | ✓          | ✓      | SSH key management     |
| htop                    | ✓             | ✓           | ✓                | ✓          | ✓      | Process monitor        |
| unzip                   | ✓             | ✓           | ✓                | ✓          | ✓      | Archive utility        |
| netcat-openbsd          | ✓             | ✓           | ✓                | ✓          | ✓      | Network utility        |
| locales                 | ✓             | ✓           | ✓                | ✓          | ✓      | Locale support         |
| direnv                  | ✓             | ✓           | ✓                | ✓          | ✓      | Directory environment  |
| **System Monitoring**   |
| btop                    | ✓             | ✓           | ✓                | ✓          | ✓      | Modern process monitor |
| nvtop                   | ✓             | ✓           | ✓                | ✓          | ✓      | GPU monitoring         |
| inxi                    | ✓             | ✓           | ✓                | ✓          | ✓      | System info            |
| lm-sensors              | ✓             | ✓           | ✓                | ✓          | ✓      | Hardware sensors       |
| **File/Text Utilities** |
| csvtool                 | ✗             | ✓           | ✓                | ✓          | ✓      | CSV processing         |
| fd-find                 | ✗             | ✓           | ✓                | ✓          | ✓      | Find alternative       |
| file                    | ✗             | ✓           | ✓                | ✓          | ✓      | File type detection    |
| ripgrep                 | ✗             | ✓           | ✓                | ✓          | ✓      | Fast grep              |
| rsync                   | ✗             | ✓           | ✓                | ✓          | ✓      | File sync              |
| jq                      | ✗             | ✓           | ✓                | ✓          | ✓      | JSON processor         |
| jc                      | ✗             | ✓           | ✓                | ✓          | ✓      | JSON converter         |
| **System Info**         |
| lshw                    | ✗             | ✓           | ✓                | ✓          | ✓      | Hardware info          |
| lsof                    | ✗             | ✓           | ✓                | ✓          | ✓      | List open files        |
| man-db                  | ✗             | ✓           | ✓                | ✓          | ✓      | Manual pages           |
| parallel                | ✗             | ✓           | ✓                | ✓          | ✓      | Parallel execution     |
| time                    | ✗             | ✓           | ✓                | ✓          | ✓      | Time commands          |
| **Network Tools**       |
| infiniband-diags        | ✗             | ✓           | ✓                | ✗          | ✓      | InfiniBand diagnostics |
| ipmitool                | ✗             | ✓           | ✓                | ✗          | ✓      | IPMI management        |
| rclone                  | ✗             | ✓           | ✓                | ✗          | ✓      | Cloud storage sync     |
| rdma-core               | ✗             | ✓           | ✓                | ✗          | ✓      | RDMA support           |
| systemd-journal-remote  | ✗             | ✓           | ✓                | ✗          | ✓      | Remote journal         |
| **Python Base**         |
| python-is-python3       | ✗             | ✓           | ✓                | ✗          | ✓      | Python symlink         |
| python3                 | ✗             | ✓           | ✓                | ✗          | ✓      | Python 3               |
| python3-pip             | ✗             | ✓           | ✓                | ✗          | ✓      | Python package manager |
| python3-venv            | ✗             | ✓           | ✓                | ✗          | ✓      | Python virtualenv      |
| **Build Tools**         |
| build-essential         | ✗             | ✗           | ✗                | ✗          | ✓      | Compiler toolchain     |
| clang                   | ✗             | ✗           | ✗                | ✗          | ✓      | C/C++ compiler         |

## 6. Hypervisor & Virtualization

| Package/Tool | bm-hypervisor | vm-k8s-node | vm-dev-container | vm-service | dt-dev | Notes                      |
| ------------ | ------------- | ----------- | ---------------- | ---------- | ------ | -------------------------- |
| qemu-kvm     | ✓             | ✗           | ✗                | ✗          | ✓      | KVM hypervisor             |
| libvirt      | ✓             | ✗           | ✗                | ✗          | ✓      | Virtualization API         |
| bridge-utils | ✓             | ✗           | ✗                | ✗          | ✓      | Network bridging           |
| virt-manager | ✓             | ✗           | ✗                | ✗          | ✓      | GUI for libvirt (optional) |

## 7. Storage & Filesystems

| Package/Tool      | bm-hypervisor | vm-k8s-node | vm-dev-container | vm-service | dt-dev | Notes           |
| ----------------- | ------------- | ----------- | ---------------- | ---------- | ------ | --------------- |
| zfsutils-linux    | ✓             | ✗           | ✗                | ✗          | ✓      | ZFS filesystem  |
| mdadm             | ✓             | ✗           | ✗                | ✗          | ✓      | RAID management |
| fio               | ✓             | ✗           | ✗                | ✗          | ✓      | I/O benchmark   |
| nvme-cli          | ✓             | ✗           | ✗                | ✗          | ✓      | NVMe management |
| pciutils          | ✓             | ✗           | ✗                | ✗          | ✓      | PCI utilities   |
| nfs-kernel-server | ✓             | ✗           | ✗                | ✗          | ✓      | NFS server      |
| nfs-common        | ✓             | ✓           | ✓                | ✓          | ✓      | NFS client      |

## 8. Container & Orchestration

| Package/Tool      | bm-hypervisor | vm-k8s-node | vm-dev-container | vm-service | dt-dev | Notes                                |
| ----------------- | ------------- | ----------- | ---------------- | ---------- | ------ | ------------------------------------ |
| Docker            | ✗             | ✗           | ✓                | ✗          | ✓      | Container runtime                    |
| k3s               | ✗             | ✓           | ✗                | ✗          | ✗      | Lightweight Kubernetes               |
| Dev Container CLI | ✗             | ✗           | ✓                | ✗          | ✓      | VS Code Dev Containers (to be added) |

## 9. Development Languages & Tools

| Package/Tool    | bm-hypervisor | vm-k8s-node | vm-dev-container | vm-service | dt-dev | Notes                   |
| --------------- | ------------- | ----------- | ---------------- | ---------- | ------ | ----------------------- |
| **Rust**        |
| rust/cargo      | ✗             | ✗           | ✗                | ✗          | ✓      | Rust toolchain          |
| **Python**      |
| uv              | ✗             | ✗           | ✗                | ✗          | ✓      | Python package manager  |
| ruff            | ✗             | ✗           | ✗                | ✗          | ✓      | Python linter/formatter |
| mypy            | ✗             | ✗           | ✗                | ✗          | ✓      | Python type checker     |
| pyright         | ✗             | ✗           | ✗                | ✗          | ✓      | Python language server  |
| pylint          | ✗             | ✗           | ✗                | ✗          | ✓      | Python linter           |
| pytest          | ✗             | ✗           | ✗                | ✗          | ✓      | Python testing          |
| pre-commit      | ✗             | ✗           | ✗                | ✗          | ✓      | Git hooks               |
| **Node.js**     |
| Node.js (nvm)   | ✗             | ✗           | ✗                | ✗          | ✓      | Node.js runtime         |
| pnpm            | ✗             | ✗           | ✗                | ✗          | ✓      | Node package manager    |
| **Java**        |
| Java (OpenJDK)  | ✗             | ✗           | ✗                | ✗          | ✓      | Java runtime            |
| **Kotlin**      |
| Kotlin (SDKMAN) | ✗             | ✗           | ✗                | ✗          | ✓      | Kotlin compiler         |
| **Golang**      |
| Go              | ✗             | ✗           | ✗                | ✗          | ✓      | Go runtime              |
| **Shell Tools** |
| shellcheck      | ✗             | ✗           | ✗                | ✗          | ✓      | Shell script linter     |
| shfmt           | ✗             | ✗           | ✗                | ✗          | ✓      | Shell formatter         |

## 10. Cloud CLIs

| Package/Tool     | bm-hypervisor | vm-k8s-node | vm-dev-container | vm-service | dt-dev | Notes                    |
| ---------------- | ------------- | ----------- | ---------------- | ---------- | ------ | ------------------------ |
| AWS CLI          | ✗             | ✗           | ✗                | ✗          | ✓      | AWS command line         |
| GCP CLI (gcloud) | ✗             | ✗           | ✗                | ✗          | ✓      | Google Cloud CLI         |
| Firebase CLI     | ✗             | ✗           | ✗                | ✗          | ✓      | Firebase tools           |
| Terraform        | ✗             | ✗           | ✗                | ✗          | ✓      | Infrastructure as code   |
| Ansible          | ✗             | ✗           | ✗                | ✗          | ✓      | Configuration management |

## 11. Development Tools

| Package/Tool    | bm-hypervisor | vm-k8s-node | vm-dev-container | vm-service | dt-dev | Notes                 |
| --------------- | ------------- | ----------- | ---------------- | ---------- | ------ | --------------------- |
| GitHub CLI (gh) | ✗             | ✗           | ✗                | ✗          | ✓      | GitHub command line   |
| Yazi            | ✗             | ✗           | ✗                | ✗          | ✓      | Terminal file manager |
| Playwright      | ✗             | ✗           | ✗                | ✗          | ✓      | Browser automation    |

## 12. Desktop Environment (Ubuntu)

| Package/Tool                | bm-hypervisor | vm-k8s-node | vm-dev-container | vm-service | dt-dev | Notes                    |
| --------------------------- | ------------- | ----------- | ---------------- | ---------- | ------ | ------------------------ |
| **Window Manager**          |
| Sway                        | ✗             | ✗           | ✗                | ✗          | ✓      | Wayland compositor       |
| wayland-protocols           | ✗             | ✗           | ✗                | ✗          | ✓      | Wayland protocols        |
| xwayland                    | ✗             | ✗           | ✗                | ✗          | ✓      | X11 compatibility        |
| swayidle                    | ✗             | ✗           | ✗                | ✗          | ✓      | Sway idle daemon         |
| swaylock                    | ✗             | ✗           | ✗                | ✗          | ✓      | Screen locker            |
| swayimg                     | ✗             | ✗           | ✗                | ✗          | ✓      | Image viewer             |
| desktop-file-utils          | ✗             | ✗           | ✗                | ✗          | ✓      | Desktop file utils       |
| **Status Bar**              |
| i3status-rs                 | ✗             | ✗           | ✗                | ✗          | ✓      | Status bar (Rust)        |
| **Notifications**           |
| mako-notifier               | ✗             | ✗           | ✗                | ✗          | ✓      | Wayland notifications    |
| **Launcher**                |
| kickoff                     | ✗             | ✗           | ✗                | ✗          | ✓      | Application launcher     |
| **Screen Sharing**          |
| xdg-desktop-portal          | ✗             | ✗           | ✗                | ✗          | ✓      | Desktop portal           |
| xdg-desktop-portal-wlr      | ✗             | ✗           | ✗                | ✗          | ✓      | WLR portal backend       |
| **Audio**                   |
| pipewire                    | ✗             | ✗           | ✗                | ✗          | ✓      | Audio server             |
| pipewire-pulse              | ✗             | ✗           | ✗                | ✗          | ✓      | PulseAudio compatibility |
| pipewire-audio              | ✗             | ✗           | ✗                | ✗          | ✓      | Audio libraries          |
| wireplumber                 | ✗             | ✗           | ✗                | ✗          | ✓      | Audio session manager    |
| pipewire-alsa               | ✗             | ✗           | ✗                | ✗          | ✓      | ALSA compatibility       |
| pulseaudio-module-bluetooth | ✗             | ✗           | ✗                | ✗          | ✓      | Bluetooth audio          |
| **Bluetooth**               |
| bluez                       | ✗             | ✗           | ✗                | ✗          | ✓      | Bluetooth stack          |
| blueman                     | ✗             | ✗           | ✗                | ✗          | ✓      | Bluetooth manager        |
| bluetooth                   | ✗             | ✗           | ✗                | ✗          | ✓      | Bluetooth service        |
| pavucontrol                 | ✗             | ✗           | ✗                | ✗          | ✓      | Audio control            |
| alsa-utils                  | ✗             | ✗           | ✗                | ✗          | ✓      | ALSA utilities           |
| playerctl                   | ✗             | ✗           | ✗                | ✗          | ✓      | Media control            |
| pulsemixer                  | ✗             | ✗           | ✗                | ✗          | ✓      | PulseAudio mixer         |
| **Screenshots**             |
| shotman                     | ✗             | ✗           | ✗                | ✗          | ✓      | Screenshot tool          |
| slurp                       | ✗             | ✗           | ✗                | ✗          | ✓      | Region selector          |
| scdoc                       | ✗             | ✗           | ✗                | ✗          | ✓      | Documentation tool       |
| oculante                    | ✗             | ✗           | ✗                | ✗          | ✓      | Image editor             |
| **Input**                   |
| fcitx5                      | ✗             | ✗           | ✗                | ✗          | ✓      | Input method (Japanese)  |
| fcitx5-mozc                 | ✗             | ✗           | ✗                | ✗          | ✓      | Japanese IME             |
| fcitx5-configtool           | ✗             | ✗           | ✗                | ✗          | ✓      | IME config tool          |
| **Power Management**        |
| tlp                         | ✗             | ✗           | ✗                | ✗          | ✓      | Power management         |
| tlp-rdw                     | ✗             | ✗           | ✗                | ✗          | ✓      | TLP radio device wizard  |
| brightnessctl               | ✗             | ✗           | ✗                | ✗          | ✓      | Brightness control       |
| wl-gammarelay-rs            | ✗             | ✗           | ✗                | ✗          | ✓      | Gamma adjustment         |
| **Network (Desktop)**       |
| systemd-networkd            | ✗             | ✗           | ✗                | ✗          | ✓      | Network manager          |
| WireGuard                   | ✗             | ✗           | ✗                | ✗          | ✓      | VPN                      |
| **Fonts**                   |
| Nerd Fonts                  | ✗             | ✗           | ✗                | ✗          | ✓      | Icon fonts               |
| fonts-noto                  | ✗             | ✗           | ✗                | ✗          | ✓      | Noto fonts               |

## 13. Desktop Applications

| Package/Tool     | bm-hypervisor | vm-k8s-node | vm-dev-container | vm-service | dt-dev | Notes                |
| ---------------- | ------------- | ----------- | ---------------- | ---------- | ------ | -------------------- |
| Starship         | ✗             | ✗           | ✗                | ✗          | ✓      | Prompt               |
| Alacritty        | ✗             | ✗           | ✗                | ✗          | ✓      | Terminal emulator    |
| 1Password (app)  | ✗             | ✗           | ✗                | ✗          | ✓      | Password manager GUI |
| Zed              | ✗             | ✗           | ✗                | ✗          | ✓      | Code editor          |
| Cursor           | ✗             | ✗           | ✗                | ✗          | ✓      | AI code editor       |
| Claude Code      | ✗             | ✗           | ✗                | ✗          | ✓      | AI code assistant    |
| Chrome           | ✗             | ✗           | ✗                | ✗          | ✓      | Web browser          |
| Firefox          | ✗             | ✗           | ✗                | ✗          | ✓      | Web browser          |
| Discord          | ✗             | ✗           | ✗                | ✗          | ✓      | Communication        |
| Zotero           | ✗             | ✗           | ✗                | ✗          | ✓      | Reference manager    |
| Spotify (client) | ✗             | ✗           | ✗                | ✗          | ✓      | Music streaming      |
| Remmina          | ✗             | ✗           | ✗                | ✗          | ✓      | Remote desktop       |

## 14. GPU & ML Tools

| Package/Tool   | bm-hypervisor | vm-k8s-node | vm-dev-container | vm-service | dt-dev | Notes                            |
| -------------- | ------------- | ----------- | ---------------- | ---------- | ------ | -------------------------------- |
| ROCm           | ○             | ✗           | ✗                | ✗          | ✗      | AMD GPU support (if GPU present) |
| amdgpu-dkms    | ○             | ✗           | ✗                | ✗          | ✗      | AMD GPU kernel driver            |
| NVIDIA drivers | ○             | ✗           | ✗                | ✗          | ✗      | NVIDIA GPU (if GPU present)      |

## 15. macOS-Specifics (dt-dev only)

| Package/Tool | bm-hypervisor | vm-k8s-node | vm-dev-container | vm-service | dt-dev | Notes           |
| ------------ | ------------- | ----------- | ---------------- | ---------- | ------ | --------------- |
| Homebrew     | ✗             | ✗           | ✗                | ✗          | ✓      | Package manager |

## 16. Cleanup packages (common)

| Snap removal | ✓ | ✓ | ✓ | ✓ | ✓ | Remove snap |
| Cleanup packages | ✓ | ✓ | ✓ | ✓ | ✓ | Cleanup packages |
