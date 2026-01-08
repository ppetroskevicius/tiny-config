#!/usr/bin/env bash
# shellcheck shell=bash
# Runs for login sessions

if command -v op >/dev/null; then
	if ! op whoami >/dev/null 2>&1; then
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
		"MISTRAL_API_KEY:mistral-api-key"
		"GEMINI_API_KEY:gemini-api-key"
		"GROQ_API_KEY:groq-api-key"
		"DEEPSEEK_API_KEY:deepseek-api-key"
		"TOGETHER_API_KEY:together-api-key"
		"PINECONE_API_KEY:pinecone-api-key"
		"TRIEVE_API_KEY:trieve-api-key"
		"VAPI_API_KEY:vapi-api-key"
		"FIRECRAWL_API_KEY:firecrawl-api-key"
		"QDRANT_API_KEY:qdrant-api-key"
		"QDRANT_URL:qdrant-url"
		"VITE_MAPBOX_TOKEN:mapbox-token"
		"GEOAPIFY_API_KEY:geoapify-api-key"
		"GOOGLE_MAPS_API_KEY:google-maps-api-key"
		"GCP_DEV_PROJECT_ID:gcp-dev-project-id"
		"GCP_TEST_PROJECT_ID:gcp-test-project-id"
		"GCP_PROD_PROJECT_ID:gcp-prod-project-id"
		"GCP_DEMO_PROJECT_ID:gcp-demo-project-id"
		"GCP_DEV_DEVELOPER_SA:gcp-dev-developer-sa"
		"GCP_DEV_TERRAFORM_SA:gcp-dev-terraform-sa"
		"GCP_TEST_DEVELOPER_SA:gcp-test-developer-sa"
		"GCP_TEST_TERRAFORM_SA:gcp-test-terraform-sa"
		"GCP_PROD_DEVELOPER_SA:gcp-prod-developer-sa"
		"GCP_DEMO_DEVELOPER_SA:gcp-demo-developer-sa"
		"GCP_PROD_TERRAFORM_SA:gcp-prod-terraform-sa"
		"GCP_DEMO_TERRAFORM_SA:gcp-demo-terraform-sa"
		"I3RS_GITHUB_TOKEN:i3rs-github-token"
		"REPLICATE_API_TOKEN:replicate-api-token"
		"SENDGRID_API_KEY:sendgrid-api-key"
		"SLACK_INCOMING_WEBHOOK_URL:slack-incoming-webhook-url"
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

# for Wayland/Sway desktop environment
if [[ "$(uname -s)" == "Linux" ]] && command -v sway >/dev/null; then
	export XDG_CURRENT_DESKTOP=sway
fi

# for KVM
export LIBVIRT_DEFAULT_URI="qemu:///system"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/home/fastctl/.lmstudio/bin"

# shellcheck source=/dev/null
source "$HOME"/.bashrc
