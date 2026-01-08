#!/usr/bin/env bash
set -euo pipefail
set -x

# ==========================================
# 4. Dotfiles (Split: Core vs Desktop)
# ==========================================
clone_dotfiles_repo() {
	if [ ! -d "$TARGET_DIR" ]; then
		git clone "$SOURCE_REPO" "$TARGET_DIR"
	else
		git -C "$TARGET_DIR" pull
	fi
}

install_dotfiles_core() {
	echo ">>> Installing Core CLI Dotfiles..."
	clone_dotfiles_repo
	cd "$TARGET_DIR" || exit 1
	mkdir -p "$HOME/.config"
	rm -f "$HOME/.bash_profile" "$HOME/.bashrc" "$HOME/.zprofile" "$HOME/.zshrc"

	ln -sf "$TARGET_DIR/.sshconfig" "$HOME/.ssh/config"
	ln -sf "$TARGET_DIR/.bash_profile" "$HOME"
	ln -sf "$TARGET_DIR/.bashrc" "$HOME"
	ln -sf "$TARGET_DIR/.zprofile" "$HOME"
	ln -sf "$TARGET_DIR/.zshrc" "$HOME"
	ln -sf "$TARGET_DIR/.tmux.conf" "$HOME"
	ln -sf "$TARGET_DIR/.vimrc" "$HOME"
	ln -sf "$TARGET_DIR/.gitconfig" "$HOME"
	ln -sf "$TARGET_DIR/.starship.toml" "$HOME/.config/starship.toml"

	# Editors (headless configs)
	ln -sf "$TARGET_DIR/.pylintrc" "$HOME/.config/pylintrc"
	mkdir -p "$HOME/.config/ruff"
	ln -sf "$TARGET_DIR/.ruff.toml" "$HOME/.config/ruff/ruff.toml"
}

install_dotfiles_desktop() {
	echo ">>> Installing Desktop GUI Dotfiles..."
	clone_dotfiles_repo

	# Terminal & Window Manager
	ln -sf "$TARGET_DIR/.alacritty.toml" "$HOME"

	if [ "$OS" != "Darwin" ]; then
		mkdir -p "$HOME/.config/sway" "$HOME/.config/mako" "$HOME/.config/i3status-rust"
		ln -sf "$TARGET_DIR/.sway" "$HOME/.config/sway/config"
		ln -sf "$TARGET_DIR/.mako" "$HOME/.config/mako/config"
		ln -sf "$TARGET_DIR/.i3status-rust.toml" "$HOME/.config/i3status-rust/config.toml"
	fi

	rm -rf "$HOME/.config/alacritty"
	git clone https://github.com/alacritty/alacritty-theme "$HOME/.config/alacritty/themes"

	# Editors (GUI)
	mkdir -p "$HOME/.config/zed" "$HOME/.cursor"
	ln -sf "$TARGET_DIR/zed/keymap.json" "$HOME/.config/zed/"
	ln -sf "$TARGET_DIR/zed/settings.json" "$HOME/.config/zed/"
	ln -sf "$TARGET_DIR/.cursor_mcp.json" "$HOME/.cursor/mcp.json"

	if [ "$OS" = "Darwin" ]; then
		mkdir -p "$HOME/Library/Application Support/Cursor/User"
		ln -sf "$TARGET_DIR/.vscode/settings.json" "$HOME/Library/Application Support/Cursor/User/settings.json"
	else
		mkdir -p "$HOME/.config/Cursor/User"
		ln -sf "$TARGET_DIR/.vscode/settings.json" "$HOME/.config/Cursor/User/settings.json"
	fi

	# Cloud Configs (Desktop only)
	mkdir -p "$HOME/.aws"
	ln -sf "$TARGET_DIR/.aws_config" "$HOME/.aws/config"
}
