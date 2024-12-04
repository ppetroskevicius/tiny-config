# Runs for login sessions

if command -v op > /dev/null; then
  eval "$(op signin --account my)"

  OP_OPENAI_KEY="op://build/openai-api-key/api key"
  OP_ANTHROPIC_KEY="op://build/anthropic-api-key/api key"
  OP_GH_TOKEN="op://build/github-api-key/api key"

  OPENAI_API_KEY=$(op read "$OP_OPENAI_KEY")
  ANTHROPIC_API_KEY=$(op read "$OP_ANTHROPIC_KEY")
  GH_TOKEN=$(op read "$OP_GH_TOKEN")

  export OPENAI_API_KEY
  export ANTHROPIC_API_KEY
  export GH_TOKEN
fi

eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# for fcitx5
# export XMODIFIERS=@im=fcitx
# export GTK_IM_MODULE=fcitx
# export QT_IM_MODULE=fcitx
export INPUT_METHOD=fcitx

# for KVM
export LIBVIRT_DEFAULT_URI="qemu:///system"

source "$HOME"/.bashrc

. "$HOME"/.cargo/env

. "$HOME"/.local/bin/env
