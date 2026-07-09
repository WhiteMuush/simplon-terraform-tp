terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

#TODO : créer un azurerm_container_group (ACI)

#Nom attendu      : "aci-${var.owner}-tf"
#Image            : "nginx:latest"
#IP               : Public
#DNS label        : "aci-${var.owner}-tf"
#CPU / Mémoire    : 0.5 / 0.5
#Port             : 80 TCP
#OS               : Linux

#Documentation : https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_group

resource "azurerm_container_group" "aci" {
  name                = "aci-${var.owner}-tf"
  resource_group_name = var.resource_group_name
  location            = var.location
  ip_address_type     = "Public"
  dns_name_label      = "aci-${var.owner}-tf"
  os_type             = Linux
  container {
    name   = "nginx"
    image  = "nginx:latest"
    cpu    = 0.5
    memory = 0.5
    ports {
      port     = 80
      protocol = "TCP"
    }
  }
  tags = var.tags
}
