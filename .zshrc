# runs for each non-login interactive shells like alacritty, or terminal in gnome

PS1=$'%n@%m:\e[0;36m%~\e[0m$ '
export EDITOR='vim'
export CLICOLOR=1

export PATH=$HOME/.npm-global/bin:$HOME/.cargo/bin:$HOME/.local/bin:/opt/rocm-6.4.0/bin:$PATH

# oh-my-zsh configuration
export ZSH="$HOME/.oh-my-zsh"
export ZSH_THEME="robbyrussell"
setopt histignorealldups
plugins=(git zsh-autosuggestions)
source $ZSH/oh-my-zsh.sh

alias ll='ls -l'
alias la='ls -lA' # Show hidden, but not . and ..
alias grep='grep --color=auto'
alias vpn_start="sudo wg-quick up gw0"
alias vpn_stop="sudo wg-quick down gw0"
alias vpn_status="sudo wg show gw0"

eval "$(starship init zsh)"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/home/fastctl/.lmstudio/bin"
