#!/usr/bin/env bash
set -euo pipefail
set -x

# ==========================================
# 5. Core System Packages
# ==========================================
install_basic_utilities() {
	echo ">>> Installing Basic Utilities..."
	if [ "$OS" = "Darwin" ]; then
		brew install vim tmux git htop unzip netcat jq coreutils
	else
		dpkg -l vim tmux git keychain htop unzip netcat-openbsd locales direnv >/dev/null 2>&1 ||
			sudo apt install -y vim tmux git keychain htop unzip netcat-openbsd locales direnv
	fi
}

install_system_monitoring() {
	echo ">>> Installing System Monitoring..."
	if [ "$OS" = "Darwin" ]; then
		brew install inxi
		# btop, nvtop can be brew installed if desired: brew install btop nvtop
	else
		dpkg -l btop nvtop inxi lm-sensors >/dev/null 2>&1 ||
			sudo apt install -y btop nvtop inxi lm-sensors
	fi
}

install_file_text_utilities() {
	if [ "$OS" = "Darwin" ]; then
		brew install ripgrep fd git-lfs jq
	else
		dpkg -l csvtool fd-find file ripgrep rsync jq jc >/dev/null 2>&1 ||
			sudo apt install -y csvtool fd-find file ripgrep rsync jq jc
	fi
}

install_system_info_utilities() {
	if [ "$OS" != "Darwin" ]; then
		dpkg -l lshw lsof man-db parallel time >/dev/null 2>&1 ||
			sudo apt install -y lshw lsof man-db parallel time
	fi
}

install_network_utilities() {
	if [ "$OS" != "Darwin" ]; then
		dpkg -l infiniband-diags ipmitool rclone rdma-core systemd-journal-remote >/dev/null 2>&1 ||
			sudo apt install -y infiniband-diags ipmitool rclone rdma-core systemd-journal-remote
	fi
}

install_python_base() {
	if [ "$OS" != "Darwin" ]; then
		dpkg -l python3 python3-pip python3-venv python-is-python3 >/dev/null 2>&1 ||
			sudo apt install -y python3 python3-pip python3-venv python-is-python3
	fi
}

install_build_tools() {
	if [ "$OS" != "Darwin" ]; then
		dpkg -l build-essential clang >/dev/null 2>&1 ||
			sudo apt install -y build-essential clang
	fi
}
