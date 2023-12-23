# terraform/main.tf

# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.85.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "=3.6.0"
    }
  }
}

# terraform/text.tf

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}
resource "random_pet" "pet" {

}
resource "random_id" "id" {
  byte_length = 8

}

# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = "${var.project}-${var.environment}-rg"
  location = "West Europe"
}
# Create a TextAnalyticsServices
resource "azurerm_cognitive_account" "text-analytics" {
  name                = "${var.project}-${var.environment}-text-analytic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "TextAnalytics"
  sku_name            = "F0" 
}