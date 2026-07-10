#!/bin/bash
set -euo pipefail

export OWNER="melvin-petit"
export RG_BACKEND="mpetitRG"
export SA_BACKEND="ststate${OWNER//-/}"

# RG déjà existant (droit Owner dessus), pas de création : Reader seulement au niveau subscription

az storage account create \
  --name           "$SA_BACKEND" \
  --resource-group "$RG_BACKEND" \
  --location       "francecentral" \
  --sku            Standard_LRS

az storage container create \
  --name         "tfstate" \
  --account-name "$SA_BACKEND" \
  --auth-mode    key