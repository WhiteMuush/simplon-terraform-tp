# ──────────────────────────────────────────────────────────────────────────────
# main.tf — Ressources Azure à provisionner avec Terraform
#
# Ce fichier est votre point d'entrée. Complétez les TODO au fil du TP.
# ──────────────────────────────────────────────────────────────────────────────

# ── Tags communs à toutes les ressources ──────────────────────────────────────
# Ces tags sont mergés automatiquement dans chaque module via var.tags

locals {
  tags = merge(
    {
      managed_by  = "terraform"
      environment = "tp"
      owner       = var.owner
    }
    var.tags
  )
}

# ── Data sources ──────────────────────────────────────────────────────────────
# Un data source LIT une ressource existante sans la créer.

# Resource Group pré-créé par le formateur — ne jamais le gérer en Terraform
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

# Plan App Service partagé (dans un Resource Group séparé)
data "azurerm_service_plan" "shared" {
  name                = var.shared_plan_name
  resource_group_name = var.shared_rg_name
}

# ── Storage (Étape 2) ─────────────────────────────────────────────────────────
# Paramètres à passer : owner, resource_group_name, location, tags

module "storage" {
  source              = "./modules/storage"
  owner               = var.owner
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location
  tags                = var.tags
}

# ── App Service (Étape 3) ─────────────────────────────────────────────────────
# Paramètres à passer : owner, resource_group_name, service_plan_id, tags

module "app_service" {
  source              = "./modules/app-service"
  owner               = var.owner
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location
  service_plan_id     = data.azurerm_service_plan.shared.id
  tags                = var.tags
}

# ── Function App (Étape 3) ────────────────────────────────────────────────────
# Paramètres à passer : owner, resource_group_name, location, service_plan_id, tags

module "function_app" {
  source              = "./modules/function-app"
  owner               = var.owner
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location
  service_plan_id     = data.azurerm_service_plan.shared.id
  tags                = var.tags
}

# ── Container Instance (Étape 3) ──────────────────────────────────────────────
# Paramètres à passer : owner, resource_group_name, location, tags

module "container" {
  source              = "./modules/container"
  owner               = var.owner
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

# ── Network (Étape 7) ─────────────────────────────────────────────────────────
# Paramètres à passer : owner, resource_group_name, location, tags

module "network" {
  source              = "./modules/network"
  owner               = var.owner
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}
