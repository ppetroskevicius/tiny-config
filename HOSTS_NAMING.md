## Home Hosts Lab Naming Conventions

Below structured scheme is adopted for the discoverability and automation (e.g., in Ansible inventories) in the home lab.

**Naming conventions:**

- **General Format**: `[prefix]-[role]-[number]-[optional-tag]`, e.g., `bm-hypervisor-01-epyc` (prefix for type, role for function, number for uniqueness, tag for hardware/OS).
- **Implementation**: Use hostnamectl on Ubuntu; automate in scripts. Nuances: Avoid spaces/uppercase for compatibility. Implications: Eases troubleshooting (e.g., ping bm-hypervisor-01) and inventory management.

**Machine Types:**

- `bm-hypervisor`: Bare metal hypervisor hosts (KVM, storage tools)
- `vm-k8s-node`: Kubernetes VM nodes (k3s, containerd)
- `vm-dev-container`: Development container VM hosts (Docker, Dev Container CLI)
- `vm-service`: Service-specific VMs (minimal, service packages)
- `dt-dev`: Development desktops (full-featured, all tools)

**Examples:**

- `bm-hypervisor-01` - `spacex`
- `bm-hypervisor-02` - `canarywharf`
- `bm-hypervisor-03` - `oslo`
- `vm-k8s-node-01`
- `vm-dev-container-01`
- `vm-service-01`
- `dt-dev-01` - `norge`
- `dt-dev-02` - `kafka`
- `dt-dev-03` - `power`
