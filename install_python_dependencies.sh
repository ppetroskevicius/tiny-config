#!/usr/bin/env bash
set -euo pipefail
set -x

OS=$(uname -s)

install_uv() {
	if ! command -v uv >/dev/null; then
		curl -LsSf https://astral.sh/uv/install.sh | sh
		# Source uv environment (adjust path if needed)
		source "$HOME/.local/bin/env" 2>/dev/null || true
		uv self update
	fi
}

install_linters_formatters() {
	# Install Python tools via uv
	uv tool install ruff
	uv tool install mypy
	uv tool install pyright
	uv tool install pylint
	uv tool install pytest
	uv tool install pre-commit
	# Install shell tools
	if [ "$OS" = "Darwin" ]; then
		if ! command -v shellcheck >/dev/null || ! command -v shfmt >/dev/null; then
			brew install shellcheck shfmt
		fi
	else
		if ! dpkg -l shellcheck shfmt >/dev/null 2>&1; then
			sudo apt install -y shellcheck shfmt
		fi
	fi
}
