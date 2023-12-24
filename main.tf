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
  # Update this block with the location of your terraform state file
  backend "azurerm" {
    resource_group_name  = "cloud-shell-storage-westeurope"
    storage_account_name = "csb1003200321a68be4"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
    use_oidc             = true
  }
}
# terraform/text.tf

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
  use_oidc = true
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
resource "azurerm_storage_account" "storage" {
  name                     = "${var.project}${var.environment}storage"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
}
resource "azurerm_app_service_plan" "asp" {
  name                = "${var.project}${var.environment}appserviceplan"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku {
    tier = "Dynamic"
    size = "Y1"
  }
  lifecycle {
    ignore_changes = [
      kind
    ]
  }
}



resource "azurerm_function_app" "vscode-function-2" {
  name                       = "${var.project}-function-app"
  resource_group_name        = azurerm_resource_group.rg.name
  location                   = azurerm_resource_group.rg.location
  app_service_plan_id        = azurerm_app_service_plan.asp.id
  storage_account_name       = azurerm_storage_account.storage.name
  storage_account_access_key = azurerm_storage_account.storage.primary_access_key
  version                    = "~4"
  os_type                    = "linux"
  app_settings = {
    "AZURE_LANGUAGE_ENDPOINT"  = azurerm_cognitive_account.text-analytics.endpoint
    "AZURE_LANGUAGE_KEY"       = azurerm_cognitive_account.text-analytics.primary_access_key
    "AzureWebJobsFeatureFlags" = "EnableWorkerIndexing"
    "FUNCTIONS_WORKER_RUNTIME" = "python"
    "WEBSITE_RUN_FROM_PACKAGE" = "1"
  }
  site_config {
  }

}
