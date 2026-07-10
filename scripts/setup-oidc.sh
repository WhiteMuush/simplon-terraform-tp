#!/bin/bash

set -euo pipefail

APP_NAME="sp-github-WhiteMuush"
REPO="WhiteMuush/simplon-terraform-tp"

# Créer l'app registration si absente, récupérer son appId
APP_ID=$(az ad app list --display-name "$APP_NAME" --query "[0].appId" -o tsv)
if [ -z "$APP_ID" ]; then
  APP_ID=$(az ad app create --display-name "$APP_NAME" --query appId -o tsv)
fi

# Créer le service principal lié si absent
if [ -z "$(az ad sp list --display-name "$APP_NAME" --query "[0].id" -o tsv)" ]; then
  az ad sp create --id "$APP_ID"
fi

# Federated credential pour GitHub Actions (branche main)
az ad app federated-credential create \
  --id "$APP_ID" \
  --parameters "{
    \"name\": \"github-azure-infra-terraform\",
    \"issuer\": \"https://token.actions.githubusercontent.com\",
    \"subject\": \"repo:${REPO}:ref:refs/heads/main\",
    \"audiences\": [\"api://AzureADTokenExchange\"]
  }"