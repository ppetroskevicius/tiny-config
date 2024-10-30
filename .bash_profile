# runs only once per new login session (tmux session, window or pane)

if [[ "$OSTYPE" == "linux"* ]]; then
  # Check if SSH agent is running and start if needed
  if [ -z "$SSH_AUTH_SOCK" ]; then
    echo "SSH agent not running, starting it..."
    eval "$(ssh-agent -s)"
  fi
fi

if [ -f ~/.bashrc ]; then . ~/.bashrc; fi
