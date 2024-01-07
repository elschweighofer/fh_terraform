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

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
  use_oidc = true
}
# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = "${var.project}-${var.environment}-rg"
  location = "West Europe"
}


module "text_analytics" {
  source              = "./modules/text_analytics"
  resource_group_name = azurerm_resource_group.rg.name

  project     = var.project
  environment = var.environment
  location    = var.location
}

module "app" {
  source              = "./modules/function"
  resource_group_name = azurerm_resource_group.rg.name

  endpoint = module.text_analytics.analytics_endpoint
  key         = module.text_analytics.analytics_key_secondary
  
  project     = var.project
  environment = var.environment
  location    = var.location

}