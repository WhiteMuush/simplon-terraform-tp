terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

#
# Nom            : "vnet-${var.owner}-tf"
# Espace d'adres.: ["10.0.0.0/16"]
#
# Documentation : https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.owner}-tf"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = ["10.0.0.0/16"]
  tags                = var.tags
}

# Documentation : https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet

resource "azurerm_subnet" "frontend" {
  name                 = "subnet-frontend"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "backend" {
  name                 = "subnet-backend"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

#
# Nom    : "nsg-frontend-${var.owner}-tf"
# Règles : Allow-HTTP (100), Allow-HTTPS (110), Deny-All-Inbound (4000)
#
# Documentation : https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group

resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-frontend-${var.owner}-tf"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  #   # TODO : ajouter Allow-HTTP  (port 80,  priorité 100, action Allow)
  #   # TODO : ajouter Allow-HTTPS (port 443, priorité 110, action Allow)
  #   # TODO : ajouter Deny-All-Inbound (port *, priorité 4000, action Deny)

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "80"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Allow-HTTPs"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "443"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Deny-All-Inbound"
    priority                   = 4000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}







# TODO (4/4) : associer le NSG au subnet-frontend
#
# Documentation : https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association

resource "azurerm_subnet_network_security_group_association" "frontend_nsg" {
  subnet_id                 = azurerm_subnet.frontend.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
