#!/usr/bin/env bash
set -euo pipefail

# run below manually ONCE
# gcloud init

# Ensure project IDs are set
: "${GCP_DEV_PROJECT_ID:?}"
: "${GCP_TEST_PROJECT_ID:?}"
: "${GCP_PROD_PROJECT_ID:?}"

# Create and configure dev
gcloud config configurations create dev || true
gcloud config set project "$GCP_DEV_PROJECT_ID" --configuration=dev

# Create and configure test
gcloud config configurations create test || true
gcloud config set project "$GCP_TEST_PROJECT_ID" --configuration=test

# Create and configure prod
gcloud config configurations create prod || true
gcloud config set project "$GCP_PROD_PROJECT_ID" --configuration=prod

echo "GCP configurations set up. Use:"
echo "  gcloud config configurations activate dev|test|prod"
