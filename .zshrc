# runs for each tmux session, window and pane

PS1=$'%n@%m:\e[0;36m%~\e[0m$ '
export EDITOR='vim'
export CLICOLOR=1

# fix brew on mac
[[ $(uname -s) == "Darwin" ]] && { [[ $(uname -m) == "arm64" ]] && eval "$(/opt/homebrew/bin/brew shellenv)" || eval "$(/usr/local/bin/brew shellenv)"; }

# oh-my-zsh configuration
ZSH_THEME="robbyrussell"
setopt histignorealldups
source $ZSH/oh-my-zsh.sh

# sign-in into 1password
export OP_ACCOUNT=my.1password.com
eval $(op signin)

alias ll='ls -la'
alias alias la='ls -A'           # Show hidden, but not . and ..
alias grep='grep --color=auto'

# venv activater
cd() {
  builtin cd "$@"

  if [[ -n "$VIRTUAL_ENV" && "$PWD" != "$(realpath $VIRTUAL_ENV/../)"* ]]; then
    deactivate 2> /dev/null
  fi

  current_dir="$PWD"
  while [[ "$current_dir" != "/" ]]; do
    if [[ -f "$current_dir/.venv/bin/activate" ]]; then
      unset PYTHONPATH
      source "$current_dir/.venv/bin/activate"
      break
    fi
    current_dir="$(dirname "$current_dir")"
  done
}
cd $PWD # for new tmux sessions

# reset specified branch to match remote
nuke() {
    if [ -z "$1" ]; then
        echo "specify a branch"
        return 1
    fi

    # Reset local branch to exactly match remote
    git fetch origin $1                        # Get latest from remote
    git checkout -f $1                         # Force switch to branch
    git reset --hard origin/$1                 # Reset to remote version
    git clean -df                              # Delete untracked files
    git submodule update --init --recursive    # Update all submodules
    git submodule foreach git reset --hard     # Discard all local changes in submodule
    git submodule foreach git clean -df        # Remove untracked directories and files
}
