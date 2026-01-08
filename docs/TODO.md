# TODO

## Requirements Overview

I have a home lab consisting of 3 several servers running Ubuntu Server 24.04 minimized, also 2 desktop machines running Ubuntu Server 24.04 minimized with Sway and MacOS as main development environments as below:

- `spacex` - 128GB RAM, Asrock X99, Xeon with 23 cores, 5 SSDs 1TB as RAID 0, 2 HDDs nvmes 1TB each (one for OS, and one another), 1 8TB HDD for data, with Ubuntu 24.04.

- `canarywharth` - 64GB RAM, Rizen 9, 16 cores, 2 nvmes 2TB each with Ubuntu Server 24.04.

- `oslo` - 128GB with ROMED8-2T, Epic with 32 cores, 5 nvmes 2TB each in RAID0, also 1 nvme 2TB for OS Ubuntu Server 24.04. It also has 6 AMD 24GB GPUs.

- `norge` - Lenovo ThinkPad, 8 cores, 96GB RAM, 2TB nvme - Ubuntu Server 24.04 with Sway as the main development desktop at home.

- `power` - MacbookPro M4 - for office development work.

I have the setup scripts for the new Ubuntu and MacOS development machines setup here: https://github.com/ppetroskevicius/tiny-config.

In this repo I want to have simple bash scripts to setup the below types of the development machines:

1. **Bare Metal Hypervisor Hosts (`bm-hypervisor`)**

   - **Description**: Physical servers dedicated to running KVM for hosting VMs. These are the foundation of your lab, optimized for stability and performance without unnecessary software. Suited for high-spec hardware like your Xeon (23 cores/128GB RAM), EPYC (32 cores/GPUs), or Ryzen (16 cores). Runs Ubuntu Server 24.04 minimally.
   - **Key Configurations**: Include KVM (qemu-kvm, libvirt), basic networking (e.g., bridge-utils for VM networking), and storage tools (e.g., LVM/RAID for VM disks). Exclude: Development tools (Rust, Python via uv), prompts (Starship), cloud CLIs (GCP/AWS), containers (Docker/Podman), and apps (Postman). Use your repo's "host" mode, stripped down. Idempotent scripts for setup.
   - **Examples/Use Cases**: Hosting multiple VMs for Kubernetes or services, similar to Proxmox VE setups but on raw Ubuntu.
   - **Nuances/Implications**: GPU passthrough (e.g., for EPYC) via vfio if needed for VMs. Edge case: Firmware updates for hardware compatibility. Implication: High uptime focus—use tools like Cockpit for remote management. This minimalism saves ~20-30% resources compared to bloated installs.

2. **Kubernetes VM Nodes (`vm-k8s-node`)**

   - **Description**: Virtual machines on bare metal KVM hosts, configured as Kubernetes nodes (e.g., master/workers for k3s clusters). Keeps them lightweight for orchestration practice. Ubuntu Server 24.04 guest OS.
   - **Key Configurations**: Include k3s (or full Kubernetes tools like kubeadm for advanced), container runtime (containerd, as k3s default), and basic utils (jq, curl). Exclude: Full dev stacks, Docker (use Podman if needed), Postman, cloud CLIs. Migrate from your repo's "guest" mode to a k3s-specific script.
   - **Examples/Use Cases**: Running a 3-node k3s cluster for testing deployments (e.g., Helm charts), akin to educational labs.
   - **Nuances/Implications**: Differentiate master (`vm-k8s-master`) vs. workers (`vm-k8s-worker`) for HA. Edge case: Networking conflicts—use Calico/Flannel CNI. Implication: Easy scaling but monitor VM overhead (e.g., 2-4 cores per node).

3. **Development Container VM Hosts (`vm-dev-container`)**

   - **Description**: VMs dedicated to running Dev Containers for isolated development (e.g., Python/Node.js environments). Focuses on containerization without Kubernetes overlap. Ubuntu Server 24.04 guest.
   - **Key Configurations**: Include Docker (or Podman for rootless), Dev Container CLI, and tools like Postman for API testing. Exclude: Kubernetes, heavy services (e.g., databases—run those in containers). Build on your repo's "guest" mode, emphasizing container features.
   - **Examples/Use Cases**: Hosting VS Code Dev Containers for multi-lang projects, similar to local Docker but offloaded to VMs for resource isolation.
   - **Nuances/Implications**: Volume mounts for persistence. Edge case: GPU access for ML containers—passthrough from bare metal. Implication: Boosts consistency but adds VM management; use for non-desktop dev.

4. **Service-Specific VMs (`vm-service`)**

   - **Description**: Clean VMs for standalone services like storage (TrueNAS), databases (PostgreSQL, MongoDB), or NFS. Avoids container/Kubernetes bloat for simplicity and performance. Ubuntu Server 24.04.
   - **Key Configurations**: Include service-specific packages (e.g., nfs-kernel-server, postgresql). Exclude: Docker, Kubernetes, dev tools. Use a "clean" mode from your repo, with minimal dotfiles.
   - **Examples/Use Cases**: A TrueNAS VM for shared storage across the lab, or a MongoDB VM for app backends.
   - **Nuances/Implications**: ZFS for TrueNAS requires memory tuning. Edge case: Migration to containers later—design with exportable data. Implication: High reliability but less flexible than Kubernetes-hosted services.

5. **Development Desktops (`dt-dev`)**
   - **Description**: Physical desktops for interactive work, like your ThinkPad (Ubuntu 24.04 with Sway WM) or M4 MacBook Pro (macOS). Full-featured for local dev, including optional KVM/Docker.
   - **Key Configurations**: Include everything—KVM (on Ubuntu), Docker, Postman, languages (Python/Rust/Go via your repo), cloud CLIs, Starship. Use "desktop" mode from tiny-config, with Sway for Ubuntu or native macOS tools.
   - **Examples/Use Cases**: Running local Dev Containers with hot reloading, or prototyping Kubernetes via minikube.
   - **Nuances/Implications**: macOS limitations (no KVM—use Hypervisor.framework). Edge case: Battery life on laptops—optimize with power profiles. Implication: Central for productivity but vulnerable to user errors; use snapshots.

### Naming Conventions

- **General Format**: `[prefix]-[role]-[number]-[optional-tag]`, e.g., `bm-hypervisor-01-epyc` (prefix for type, role for function, number for uniqueness, tag for hardware/OS).

I want to keep the scripts in this repository as simple and as short as possible, rather than overengineered and bloated. I am fine if all of my dot files go into all configurations to keep it simple. Just need to make sure, that the dotfiles do not fail by referencing some packages, that do not exist on some configurations.

## Things to Fix NOW:


