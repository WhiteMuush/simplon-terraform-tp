terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

data "azurerm_service_plan" "shared" {
  name                = split("/", var.service_plan_id)[8]
  resource_group_name = split("/", var.service_plan_id)[4]
}

resource "azurerm_linux_web_app" "app" {
  name                = "app-${var.owner}-tf"
  resource_group_name = data.azurerm_service_plan.shared.name
  location            = data.azurerm_service_plan.shared.location
  service_plan_id     = var.service_plan_id
  https_only          = true
  site_config {
    minimum_tls_version = "1.2"
    application_stack {
      python_version = 3.11
    }
  }
  tags = var.tags
}
