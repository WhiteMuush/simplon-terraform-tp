terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

# TODO (1/3) : créer un azurerm_storage_account métier
#
# Nom attendu              : "st${replace(var.owner, "-", "")}tf"
# Tier                     : Standard, LRS, StorageV2, TLS 1.2
# Accès public blob activé : true  (nécessaire pour api-config)
#
# Documentation : https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account

resource "azurerm_storage_account" "sa" {
  name                            = "st${replace(var.owner, "-", "")}tf"
  resource_group_name             = var.resource_group_name
  location                        = var.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  account_kind                    = "StorageV2"
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = true
  tags                            = var.tags
}

# Conteneur privé pour les logs API
resource "azurerm_storage_container" "api_logs" {
  name                  = "api-logs"
  storage_account_id    = azurerm_storage_account.sa.id
  container_access_type = "private"
}

# Conteneur public pour la config API (lecture anonyme des blobs)
resource "azurerm_storage_container" "api_config" {
  name                  = "api-config"
  storage_account_id    = azurerm_storage_account.sa.id
  container_access_type = "blob"
}
