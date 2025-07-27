#!/usr/bin/env bash
set -euo pipefail

# GCP Configuration Setup Script
# Sets up gcloud CLI configurations for dev, test, and prod environments
#
# Prerequisites:
# 1. Run setup_ubuntu.sh first (installs gcloud CLI)
# 2. Run: gcloud auth login (to authenticate with Google Cloud)
# 3. Set environment variables: GCP_DEV_PROJECT_ID, GCP_TEST_PROJECT_ID, GCP_PROD_PROJECT_ID

# Check prerequisites
command -v gcloud >/dev/null 2>&1 || { echo "❌ gcloud CLI not found. Run setup_ubuntu.sh first."; exit 1; }
gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q . || { echo "❌ No active authentication. Run: gcloud auth login"; exit 1; }

# Validate environment variables
[[ -n "${GCP_DEV_PROJECT_ID:-}" && -n "${GCP_TEST_PROJECT_ID:-}" && -n "${GCP_PROD_PROJECT_ID:-}" ]] || {
    echo "❌ Set GCP_DEV_PROJECT_ID, GCP_TEST_PROJECT_ID, GCP_PROD_PROJECT_ID environment variables"
    exit 1
}

# Get current account
CURRENT_ACCOUNT=$(gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -1)

# Verify project access
for project in "$GCP_DEV_PROJECT_ID" "$GCP_TEST_PROJECT_ID" "$GCP_PROD_PROJECT_ID"; do
    gcloud projects describe "$project" --format="value(projectId)" >/dev/null 2>&1 || {
        echo "❌ No access to project: $project"
        exit 1
    }
done

# Create and configure environments
for env in dev test prod; do
    project_var="GCP_${env^^}_PROJECT_ID"
    project="${!project_var}"

    gcloud config configurations create "$env" 2>/dev/null || true
    gcloud config set project "$project" --configuration="$env"
    gcloud config set account "$CURRENT_ACCOUNT" --configuration="$env"
done

# Set dev as default
gcloud config configurations activate dev

echo "✅ GCP configurations ready: dev, test, prod"
echo "📋 Current: $(gcloud config get-value project)"
echo "👤 Account: $CURRENT_ACCOUNT"
