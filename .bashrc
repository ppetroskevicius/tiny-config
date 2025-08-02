# runs for each non-login interactive shells like alacritty, or terminal in gnome

export PS1="\u@\h:\[\e[0;36m\]\w\[\e[0m\]$ "
export EDITOR='vim'
export CLICOLOR=1

# Initialize nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PATH="$PATH:$HOME/.npm-global/bin:$HOME/.cargo/bin:$HOME/.local/bin:/opt/rocm-6.4.0/bin:/home/fastctl/.lmstudio/bin:$HOME/bin"

# GCloud configuration aliases
alias gdev='gcloud config configurations activate dev'
alias gprod='gcloud config configurations activate prod'
alias gtest='gcloud config configurations activate test'
alias gconfig='gcloud config list'
alias gprojects='gcloud projects list'

eval "$(starship init bash)"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/home/fastctl/.lmstudio/bin:$HOME/bin"
