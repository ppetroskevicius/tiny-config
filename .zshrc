# runs for each non-login interactive shells like alacritty, or terminal in gnome

PS1=$'%n@%m:\e[0;36m%~\e[0m$ '
export EDITOR='vim'
export CLICOLOR=1

# Initialize nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PATH="$PATH:$HOME/.npm-global/bin:$HOME/.cargo/bin:$HOME/.local/bin:/opt/rocm-6.4.0/bin:/home/fastctl/.lmstudio/bin:$HOME/bin"

# Load keychain and add SSH key if not already added
if command -v keychain >/dev/null 2>&1; then
  eval "$(keychain --eval --quiet id_ed25519)"
fi

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

setopt EXTENDED_HISTORY          # store timestamp with every command
export HIST_STAMPS="%F %T "      # how “history” will print it: YYYY-MM-DD HH:MM:SS

# --- GCP State Management Functions for Starship ---

gset() {
    # --- 1. Define local variables and parse arguments ---
    local env=$1
    local identity=${2:-owner} # Default to 'owner' if identity isn't provided
    local project_id_var="GCP_${(U)env}_PROJECT_ID"
    local project_id=${(P)project_id_var}

    # --- 2. Validate environment and project ID ---
    if [[ -z "$env" ]]; then
        echo "🔴 Usage: gcp-set <env> [identity]"
        echo "   env:      dev, test, prod"
        echo "   identity: owner, tf, sa (defaults to owner)"
        return 1
    fi

    if [[ -z "$project_id" ]]; then
        echo "🔴 Error: Project ID for environment '$env' is not set."
        echo "   Please export the variable '$project_id_var'."
        return 1
    fi

    # --- 3. Activate gcloud configuration and set ADC Quota Project ---
    echo "🔄 Switching to environment: ${(U)env}"
    gcloud config configurations activate "$env" >/dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        echo "🔴 Error: Failed to activate gcloud configuration '$env'."
        return 1
    fi

    # THIS IS THE KEY ADDITION
    # It automatically sets the quota project based on the active config.
    echo "🔧 Setting ADC quota project to: $project_id"
    gcloud auth application-default set-quota-project "$project_id" >/dev/null 2>&1

    # --- 4. Set identity (impersonation) ---
    local sa_email=""
    case "$identity" in
        tf)
            local sa_var="GCP_${(U)env}_TERRAFORM_SA"
            sa_email=${(P)sa_var}
            echo "👤 Impersonating Terraform SA..."
            ;;
        sa)
            local sa_var="GCP_${(U)env}_DEVELOPER_SA"
            sa_email=${(P)sa_var}
            echo "👤 Impersonating Developer SA..."
            ;;
        owner)
            echo "👑 Using owner account."
            gcloud config unset auth/impersonate_service_account >/dev/null 2>&1
            ;;
        *)
            echo "🔴 Error: Unknown identity '$identity'."
            return 1
            ;;
    esac

    if [[ -n "$sa_email" ]]; then
        if [[ -z "$sa_email" ]]; then
            echo "🔴 Error: Service account for '$identity' in '$env' is not set."
            return 1
        fi
        gcloud config set auth/impersonate_service_account "$sa_email" >/dev/null 2>&1
    fi

    # --- 5. Set environment variables for Starship prompt ---
    export GCP_ENV="$env"
    export GCP_IDENTITY="$identity"
    echo "✅ Done. Active context: ${(U)env} as ${(U)identity}"
}

# --- Utility aliases (can remain as is) ---
alias gconf='gcloud config list'
alias gprojects='gcloud projects list'
alias gauth='gcloud auth list'
alias gimp='gcloud config get-value auth/impersonate_service_account'

# --- Set a default environment on shell startup ---
# gset dev sa

# --- End GCP Section ---

eval "$(starship init zsh)"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/home/fastctl/.lmstudio/bin:$HOME/bin"

# --- Java environment ---
if [[ "$(uname -s)" == "Darwin" ]]; then
  export JAVA_HOME="$(brew --prefix)/opt/openjdk"
else
  export JAVA_HOME="/usr/lib/jvm/default-java"
fi
export PATH="$JAVA_HOME/bin:$PATH"
