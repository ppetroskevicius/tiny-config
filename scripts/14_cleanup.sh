#!/usr/bin/env bash
set -euo pipefail
set -x

# ==========================================
# 14. Cleanup
# ==========================================
remove_snap() {
	if [ "$OS" != "Darwin" ]; then
		if command -v snap >/dev/null; then
			sudo apt purge -y snapd
			sudo rm -rf /var/cache/snapd /snap
		fi
	fi
}

cleanup_all() {
	if [ "$OS" = "Darwin" ]; then
		brew cleanup
	else
		sudo apt autoremove -y
		sudo apt clean -y
		remove_snap
	fi
}
