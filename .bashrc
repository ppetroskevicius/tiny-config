# runs for each tmux session, window and pane

export BASH_SILENCE_DEPRECATION_WARNING=1

export PS1="\u@\h:\[\e[0;36m\]\w\[\e[0m\]$ "
export EDITOR='vim'
export CLICOLOR=1

[[ $(uname -s) == "Darwin" ]] && { [[ $(uname -m) == "arm64" ]] && eval "$(/opt/homebrew/bin/brew shellenv)" || eval "$(/usr/local/bin/brew shellenv)"; }
