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

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "translator-network" {
  name                = "${var.project}-${var.environment}-network"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]
}
# Create a TextAnalyticsServices
resource "azurerm_cognitive_account" "translator-service" {
  name                = "${var.project}-${var.environment}-ai-service"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "TextAnalytics"
  sku_name            = "F0" #should be translator
}
# monitoring

resource "azurerm_application_insights" "application_insights" {
  name                = "${var.project}-${var.environment}-application-insights"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
}

# Create a FaaS Lambda w/ever

resource "azurerm_storage_account" "storage" {
  name                     = random_id.id.dec
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS" #local redundant
}

resource "azurerm_service_plan" "translator-service-plan" {
  name                = "translator-service-plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "Y1"

}

# azurerm_linux_function_app.translator2:
resource "azurerm_linux_function_app" "translator2" {
    app_settings                                   = {
        "AzureWebJobsSecretStorageType" = "files"
    }
    functions_extension_version                    = "~4"
    https_only                                     = true
    location                                       = azurerm_resource_group.rg.location
    name                                           = "translator2"
    public_network_access_enabled                  = true
    resource_group_name                            = azurerm_resource_group.rg.name
    service_plan_id                                = azurerm_service_plan.translator-service-plan.id
    webdeploy_publish_basic_authentication_enabled = true

    site_config {        

        application_stack {
            python_version              = "3.10"
        }

        cors {
            allowed_origins     = [
                "https://portal.azure.com",
            ]
            support_credentials = false
        }
    }
}
