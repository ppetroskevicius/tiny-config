#!/bin/bash

# Bootstrap for the new Ubuntu or Mac machine

# Customizable variables
OP_ACCOUNT="my" # account shorthand in case signing in into multiple accounts
OP_SSH_KEY_NAME="build/my-ssh-key/id_ed25519"
GIT_USERNAME="ppetroskevicius"
GIT_EMAIL="p.petroskevicius@gmail.com"
GIT_REPO="tiny-config"

# Install Homebrew for macOS
if [ "$OSTYPE" == "darwin"* ] && ! command -v brew >/dev/null; then
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install essential packages and tools
if [ "$OSTYPE" == "linux"* ]; then
	sudo apt update
	sudo apt install -y curl unzip openssh-client git software-properties-common
elif [ "$OSTYPE" == "darwin"* ]; then
	brew install git
fi

# Install 1Password CLI if not installed
if ! command -v op >/dev/null; then
	echo "1Password CLI (op) is not installed. Installing..."
	if [ "$OSTYPE" == "linux"* ]; then

		# Add the key for the 1Password apt repository:
		curl -sS https://downloads.1password.com/linux/keys/1password.asc |
			sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg

		# Add the 1Password apt repository:
		echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" |
			sudo tee /etc/apt/sources.list.d/1password.list

		# Add the debsig-verify policy:
		sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/
		curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol |
			sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol
		sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22
		curl -sS https://downloads.1password.com/linux/keys/1password.asc |
			sudo gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg

		# Install 1Password CLI:
		sudo apt update && sudo apt install -y 1password-cli

	elif [ "$OSTYPE" == "darwin"* ]; then
		brew install 1password-cli
	fi
	echo "1Password CLI installed successfully."
fi

# Check that 1Password CLI installed successfully
op --version

# Sign in to 1Password
# Use the eval to save the session token to an environment variable automatically
eval $(op signin --account $OP_ACCOUNT)

# List accounts added to 1Password on this machine
op account list

# Create the .ssh directory if it doesn't exist
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Temporary file to store the SSH key
temp_key=$(mktemp)

# Attempt to retrieve the SSH key
if op read -o "$temp_key" op://$OP_SSH_KEY_NAME; then
	# Check if the temporary file is empty or not
	if [ -s "$temp_key" ]; then
		echo "Successfully retrieved the SSH key."
		# Overwrite the old key
		mv "$temp_key" ~/.ssh/id_ed25519
		chmod 600 ~/.ssh/id_ed25519
		# Generate corresponding public key
		ssh-keygen -y -f ~/.ssh/id_ed25519 >~/.ssh/id_ed25519.pub
	else
		echo "SSH key is empty. Not overwriting the existing key."
		rm -f "$temp_key"
	fi
else
	echo "Failed to retrieve the SSH key."
	rm -f "$temp_key"
fi

# Add the key to the SSH agent
if command -v ssh-add >/dev/null; then
	eval "$(ssh-agent -s)"
	ssh-add -l
	ssh-add ~/.ssh/id_ed25519
	ssh-add -l
	echo "ssh-add is available; added key to the agent succesfully."
else
	echo "ssh-add is not available; skipping addition to SSH agent."
fi

# Git Configuration
git config --global user.name $GIT_USERNAME
git config --global user.email $GIT_EMAIL

# Manually add GitHub's SSH key to the known_hosts file, so that it does not ask when accesing for the first time.
ssh-keyscan github.com >> ~/.ssh/known_hosts

# Run the setup script from private GitHub repository
# git clone git@github.com:$GIT_USERNAME/$GIT_REPO.git
# cd $GIT_REPO
# chmod +x setup.sh
# ./setup_mac.sh
# or
# ./setup_ubuntu.sh

echo "You are all set."
