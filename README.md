# Automated Machine Setup

## Overview

This repository contains scripts to automate the setup of a new Ubuntu machine
The script installs essential packages, sets up SSH keys, Git, and
1Password CLI. Other setup scripts from the private GitHub repositories could
be run later. This setup aims to have least dependencies and be _tiny_.

Use `zsh` for interactive shell, and `bash` for scripts.

## Prerequisites

- Fresh installation of Ubuntu or macOS on a VM or physical machine.
- Internet connection
- GitHub account

## Create a new VM

1. Create a VM backup.

   `101` - is the VM ID.

   ```bash
   cd /var/lib/vz/dump
   vzdump 101
   ```

2. Restore a VM backup

   `102` - is the new VM ID.

   ```bash
   cd /var/lib/vz/dump
   qmrestore vzdump-qemu-101-YYYY_MM_DD_HH_MM_SS.vma 102
   ```

3. Run the scripts

   ```bash
   curl -O https://raw.githubusercontent.com/ppetroskevicius/bootstrap/main/setup.sh
   chmod +x setup.sh
   ./setup.sh
   ```

## What Does the Script Do?

- Detects the operating system (Ubuntu or macOS)
- Installs essential packages
- Installs Git
- Installs 1Password CLI
- Sets up SSH keys
- Adds public key to `~/.ssh/authorized_keys` for SSH access
- Allows to run other setup scripts later

## Customization

Replace the placeholders in the script with your actual details:

- 1Password account details
- SSH key name in 1Password
- Git username and email

## Contributing

Pull requests are welcome. For major changes, please open an issue first to
discuss what you would like to change.
