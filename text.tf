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
resource "azurerm_resource_group" "vscodefunction22" {
  name     = "vscodefunction22"
  location = "West Europe"
}
