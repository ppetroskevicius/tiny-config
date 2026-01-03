# SSH Multi-Account Setup for GitHub

Add private and work keys to ssh agent

```sh
# Start the ssh-agent if it's not already running
eval "$(ssh-agent -s)"

# Add your private key
ssh-add --apple-use-keychain ~/.ssh/id_ed25519

# Add your work key
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_work
```

Cloning repositories

```sh
git clone git@github.com:USERNAME/REPO.git
git clone git@github.com-work:WORKUSERNAME/REPO.git
```

Changing the remote URL for an existing repository:

```sh
git remote set-url origin git@github.com:USERNAME/REPO.git
git remote set-url origin git@github.com-work:WORKUSERNAME/REPO.git
```
