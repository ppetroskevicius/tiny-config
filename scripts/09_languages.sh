#!/usr/bin/env bash
set -euo pipefail
set -x

# ==========================================
# 9. Development Languages & Tools
# ==========================================
install_rust() {
	if ! [ -f "$HOME/.cargo/bin/cargo" ]; then
		curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
		. "$HOME/.cargo/env"
	fi
}

install_uv() {
	if ! command -v uv >/dev/null; then
		curl -LsSf https://astral.sh/uv/install.sh | sh
		source "$HOME/.local/bin/env" 2>/dev/null || true
		uv self update
	fi
}

install_linters_formatters() {
	uv tool install ruff
	uv tool install mypy
	uv tool install pyright
	uv tool install pylint
	uv tool install pytest
	uv tool install pre-commit
	if [ "$OS" = "Darwin" ]; then
		if ! command -v shellcheck >/dev/null; then brew install shellcheck shfmt; fi
	else
		sudo apt install -y shellcheck shfmt
	fi
}

install_node() {
	if ! command -v nvm >/dev/null; then
		curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
	fi
	export NVM_DIR="$HOME/.nvm"
	[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

	nvm install --lts

	if ! command -v pnpm >/dev/null; then
		curl -fsSL https://get.pnpm.io/install.sh | sh -
	fi
	install_playwright_cli
}

install_java() {
	if command -v java >/dev/null; then return 0; fi
	if [ "$OS" = "Darwin" ]; then
		brew install openjdk
		sudo ln -sfn "$(brew --prefix)/opt/openjdk/libexec/openjdk.jdk" /Library/Java/JavaVirtualMachines/openjdk.jdk || true
	else
		sudo apt install -y default-jdk
	fi
}

install_kotlin() {
	if [ ! -d "$HOME/.sdkman" ]; then
		curl -s "https://get.sdkman.io" | bash
	fi
	source "$HOME/.sdkman/bin/sdkman-init.sh"
	if ! command -v kotlin >/dev/null; then sdk install kotlin; fi
}

install_golang() {
	if ! command -v go >/dev/null; then
		if [ "$OS" = "Darwin" ]; then
			brew install go
		else
			sudo apt install -y golang-go
		fi
	fi
}
