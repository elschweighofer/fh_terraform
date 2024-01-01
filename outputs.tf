output "azurerm_cognitive_account_endpoint" {
  value       = azurerm_cognitive_account.text-analytics.endpoint
  description = "Endpoint of the Text Analytics Service"
}
output "azurerm_cognitive_account_primary_key" {
  value       = azurerm_cognitive_account.text-analytics.primary_access_key
  description = "Primary access key"
  sensitive   = true
}
output "azurerm_cognitive_account_key_secondary" {
  value       = azurerm_cognitive_account.text-analytics.secondary_access_key
  description = "Primary access key"
  sensitive   = true
}


output "storage_endpoint" {
  value = azurerm_storage_account.storage.endpoint
}
output "storage_access_key" {
  value = azurerm_storage_account.storage.primary_access_key
  sensitive = true
}