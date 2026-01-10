#!/usr/bin/env bash
set -euo pipefail
set -x

# 1. Resolve Script Directory (so you can run it from anywhere)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULES_DIR="$SCRIPT_DIR/scripts"

# 2. Define Global Variables (before sourcing modules)
# These are used across multiple modules and must be defined first
OS=$(uname -s)
SOURCE_REPO="https://github.com/ppetroskevicius/tiny-config.git"
TARGET_DIR="$HOME/fun/tiny-config"
CHEZMOI_REPO="https://github.com/ppetroskevicius/dotfiles.git"
OP_ACCOUNT="my"
OP_SSH_KEY_NAME="op://build/my-ssh-key/id_ed25519"
OP_WG_CONFIG_NAME="op://network/wireguard/conf"
NETPLAN_CONFIG="/etc/netplan/50-cloud-init.yaml"
OP_WIFI_SSID="op://network/wifi/ssid"
OP_WIFI_PASS="op://network/wifi/pass"

# Temp dir for downloads (will be set up in 01_update.sh, but declare here for visibility)
tempdir=""

# 3. Source Modules (Order matters for dependencies)
source "$MODULES_DIR/01_update.sh"
source "$MODULES_DIR/02_credentials.sh"
source "$MODULES_DIR/03_shell.sh"
source "$MODULES_DIR/04_dotfiles.sh"
source "$MODULES_DIR/05_system.sh"
source "$MODULES_DIR/06_hypervisor.sh"
source "$MODULES_DIR/07_storage.sh"
source "$MODULES_DIR/08_containers.sh"
source "$MODULES_DIR/09_languages.sh"
source "$MODULES_DIR/10_cloud.sh"
source "$MODULES_DIR/11_desktop.sh"
source "$MODULES_DIR/12_desktop_apps.sh"
source "$MODULES_DIR/13_gpus_ml.sh"
source "$MODULES_DIR/14_cleanup.sh"
source "$MODULES_DIR/15_profiles.sh"

# 4. Main Controller Logic
if [ $# -eq 0 ]; then
	echo "Error: No machine type specified."
	echo "Usage: $0 {bm-hypervisor|vm-k8s-node|vm-dev-container|vm-service|dt-dev}"
	exit 1
fi

# Route arguments to functions defined in scripts/profiles.sh
case "$1" in
"bm-hypervisor") profile_bm_hypervisor ;;
"vm-k8s-node") profile_vm_k8s_node ;;
"vm-dev-container") profile_vm_dev_container ;;
"vm-service") profile_vm_service ;;
"dt-dev") profile_dt_dev ;;
*)
	echo "Error: Invalid machine type '$1'"
	exit 1
	;;
esac

echo ">>> Setup for '$1' completed successfully!"
