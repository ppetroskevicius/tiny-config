# Setup Scripts

```
.
├── setup.sh                    # Main entry point (The Controller)
└── scripts/                    # Module directory
    ├── 01_update.sh            # Updates packages
    ├── 02_credentials.sh       # Setup credentials
    ├── 03_shell.sh             # Setup zsh
    ├── 04_dotfiles.sh          # Setup dot files
    ├── 05_system.sh            # Setup Core system utilities
    ├── 06_hypervisor.sh        # Setup KVM
    ├── 07_storage.sh           # Setup Storage utilities
    ├── 08_containers.sh        # Setup Containerization utilities
    ├── 09_languages.sh         # Setup Python, Node, Go, Rust, Java, Kotlin
    ├── 10_cloud.sh             # Setup AWS CLI, GCP CLI, Terraform, Ansible
    ├── 11_desktop.sh           # Setup Ubuntu Sway ddesktop
    ├── 12_desktop_apps.sh      # Setup Alacritty, Firefox, Claude Code
    ├── 13_gpus_ml.sh           # Setup NVidia, AMD GPU drivers and libraries
    ├── 14_cleanup.sh           # Clean-up installation
    └── 15_profiles.sh          # Definition of "dt-dev", "vm-k8s-node"
```
