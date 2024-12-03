# runs for each non-login interactive shells like alacritty, or terminal in gnome

PS1=$'%n@%m:\e[0;36m%~\e[0m$ '
export EDITOR='vim'
export CLICOLOR=1

export PATH=$HOME/.local/bin:$PATH
. "$HOME/.cargo/env"

# oh-my-zsh configuration
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
setopt histignorealldups
plugins=(git z zsh-autosuggestions)
source $ZSH/oh-my-zsh.sh

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

. "$HOME/.local/bin/env"
