# Runs only for login session

if command -v op > /dev/null; then
  if ! op whoami > /dev/null 2>&1; then
    eval "$(op signin --account my)"
  fi

  SECRETS_JSON=$(op item get "ev5xkkud6nr57o24ffzfbfsaou" --vault "build" --format json)

  OPENAI_API_KEY=$(echo "$SECRETS_JSON" | jq -r '.fields[] | select(.section.label=="keys" and .label=="openai-api-key") | .value')
  ANTHROPIC_API_KEY=$(echo "$SECRETS_JSON" | jq -r '.fields[] | select(.section.label=="keys" and .label=="anthropic-api-key") | .value')
  PINECONE_API_KEY=$(echo "$SECRETS_JSON" | jq -r '.fields[] | select(.section.label=="keys" and .label=="pinecone-api-key") | .value')
  MISTRAL_API_KEY=$(echo "$SECRETS_JSON" | jq -r '.fields[] | select(.section.label=="keys" and .label=="mistral-api-key") | .value')
  FASTCTL_API_KEY=$(echo "$SECRETS_JSON" | jq -r '.fields[] | select(.section.label=="keys" and .label=="fastctl-api-key") | .value')
  GH_TOKEN=$(echo "$SECRETS_JSON" | jq -r '.fields[] | select(.section.label=="keys" and .label=="github-api-key") | .value')
  AWS_ACCESS_KEY_ID=$(echo "$SECRETS_JSON" | jq -r '.fields[] | select(.section.label=="keys" and .label=="aws-access-key") | .value')
  AWS_SECRET_ACCESS_KEY=$(echo "$SECRETS_JSON" | jq -r '.fields[] | select(.section.label=="keys" and .label=="aws-secret-access-key") | .value')
  AWS_HOSTED_ZONE_ID=$(echo "$SECRETS_JSON" | jq -r '.fields[] | select(.section.label=="keys" and .label=="hosted-zone") | .value')

  export OPENAI_API_KEY
  export ANTHROPIC_API_KEY
  export PINECONE_API_KEY
  export MISTRAL_API_KEY
  export FASTCTL_API_KEY
  export GH_TOKEN
  export AWS_ACCESS_KEY_ID
  export AWS_SECRET_ACCESS_KEY
  export AWS_HOSTED_ZONE_ID
fi

# Load keychain and add SSH key if not already added
eval "$(keychain --eval --quiet id_ed25519)"

# Homebrew PATH setup for macOS
if [[ "$(uname -s)" == "Darwin" ]]; then
  if [[ "$(uname -m)" == "arm64" ]]; then
    BREW_PREFIX="/opt/homebrew"
  else
    BREW_PREFIX="/usr/local"
  fi
  if [[ -x "$BREW_PREFIX/bin/brew" ]]; then
    eval "$("$BREW_PREFIX/bin/brew" shellenv)"
  fi
fi

# for fcitx5
export XMODIFIERS=@im=fcitx
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx

# for KVM
export LIBVIRT_DEFAULT_URI="qemu:///system"

source ~/.zshrc
