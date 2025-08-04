# runs for each non-login interactive shells like alacritty, or terminal in gnome

PS1=$'%n@%m:\e[0;36m%~\e[0m$ '
export EDITOR='vim'
export CLICOLOR=1

# Initialize nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PATH="$PATH:$HOME/.npm-global/bin:$HOME/.cargo/bin:$HOME/.local/bin:/opt/rocm-6.4.0/bin:/home/fastctl/.lmstudio/bin:$HOME/bin"

# oh-my-zsh configuration
export ZSH="$HOME/.oh-my-zsh"
export ZSH_THEME="robbyrussell"
setopt histignorealldups
plugins=(git zsh-autosuggestions terraform gcloud docker docker-compose)
source $ZSH/oh-my-zsh.sh

alias ll='ls -l'
alias la='ls -lA' # Show hidden, but not . and ..
alias grep='grep --color=auto'
alias vpn_start="sudo wg-quick up gw0"
alias vpn_stop="sudo wg-quick down gw0"
alias vpn_status="sudo wg show gw0"

# GCloud configuration aliases
alias gdev='gcloud config configurations activate dev'
alias gprod='gcloud config configurations activate prod'
alias gtest='gcloud config configurations activate test'
alias gconfig='gcloud config list'
alias gprojects='gcloud projects list'

alias g-tf-mode='gcloud config set auth/impersonate_service_account $GCP_TERRAFORM_SA'
alias g-dev-mode='gcloud config set auth/impersonate_service_account $GCP_DEVELOPER_SA'
alias gwhoami='gcloud auth list'

eval "$(starship init zsh)"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/home/fastctl/.lmstudio/bin:$HOME/bin"
