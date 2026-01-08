#!/usr/bin/env bash
set -euo pipefail
set -x

# ==========================================
# 10. Cloud CLIs and Dev Tools
# ==========================================
install_aws_cli() {
	if ! command -v aws >/dev/null; then
		if [ "$OS" = "Darwin" ]; then
			curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "awscliv2.pkg"
			sudo installer -pkg awscliv2.pkg -target /
			rm -f awscliv2.pkg
		else
			curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
			unzip awscliv2.zip
			sudo ./aws/install
			rm -rf awscliv2.zip aws
		fi
	fi
}

install_gcp_cli() {
	if ! command -v gcloud >/dev/null; then
		if [ "$OS" = "Darwin" ]; then
			brew install --cask google-cloud-sdk
		else
			echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list >/dev/null
			curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor --yes -o /usr/share/keyrings/cloud.google.gpg
			sudo apt-get update && sudo apt-get install -y google-cloud-cli
		fi
	fi
}

install_firebase_cli() {
	if ! command -v firebase >/dev/null; then
		if command -v pnpm >/dev/null; then pnpm add -g firebase-tools; fi
	fi
}

install_terraform_cli() {
	if ! command -v terraform >/dev/null; then
		if [ "$OS" = "Darwin" ]; then
			brew tap hashicorp/tap
			brew install hashicorp/tap/terraform
		else
			wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
			echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
			sudo apt update && sudo apt install terraform
		fi
	fi
}

install_github_cli() {
	if ! command -v gh >/dev/null; then
		if [ "$OS" = "Darwin" ]; then
			brew install gh
		else
			sudo apt install gh -y
		fi
	fi
}

install_cloud_tools() {
	install_aws_cli
	install_gcp_cli
	install_firebase_cli
	install_terraform_cli
	install_github_cli
	if [ "$OS" != "Darwin" ]; then sudo apt install ansible -y; fi
}

install_yazi() {
	if ! command -v yazi >/dev/null; then
		if [ "$OS" = "Darwin" ]; then
			brew install yazi ffmpeg sevenzip jq poppler fd ripgrep fzf zoxide resvg imagemagick font-symbols-only-nerd-font
		else
			sudo apt install -y ffmpeg p7zip jq poppler-utils fd-find ripgrep fzf zoxide imagemagick
			cargo install --force yazi-build
		fi
	fi
}

install_playwright_cli() {
	if [ "$(uname -s)" != "Darwin" ]; then
		if ! dpkg -s libwoff1 >/dev/null 2>&1; then
			sudo apt-get update && sudo apt-get install -y libwoff1 libevent-2.1-7 libsecret-1-0 libhyphen0 libmanette-0.2-0
		fi
	fi
	if ! command -v playwright >/dev/null; then
		pnpm add -g playwright
		playwright install chromium firefox webkit || true
	fi
}
