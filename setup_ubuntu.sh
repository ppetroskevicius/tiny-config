#!/usr/bin/env bash
set -euo pipefail
set -x

# Timer for completion tracking
SECONDS=0
SETUP_TYPE=${1:-"host"} # Options: host, guest, desktop

source ./install_common_dependencies.sh
source ./install_python_dependencies.sh
source ./install_ubuntu_dependencies.sh

update_packages() {
  sudo apt update && sudo apt upgrade -y
}

cleanup_all() {
  sudo apt autoremove -y
  sudo apt clean -y

  # Clean up old kernels
  sudo dpkg -l 'linux-*' | sed '/^ii/!d;/'"$(uname -r | sed "s/\(.*\)-\([^0-9]\+\)/\1/")"'/d;s/^[^ ]* [^ ]* \([^ ]*\).*/\1/;/[0-9]/!d' | xargs sudo apt -y purge || true

  # Clean up temporary files
  sudo rm -rf /tmp/*
  sudo journalctl --vacuum-time=120d
}

# Main execution
main() {

  # Common packges
  update_packages
  install_packages_common
  setup_1password_cli
  setup_credentials
  install_zsh
  install_dotfiles
  setup_timezone

  case "$SETUP_TYPE" in
    "host")
      echo "Performing host (minimal) setup..."
      install_packages_host
      install_docker
      install_podman
      ;;
    "guest")
      echo "Performing guest setup..."
      install_packages_guest
      install_rust
      install_uv
      install_linters_formatters
      install_starship
      ;;
    "gpu")
      install_ollama
      ;;
    "desktop")
      echo "Performing desktop setup..."
      # setup desktop environment
      setup_netplan
      install_wireguard
      install_node
      # Playwright CLI (also installs runtime libraries)
      install_playwright_cli
      install_java
      install_aws_cli
      install_gcp_cli
      install_firebase_cli
      install_terraform_cli
      install_alacritty_app
      setup_bluetooth_audio
      setup_sway_wayland
      install_nerd_fonts
      install_i3status-rs
      install_screenshots
      install_notifications
      install_kickoff
      setup_power_management
      setup_brightness
      setup_gamma
      setup_japanese
      remove_snap
      # setup desktop applications
      install_1password_app
      install_zed_app
      install_cursor_app
      install_claude_code_app
      install_windsurf_app
      install_chrome_app
      install_discord_app
      install_zotero_app
      install_spotify_app
      install_spotify_player
      install_remote_desktop
      ;;
    *)
      log "Error: Please specify 'host', 'guest', 'gpu' or 'desktop'"
      exit 1
      ;;
  esac

  cleanup_all
}

main
echo "[ ] Ubuntu setup completed in t=$SECONDS seconds"
