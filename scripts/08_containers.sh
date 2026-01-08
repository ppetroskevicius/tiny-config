#!/usr/bin/env bash
set -euo pipefail
set -x

# ==========================================
# 8. Container & Orchestration
# ==========================================
install_docker() {
	echo ">>> Installing Docker..."
	if ! command -v docker >/dev/null; then
		if [ "$OS" = "Darwin" ]; then
			brew install --cask docker
		else
			sudo apt-get update
			sudo apt-get install -y ca-certificates curl
			sudo install -m 0755 -d /etc/apt/keyrings
			sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
			sudo chmod a+r /etc/apt/keyrings/docker.asc

			echo \
				"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" |
				sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
			sudo apt update

			sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

			sudo groupadd docker || true
			sudo usermod -aG docker "$USER"
			sudo systemctl enable --now docker
		fi
	fi
}

install_k3s() {
	if [ "$OS" != "Darwin" ]; then
		echo ">>> Installing K3s..."
		if ! command -v k3s >/dev/null; then
			curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode 644
			sudo systemctl enable k3s
			sudo systemctl start k3s
		fi
	fi
}

install_dev_container_cli() {
	if ! command -v devcontainer >/dev/null; then
		if command -v pnpm >/dev/null; then
			pnpm add -g @devcontainers/cli
		elif command -v npm >/dev/null; then
			npm install -g @devcontainers/cli
		fi
	fi
}
