# ==========================================
# 1. Core Environment
# ==========================================
export EDITOR='vim'
export CLICOLOR=1

# Build PATH safely (add directories only if they exist)
# Using a function to keep the namespace clean
add_to_path() {
  [ -d "$1" ] && export PATH="$1:$PATH"
}

# Add standard paths
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

# Add machine-specific paths if they exist
add_to_path "$HOME/.npm-global/bin"
add_to_path "$HOME/.cargo/bin"
add_to_path "$HOME/.local/share/pnpm"
add_to_path "/opt/rocm-6.4.0/bin"
add_to_path "$HOME/.lmstudio/bin"

# ==========================================
# 2. Keychains & SSH
# ==========================================
# Only run keychain if installed (Common on all profiles)
if command -v keychain >/dev/null 2>&1; then
  # Only load if the key actually exists
  if [ -f "$HOME/.ssh/id_ed25519" ]; then
    eval "$(keychain --eval --quiet id_ed25519)"
  fi
fi

# ==========================================
# 3. Zsh Framework (Oh-My-Zsh)
# ==========================================
export ZSH="$HOME/.oh-my-zsh"

if [ -f "$ZSH/oh-my-zsh.sh" ]; then
    export ZSH_THEME="robbyrussell"
    setopt histignorealldups

    # Adjust plugins based on installed tools
    plugins=(git zsh-autosuggestions)

    # Only load cloud plugins if tools exist
    command -v terraform >/dev/null && plugins+=(terraform)
    command -v gcloud >/dev/null && plugins+=(gcloud)
    command -v docker >/dev/null && plugins+=(docker docker-compose)

    source $ZSH/oh-my-zsh.sh
fi

# ==========================================
# 4. Standard Aliases
# ==========================================
alias ll='ls -l'
alias la='ls -lA'
alias grep='grep --color=auto'

# Wireguard Aliases (Only if wg-quick exists)
if command -v wg-quick >/dev/null 2>&1; then
    alias vpn_start="sudo wg-quick up gw0"
    alias vpn_stop="sudo wg-quick down gw0"
    alias vpn_status="sudo wg show gw0"
fi

# ==========================================
# 5. Language Environments
# ==========================================

# NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
    . "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
fi

# PNPM
export PNPM_HOME="$HOME/.local/share/pnpm"
# (PATH handling is done in section 1, but environment var is needed)

# Java
if [[ "$(uname -s)" == "Darwin" ]]; then
    if command -v brew >/dev/null; then
        export JAVA_HOME="$(brew --prefix)/opt/openjdk"
    fi
elif [ -d "/usr/lib/jvm/default-java" ]; then
    export JAVA_HOME="/usr/lib/jvm/default-java"
fi
[ -n "$JAVA_HOME" ] && export PATH="$JAVA_HOME/bin:$PATH"

# ==========================================
# 6. Google Cloud (Conditioned)
# ==========================================
# Only load this block if gcloud is installed
if command -v gcloud >/dev/null 2>&1; then

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

    alias gconf='gcloud config list'
    alias gprojects='gcloud projects list'
    alias gauth='gcloud auth list'
    alias gimp='gcloud config get-value auth/impersonate_service_account'
fi

# ==========================================
# 7. Prompt (Starship vs Fallback)
# ==========================================
setopt EXTENDED_HISTORY
export HIST_STAMPS="%F %T "

if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
else
    # Fallback PS1 for machines without Starship (e.g. K8s nodes)
    # Result: user@hostname:~/current/path$
    PS1=$'%n@%m:%~\$ '
fi