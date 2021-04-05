terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "learningrg" {
  name = "learning"
  location = "westeurope"

  tags = {
    purpose = "Learning"
  }
}

resource "azurerm_virtual_network" "learningnetwork" {
    name                = "learningNetwork"
    address_space       = ["10.0.0.0/16"]
    location            = "westeurope"
    resource_group_name = azurerm_resource_group.learningrg.name

    tags = {
        purpose = "Learning"
    }
}

resource "azurerm_subnet" "learningsubnet" {
    name                 = "learningSubnet"
    resource_group_name  = azurerm_resource_group.learningrg.name
    virtual_network_name = azurerm_virtual_network.learningnetwork.name
    address_prefixes       = ["10.0.2.0/24"]
}

module "azurevm" {
  source = "./modules/azurevm"

  resource_group = azurerm_resource_group.learningrg.name
  subnet = azurerm_subnet.learningsubnet.id
}