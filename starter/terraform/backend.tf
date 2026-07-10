# Remote state stored in Azure Blob Storage
# Backend config values are injected at runtime via -backend-config
# (never commit account names or secrets here)
terraform {
  backend "azurerm" {}
}