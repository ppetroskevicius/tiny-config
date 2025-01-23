# runs for each non-login interactive shells like alacritty, or terminal in gnome

PS1=$'%n@%m:\e[0;36m%~\e[0m$ '
export EDITOR='vim'
export CLICOLOR=1

export PATH=$HOME/.cargo/bin:$HOME/.local/bin:$PATH

# oh-my-zsh configuration
export ZSH="$HOME/.oh-my-zsh"
export ZSH_THEME="robbyrussell"
setopt histignorealldups
plugins=(git zsh-autosuggestions)
source $ZSH/oh-my-zsh.sh

alias ll='ls -la'
alias la='ls -A' # Show hidden, but not . and ..
alias grep='grep --color=auto'
