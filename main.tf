# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "translator-resource-group" {
  name     = "translator"
  location = "West Europe"
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "translator-network" {
  name                = "network"
  resource_group_name = azurerm_resource_group.translator-resource-group.name
  location            = azurerm_resource_group.translator-resource-group.location
  address_space       = ["10.0.0.0/16"]
}
# Create TextAnalyticsService
resource "azurerm_cognitive_account" "translator-service" {
  name                = "translator-service-domain"
  location            = azurerm_resource_group.translator-resource-group.location
  resource_group_name = azurerm_resource_group.translator-resource-group.name
  kind                = "TextAnalytics"
  sku_name = "F0" #should be translator
}