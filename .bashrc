# runs for each non-login interactive shells like alacritty, or terminal in gnome

export PS1="\u@\h:\[\e[0;36m\]\w\[\e[0m\]$ "
export EDITOR='vim'
export CLICOLOR=1

export PATH=$HOME/.local/bin:$PATH

. "$HOME/.cargo/env"

. "$HOME/.local/bin/env"
