locals {
  tags = merge(
    {
      managed_by  = "terraform"
      environment = "tp"
      owner       = var.owner
    },
    var.tags
  )
}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_service_plan" "shared" {
  name                = var.shared_plan_name
  resource_group_name = var.shared_rg_name
}

module "storage" {
  source              = "app.terraform.io/WhiteMuush-Organizations/storage/azurerm"
  version             = "1.0.0"
  owner               = var.owner
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location
  tags                = var.tags
}

module "app_service" {
  source              = "app.terraform.io/WhiteMuush-Organizations/app-service/azurerm"
  version             = "1.0.0"
  owner               = var.owner
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location
  service_plan_id     = data.azurerm_service_plan.shared.id
  tags                = var.tags
}

module "function_app" {
  source              = "app.terraform.io/WhiteMuush-Organizations/function-app/azurerm"
  version             = "1.0.0"
  owner               = var.owner
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location
  service_plan_id     = data.azurerm_service_plan.shared.id
  tags                = var.tags
}

module "container" {
  source              = "app.terraform.io/WhiteMuush-Organizations/container/azurerm"
  version             = "1.0.0"
  owner               = var.owner
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

module "network" {
  source              = "app.terraform.io/WhiteMuush-Organizations/network/azurerm"
  version             = "1.0.0"
  owner               = var.owner
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}
