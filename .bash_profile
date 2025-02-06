# Runs for login sessions

if command -v op > /dev/null; then
  if ! op whoami > /dev/null 2>&1; then
    eval "$(op signin --account my)"
  fi

  SECRETS_JSON=$(op item get "ev5xkkud6nr57o24ffzfbfsaou" --vault "build" --format json)

  OPENAI_API_KEY=$(echo "$SECRETS_JSON" | jq -r '.fields[] | select(.section.label=="keys" and .label=="openai-api-key") | .value')
  ANTHROPIC_API_KEY=$(echo "$SECRETS_JSON" | jq -r '.fields[] | select(.section.label=="keys" and .label=="anthropic-api-key") | .value')
  GH_TOKEN=$(echo "$SECRETS_JSON" | jq -r '.fields[] | select(.section.label=="keys" and .label=="github-api-key") | .value')
  AWS_ACCESS_KEY_ID=$(echo "$SECRETS_JSON" | jq -r '.fields[] | select(.section.label=="keys" and .label=="aws-access-key") | .value')
  AWS_SECRET_ACCESS_KEY=$(echo "$SECRETS_JSON" | jq -r '.fields[] | select(.section.label=="keys" and .label=="aws-secret-access-key") | .value')

  export OPENAI_API_KEY
  export ANTHROPIC_API_KEY
  export GH_TOKEN
  export AWS_ACCESS_KEY_ID
  export AWS_SECRET_ACCESS_KEY
fi

# Load keychain and add SSH key if not already added
eval "$(keychain --eval --quiet id_ed25519)"

# for fcitx5
export XMODIFIERS=@im=fcitx
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx

# for KVM
export LIBVIRT_DEFAULT_URI="qemu:///system"

source "$HOME"/.bashrc

# Added by LM Studio CLI (lms)
export PATH="$PATH:/home/fastctl/.lmstudio/bin"
