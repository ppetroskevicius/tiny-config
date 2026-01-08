# ==========================================
# 1. Homebrew Setup (macOS)
#    Must run first to ensure 'op', 'jq', etc. are found in PATH
# ==========================================
if [[ "$(uname -s)" == "Darwin" ]]; then
	if [[ -x "/opt/homebrew/bin/brew" ]]; then
		eval "$(/opt/homebrew/bin/brew shellenv)"
	elif [[ -x "/usr/local/bin/brew" ]]; then
		eval "$(/usr/local/bin/brew shellenv)"
	fi
fi

# ==========================================
# 2. 1Password Secrets Injection
# ==========================================
# Only attempt if 'op' and 'jq' are installed
if command -v op >/dev/null && command -v jq >/dev/null; then
	# Check if signed in before hanging on a network call.
	# 'op account get' is a fast local check.
	if op account get >/dev/null 2>&1; then

		# Fetch the item JSON once
		# Added '|| true' to prevent crash/hang if network fails
		SECRETS_JSON=$(op item get "ev5xkkud6nr57o24ffzfbfsaou" --vault "build" --format json 2>/dev/null || true)

		if [[ -n "$SECRETS_JSON" ]]; then
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
				# Extract value safely using jq
				value=$(echo "$SECRETS_JSON" | jq -r \
					".fields[] | select(.section.label==\"keys\" and .label==\"$label\") | .value")

				# Only export if value was found (prevents empty env vars)
				if [[ -n "$value" ]]; then
					export "$var_name"="$value"
				fi
			done
		fi
	fi
fi

# ==========================================
# 3. SSH Agent (Keychain)
# ==========================================
if command -v keychain >/dev/null 2>&1; then
	# Only try to add key if it actually exists
	if [ -f "$HOME/.ssh/id_ed25519" ]; then
		eval "$(keychain --eval --quiet id_ed25519)"
	fi
fi

# ==========================================
# 4. GUI / Desktop Environment Settings
#    Only apply if on Linux and Sway is present
# ==========================================
if [[ "$(uname -s)" == "Linux" ]]; then

	# KVM Defaults (Useful on hypervisors too, harmless if missing)
	if [ -e /var/run/libvirt/libvirt-sock ]; then
		export LIBVIRT_DEFAULT_URI="qemu:///system"
	fi

	# Wayland & IME (Strictly for Sway environments)
	if command -v sway >/dev/null; then
		export XDG_CURRENT_DESKTOP=sway
		export MOZ_ENABLE_WAYLAND=1

		# IME configuration (fcitx5)
		export XMODIFIERS=@im=fcitx
		export GTK_IM_MODULE=fcitx
		export QT_IM_MODULE=fcitx
	fi
fi

# ==========================================
# 5. Interactive Shell Config
# ==========================================
if [ -f "$HOME/.zshrc" ]; then
	source "$HOME/.zshrc"
fi
