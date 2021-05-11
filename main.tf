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

# module "azurevm" {
#   source = "./modules/azurevm"

#   resource_group = azurerm_resource_group.learningrg.name
#   subnet = azurerm_subnet.learningsubnet.id
# }

# create app service plan
resource "azurerm_app_service_plan" "webapp" {
  name                = "webapp-appserviceplan"
  location            = azurerm_resource_group.learningrg.location
  resource_group_name = azurerm_resource_group.learningrg.name

  sku {
    tier = "Free"
    size = "F1"
  }
}

# create webapp

resource "azurerm_app_service" "webapp" {
  name                = "webapp-app-service"
  location            = azurerm_resource_group.learningrg.location
  resource_group_name = azurerm_resource_group.learningrg.name
  app_service_plan_id = azurerm_app_service_plan.webapp.id

  source_control {
    repo_url = "https://github.com/Azure-Samples/php-docs-hello-world"
    branch = "master" #master is default, but just in case
    manual_integration = true
  }
}

output "app_service" {
    value = azurerm_app_service.webapp.default_site_hostname
}

# Free Tier → F1
# Shared Tier → D1
# Basic Tier → B1, B2, B3 (Basic Small, Medium, Large)
# Standard Tier → S1, S2, S3 (Small, Medium, Large)
# PremiumV2 Tier → P1v2, P2v2, P3v2 (Small, Medium, Large)