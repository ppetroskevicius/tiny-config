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
alias gtest='gcloud config configurations activate test'
alias gprod='gcloud config configurations activate prod'
alias gconfig='gcloud config list'
alias gprojects='gcloud projects list'

# This command tells ADC to use the *-sa-dev identity for all future commands
alias gdev-tf='gcloud config set auth/impersonate_service_account $GCP_DEV_TERRAFORM_SA'
alias gdev-sa='gcloud config set auth/impersonate_service_account $GCP_DEV_DEVELOPER_SA'
alias gtest-tf='gcloud config set auth/impersonate_service_account $GCP_TEST_TERRAFORM_SA'
alias gtest-sa='gcloud config set auth/impersonate_service_account $GCP_TEST_DEVELOPER_SA'
alias gprod-tf='gcloud config set auth/impersonate_service_account $GCP_PROD_TERRAFORM_SA'
alias gprod-sa='gcloud config set auth/impersonate_service_account $GCP_PROD_DEVELOPER_SA'

# Stop impersonating and return to your user credentials
alias gowner='gcloud config unset auth/impersonate_service_account'

# Detailed status check
gwhoami() {
    echo "--- Active Configuration ---"
    gcloud config list --format="table(core.project, compute.region, compute.zone)"
    echo "\n--- Authentication State ---"
    gcloud auth list
    IMPERSONATED_SA=$(gcloud config get-value auth/impersonate_service_account 2>/dev/null)
    if [ -n "$IMPERSONATED_SA" ]; then
        echo "\n\033[1;33mCurrently Impersonating:\033[0m $IMPERSONATED_SA"
    else
        echo "\n\033[1;32mActing as primary user.\033[0m"
    fi
}

eval "$(starship init bash)"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/home/fastctl/.lmstudio/bin:$HOME/bin"
