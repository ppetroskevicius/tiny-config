#!/usr/bin/env bash
set -euo pipefail
set -x

# ==========================================
# 13. GPU & ML Tools
# ==========================================
install_ollama() {
	if ! command -v ollama >/dev/null; then
		curl -fsSL https://ollama.com/install.sh | sh
	fi
}

install_gpu_ml_tools() {
	# Only if NVIDIA card is present
	if [ "$OS" != "Darwin" ]; then
		if lspci | grep -i nvidia >/dev/null; then
			sudo apt install -y nvidia-driver-550
		fi
	fi
	install_ollama
}
