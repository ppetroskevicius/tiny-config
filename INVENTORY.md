# Package Inventory

This document maps all packages, tools, and configurations to the 5 machine types defined in [TODO.md](TODO.md).

## Machine Types

- **bm-hypervisor**: Bare Metal Hypervisor Hosts (KVM hosts for running VMs)
- **vm-k8s-node**: Kubernetes VM Nodes (k3s master/worker nodes)
- **vm-dev-container**: Development Container VM Hosts (for Dev Containers)
- **vm-service**: Service-Specific VMs (standalone services like NFS, databases)
- **dt-dev**: Development Desktops (physical desktops for interactive work)

## Legend

- ✓ = Included
- ✗ = Excluded (per requirements)
- ○ = Optional/Conditional
- ⚠ = To be added (not in current scripts)
- N/A = Not applicable

## Core System Packages

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
| **Build Tools**         |
| build-essential         | ✗             | ✗           | ✗                | ✗          | ✓      | Compiler toolchain     |
| clang                   | ✗             | ✗           | ✗                | ✗          | ✓      | C/C++ compiler         |
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

## Hypervisor & Virtualization

| Package/Tool | bm-hypervisor | vm-k8s-node | vm-dev-container | vm-service | dt-dev | Notes                      |
| ------------ | ------------- | ----------- | ---------------- | ---------- | ------ | -------------------------- |
| qemu-kvm     | ✓             | ✗           | ✗                | ✗          | ✓      | KVM hypervisor             |
| libvirt      | ✓             | ✗           | ✗                | ✗          | ✓      | Virtualization API         |
| bridge-utils | ✓             | ✗           | ✗                | ✗          | ✓      | Network bridging           |
| virt-manager | ✓             | ✗           | ✗                | ✗          | ✓      | GUI for libvirt (optional) |

## Storage & Filesystems

| Package/Tool      | bm-hypervisor | vm-k8s-node | vm-dev-container | vm-service | dt-dev | Notes           |
| ----------------- | ------------- | ----------- | ---------------- | ---------- | ------ | --------------- |
| zfsutils-linux    | ✓             | ✗           | ✗                | ✗          | ✓      | ZFS filesystem  |
| mdadm             | ✓             | ✗           | ✗                | ✗          | ✓      | RAID management |
| fio               | ✓             | ✗           | ✗                | ✗          | ✓      | I/O benchmark   |
| nvme-cli          | ✓             | ✗           | ✗                | ✗          | ✓      | NVMe management |
| pciutils          | ✓             | ✗           | ✗                | ✗          | ✓      | PCI utilities   |
| nfs-kernel-server | ✓             | ✗           | ✗                | ✗          | ✓      | NFS server      |
| nfs-common        | ✓             | ✓           | ✓                | ✓          | ✓      | NFS client      |

## Container & Orchestration

| Package/Tool      | bm-hypervisor | vm-k8s-node | vm-dev-container | vm-service | dt-dev | Notes                                |
| ----------------- | ------------- | ----------- | ---------------- | ---------- | ------ | ------------------------------------ |
| Docker            | ✗             | ✗           | ✓                | ✗          | ✓      | Container runtime                    |
| k3s               | ✗             | ✓           | ✗                | ✗          | ✗      | Lightweight Kubernetes               |
| Dev Container CLI | ✗             | ✗           | ✓                | ✗          | ✓      | VS Code Dev Containers (to be added) |

## Kubernetes Tools

| Package/Tool | bm-hypervisor | vm-k8s-node | vm-dev-container | vm-service | dt-dev | Notes                             |
| ------------ | ------------- | ----------- | ---------------- | ---------- | ------ | --------------------------------- |
| kubectl      | ✗             | ○           | ✗                | ✗          | ○      | K8s CLI (if not using k3s)        |
| helm         | ✗             | ○           | ✗                | ✗          | ○      | K8s package manager (to be added) |

## Shell & Terminal

| Package/Tool | bm-hypervisor | vm-k8s-node | vm-dev-container | vm-service | dt-dev | Notes                              |
| ------------ | ------------- | ----------- | ---------------- | ---------- | ------ | ---------------------------------- |
| zsh          | ✓             | ✓           | ✓                | ✓          | ✓      | Z shell                            |
| oh-my-zsh    | ✓             | ✓           | ✓                | ✓          | ✓      | Zsh framework                      |
| Starship     | ✗             | ✗           | ✗                | ✗          | ✓      | Prompt (excluded per requirements) |
| Alacritty    | ✗             | ✗           | ✗                | ✗          | ✓      | Terminal emulator                  |

## Development Languages & Tools

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

## Cloud CLIs

| Package/Tool     | bm-hypervisor | vm-k8s-node | vm-dev-container | vm-service | dt-dev | Notes                     |
| ---------------- | ------------- | ----------- | ---------------- | ---------- | ------ | ------------------------- |
| AWS CLI          | ✗             | ✗           | ✗                | ✗          | ✓      | AWS command line          |
| AWS CDK          | ✗             | ✗           | ✗                | ✗          | ✓      | AWS Cloud Development Kit |
| GCP CLI (gcloud) | ✗             | ✗           | ✗                | ✗          | ✓      | Google Cloud CLI          |
| Firebase CLI     | ✗             | ✗           | ✗                | ✗          | ✓      | Firebase tools            |
| Terraform        | ✗             | ✗           | ✗                | ✗          | ✓      | Infrastructure as code    |
| Ansible          | ✗             | ✗           | ✗                | ✗          | ✓      | Configuration management  |

## Development Tools

| Package/Tool    | bm-hypervisor | vm-k8s-node | vm-dev-container | vm-service | dt-dev | Notes                 |
| --------------- | ------------- | ----------- | ---------------- | ---------- | ------ | --------------------- |
| GitHub CLI (gh) | ✗             | ✗           | ✗                | ✗          | ✓      | GitHub command line   |
| Yazi            | ✗             | ✗           | ✗                | ✗          | ✓      | Terminal file manager |
| Playwright      | ✗             | ✗           | ✗                | ✗          | ✓      | Browser automation    |

## Desktop Environment (Ubuntu)

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

## Desktop Applications

| Package/Tool     | bm-hypervisor | vm-k8s-node | vm-dev-container | vm-service | dt-dev | Notes                |
| ---------------- | ------------- | ----------- | ---------------- | ---------- | ------ | -------------------- |
| 1Password (app)  | ✗             | ✗           | ✗                | ✗          | ✓      | Password manager GUI |
| 1Password CLI    | ✓             | ✓           | ✓                | ✓          | ✓      | Password manager CLI |
| Zed              | ✗             | ✗           | ✗                | ✗          | ✓      | Code editor          |
| Cursor           | ✗             | ✗           | ✗                | ✗          | ✓      | AI code editor       |
| Claude Code      | ✗             | ✗           | ✗                | ✗          | ✓      | AI code assistant    |
| Chrome           | ✗             | ✗           | ✗                | ✗          | ✓      | Web browser          |
| Firefox          | ✗             | ✗           | ✗                | ✗          | ✓      | Web browser          |
| Discord          | ✗             | ✗           | ✗                | ✗          | ✓      | Communication        |
| Zotero           | ✗             | ✗           | ✗                | ✗          | ✓      | Reference manager    |
| Spotify (client) | ✗             | ✗           | ✗                | ✗          | ✓      | Music streaming      |
| spotify-player   | ✗             | ✗           | ✗                | ✗          | ✓      | CLI music player     |
| Remmina          | ✗             | ✗           | ✗                | ✗          | ✓      | Remote desktop       |

## Service-Specific Packages

| Package/Tool | bm-hypervisor | vm-k8s-node | vm-dev-container | vm-service | dt-dev | Notes                                     |
| ------------ | ------------- | ----------- | ---------------- | ---------- | ------ | ----------------------------------------- |
| postgresql   | ✗             | ✗           | ✗                | ✓          | ✗      | PostgreSQL database (optional, add later) |
| redis        | ✗             | ✗           | ✗                | ✓          | ✗      | Redis (optional, add later)               |

## GPU & ML Tools

| Package/Tool   | bm-hypervisor | vm-k8s-node | vm-dev-container | vm-service | dt-dev | Notes                            |
| -------------- | ------------- | ----------- | ---------------- | ---------- | ------ | -------------------------------- |
| ROCm           | ○             | ✗           | ✗                | ✗          | ○      | AMD GPU support (if GPU present) |
| amdgpu-dkms    | ○             | ✗           | ✗                | ✗          | ○      | AMD GPU kernel driver            |
| NVIDIA drivers | ○             | ✗           | ✗                | ✗          | ○      | NVIDIA GPU (if GPU present)      |
| Ollama         | ○             | ✗           | ✗                | ✗          | ○      | LLM runtime (GPU optional)       |

## Configuration & Dotfiles

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

## System Configuration

| Package/Tool           | bm-hypervisor | vm-k8s-node | vm-dev-container | vm-service | dt-dev | Notes                          |
| ---------------------- | ------------- | ----------- | ---------------- | ---------- | ------ | ------------------------------ |
| Timezone setup         | ✓             | ✓           | ✓                | ✓          | ✓      | Set to Asia/Tokyo              |
| Credentials (SSH keys) | ✓             | ✓           | ✓                | ✓          | ✓      | From 1Password                 |
| WireGuard config       | ✗             | ✗           | ✗                | ✗          | ✓      | VPN configuration              |
| Snap removal           | ✓             | ✓           | ✓                | ✓          | ✓      | Remove snap (all environments) |

## macOS-Specific (dt-dev only)

| Package/Tool | bm-hypervisor | vm-k8s-node | vm-dev-container | vm-service | dt-dev | Notes           |
| ------------ | ------------- | ----------- | ---------------- | ---------- | ------ | --------------- |
| Homebrew     | ✗             | ✗           | ✗                | ✗          | ✓      | Package manager |

## Summary by Machine Type

### bm-hypervisor

**Purpose**: Physical servers running KVM for hosting VMs

**Includes**:

- Core utilities (vim, tmux, git, htop)
- KVM and libvirt
- Storage tools (ZFS, mdadm, nvme-cli)
- NFS server
- Basic networking
- Hardware monitoring (lm-sensors)
- 1Password CLI, SSH, dotfiles
- Zsh and Oh-My-Zsh
- Snap removal

**Excludes** (per requirements):

- Development tools (Rust, Python via uv, linters)
- Starship prompt
- Cloud CLIs (AWS, GCP, Firebase, Terraform)
- Containers (Docker)
- Desktop applications
- Desktop environment

### vm-k8s-node

**Purpose**: Virtual machines configured as Kubernetes nodes (k3s)

**Includes**:

- Core utilities and monitoring tools
- File/text utilities (jq, ripgrep, fd-find)
- System info tools (lshw, lsof, man-db)
- Network tools (infiniband-diags, ipmitool)
- Python base (python3, pip, venv)
- containerd (k3s default runtime)
- k3s (⚠ to be added)
- 1Password CLI, SSH, dotfiles
- Zsh and Oh-My-Zsh
- Snap removal

**Excludes** (per requirements):

- Full dev stacks (Rust, Python via uv, Node.js, Java)
- Starship prompt
- Docker (use containerd via k3s)
- Cloud CLIs
- Desktop applications

### vm-dev-container

**Purpose**: VMs dedicated to running Dev Containers

**Includes**:

- Core utilities and monitoring tools
- File/text utilities (jq, ripgrep, fd-find)
- Python base (python3, pip, venv)
- Docker
- Dev Container CLI (⚠ to be added)
- 1Password CLI, SSH, dotfiles
- Zsh and Oh-My-Zsh
- Snap removal

**Excludes** (per requirements):

- Kubernetes (k3s, kubeadm)
- Heavy services (databases - run in containers)
- Full dev stacks (Rust, Python via uv, Node.js, Java)
- Starship prompt
- Cloud CLIs
- Desktop applications

### vm-service

**Purpose**: Clean VMs for standalone services (NFS, databases, etc.)

**Includes**:

- Core utilities (minimal)
- Service-specific packages (nfs-kernel-server, etc. - add postgresql/mongodb later if needed)
- Basic monitoring (htop)
- NFS client (if needed)
- 1Password CLI, SSH, dotfiles
- Zsh and Oh-My-Zsh
- Snap removal

**Excludes** (per requirements):

- Docker
- Kubernetes
- Development tools
- Starship prompt
- Cloud CLIs
- Desktop applications
- Most monitoring/development utilities

### dt-dev

**Purpose**: Physical desktops for interactive development work

**Includes**:

- **Everything** from other types (where applicable)
- Full development stacks (Rust, Python via uv, Node.js, Java)
- All cloud CLIs (AWS, GCP, Firebase, Terraform)
- Starship prompt
- Docker
- Desktop environment (Sway on Ubuntu, native macOS)
- All desktop applications
- KVM (on Ubuntu, Homebrew on macOS)
- All development tools and linters (Rust, Python, Node.js, Java, Kotlin, Golang)
- Ansible
- Hardware monitoring (lm-sensors)
- All configuration files
- Snap removal

**Excludes**:

- Service-specific packages (unless needed)
- k3s/Kubernetes (unless using minikube locally)

## Notes

1. **Dotfiles**: Per user preference in TODO.md, all dotfiles go into all configurations. Ensure dotfiles don't fail by referencing packages that don't exist on some configurations.

2. **k3s Installation**: Currently not in scripts - needs to be added for vm-k8s-node.

3. **Dev Container CLI**: Currently not in scripts - needs to be added for vm-dev-container.

4. **GPU Support**: ROCm/NVIDIA drivers are conditional based on hardware presence.

5. **macOS**: dt-dev on macOS uses Homebrew instead of apt. KVM is not available on macOS (use Docker/containers instead).

6. **Service-Specific VMs**: The vm-service type is intentionally minimal - only install what's needed for the specific service.
