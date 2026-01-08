#!/usr/bin/env bash
# Sync Cursor extensions with dotfiles/.vscode/extensions.json
# Removes all extensions not listed in the recommendations

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXTENSIONS_JSON="${SCRIPT_DIR}/dotfiles/.vscode/extensions.json"

if [[ ! -f "$EXTENSIONS_JSON" ]]; then
	echo "Error: dotfiles/.vscode/extensions.json not found at $EXTENSIONS_JSON"
	exit 1
fi

# Extract extension IDs from extensions.json (removing comments and quotes)
RECOMMENDED_EXTENSIONS=$(
	grep -o '"[^"]*"' "$EXTENSIONS_JSON" |
		sed 's/"//g' |
		grep -v '^recommendations$' |
		sort
)

# Get currently installed extensions
INSTALLED_EXTENSIONS=$(cursor --list-extensions | sort)

echo "=== Extension Sync Report ==="
echo ""
echo "Recommended extensions (from dotfiles/.vscode/extensions.json):"
echo "$RECOMMENDED_EXTENSIONS" | nl
echo ""
echo "Currently installed extensions:"
echo "$INSTALLED_EXTENSIONS" | nl
echo ""

# Find extensions to remove (installed but not recommended)
TO_REMOVE=$(comm -23 <(echo "$INSTALLED_EXTENSIONS") <(echo "$RECOMMENDED_EXTENSIONS"))

# Find extensions to install (recommended but not installed)
TO_INSTALL=$(comm -13 <(echo "$INSTALLED_EXTENSIONS") <(echo "$RECOMMENDED_EXTENSIONS"))

if [[ -z "$TO_REMOVE" && -z "$TO_INSTALL" ]]; then
	echo "✓ Extensions are already in sync!"
	exit 0
fi

if [[ -n "$TO_REMOVE" ]]; then
	echo "Extensions to REMOVE (not in extensions.json):"
	echo "$TO_REMOVE" | nl
	echo ""
fi

if [[ -n "$TO_INSTALL" ]]; then
	echo "Extensions to INSTALL (missing from current installation):"
	echo "$TO_INSTALL" | nl
	echo ""
fi

# Ask for confirmation
read -p "Do you want to proceed? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
	echo "Aborted."
	exit 0
fi

# Remove extensions
if [[ -n "$TO_REMOVE" ]]; then
	echo ""
	echo "Removing extensions..."
	while IFS= read -r ext; do
		if [[ -n "$ext" ]]; then
			echo "  Removing: $ext"
			cursor --uninstall-extension "$ext" || echo "    Warning: Failed to remove $ext"
		fi
	done <<<"$TO_REMOVE"
fi

# Install missing extensions
if [[ -n "$TO_INSTALL" ]]; then
	echo ""
	echo "Installing missing extensions..."
	while IFS= read -r ext; do
		if [[ -n "$ext" ]]; then
			echo "  Installing: $ext"
			cursor --install-extension "$ext" || echo "    Warning: Failed to install $ext"
		fi
	done <<<"$TO_INSTALL"
fi

echo ""
echo "✓ Extension sync complete!"
