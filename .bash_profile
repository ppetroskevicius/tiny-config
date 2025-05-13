# Runs for login sessions

if command -v op > /dev/null; then
  if ! op whoami > /dev/null 2>&1; then
    eval "$(op signin --account my)"
  fi

  SECRETS_JSON=$(op item get "ev5xkkud6nr57o24ffzfbfsaou" --vault "build" --format json)

  # List of environment variable names and their corresponding 1Password labels
  env_vars=(
    "GH_TOKEN:github-api-key"
    "AWS_ACCESS_KEY_ID:aws-access-key"
    "AWS_SECRET_ACCESS_KEY:aws-secret-access-key"
    "AWS_HOSTED_ZONE_ID:aws-hosted-zone"
    "AWS_ACCOUNT_ID:aws-account-id"
    "FASTCTL_API_KEY:fastctl-api-key"
    "OPENAI_API_KEY:openai-api-key"
    "ANTHROPIC_API_KEY:anthropic-api-key"
    "MISTRAL_API_KEY:mistral-api-key"
    "GEMINI_API_KEY:gemini-api-key"
    "GROQ_API_KEY:groq-api-key"
    "DEEPSEEK_API_KEY:deepseek-api-key"
    "TOGETHER_API_KEY:together-api-key"
    "PINECONE_API_KEY:pinecone-api-key"
    "TRIEVE_API_KEY:trieve-api-key"
    "VAPI_API_KEY:vapi-api-key"
  )

  for entry in "${env_vars[@]}"; do
    var_name="${entry%%:*}"
    label="${entry#*:}"
    value=$(echo "$SECRETS_JSON" | jq -r \
      ".fields[] | select(.section.label==\"keys\" and .label==\"$label\") | .value")
    export "$var_name"="$value"
  done
fi

# Load keychain and add SSH key if not already added
eval "$(keychain --eval --quiet id_ed25519)"

# for fcitx5
export XMODIFIERS=@im=fcitx
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx

# for KVM
export LIBVIRT_DEFAULT_URI="qemu:///system"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/home/fastctl/.lmstudio/bin"

source "$HOME"/.bashrc
