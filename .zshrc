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

# --- GCP State Management Functions for Starship ---

# Set Environment (dev, test, prod)
gdev() {
    gcloud config configurations activate dev
    export GCP_ENV="dev"
    gowner # Default to owner identity when switching envs
}
gtest() {
    gcloud config configurations activate test
    export GCP_ENV="test"
    gowner
}
gprod() {
    gcloud config configurations activate prod
    export GCP_ENV="prod"
    gowner
}

# Set Identity (tf, sa, owner)
gdev-tf() { gdev && gcloud config set auth/impersonate_service_account $GCP_DEV_TERRAFORM_SA && export GCP_IDENTITY="tf"; }
gdev-sa() { gdev && gcloud config set auth/impersonate_service_account $GCP_DEV_DEVELOPER_SA && export GCP_IDENTITY="sa"; }

gtest-tf() { gtest && gcloud config set auth/impersonate_service_account $GCP_TEST_TERRAFORM_SA && export GCP_IDENTITY="tf"; }
gtest-sa() { gtest && gcloud config set auth/impersonate_service_account $GCP_TEST_DEVELOPER_SA && export GCP_IDENTITY="sa"; }

gprod-tf() { gprod && gcloud config set auth/impersonate_service_account $GCP_PROD_TERRAFORM_SA && export GCP_IDENTITY="tf"; }
gprod-sa() { gprod && gcloud config set auth/impersonate_service_account $GCP_PROD_DEVELOPER_SA && export GCP_IDENTITY="sa"; }

# Return to Owner identity
gowner() {
    gcloud config unset auth/impersonate_service_account >/dev/null 2>&1
    export GCP_IDENTITY="owner"
}

# Utility aliases (can remain as is)
alias gconf='gcloud config list'
alias gprojects='gcloud projects list'
alias gauth='gcloud auth list' # who am i
alias gimp='gcloud config get-value auth/impersonate_service_account' # check which service account we are impersonating

# Activate the default environment
gdev-sa

# --- End GCP Section ---

eval "$(starship init zsh)"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/home/fastctl/.lmstudio/bin:$HOME/bin"
