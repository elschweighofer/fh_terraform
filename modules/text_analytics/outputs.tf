output "analytics_endpoint" {
  value       = azurerm_cognitive_account.text-analytics.endpoint
  description = "Endpoint of the Text Analytics Service"
}

output "analytics_primary_key" {
  value       = azurerm_cognitive_account.text-analytics.primary_access_key
  description = "Primary access key"
  sensitive   = true
}

output "analytics_key_secondary" {
  value       = azurerm_cognitive_account.text-analytics.secondary_access_key
  description = "Primary access key"
  sensitive   = true
}

output "translation_endpoint" {
  value       = azurerm_cognitive_account.text-translation.endpoint
  description = "Endpoint of the Text Translation Service"
}

output "translation_primary_key" {
  value       = azurerm_cognitive_account.text-translation.primary_access_key
  description = "Primary access key"
  sensitive   = true
}

output "translation_key_secondary" {
  value       = azurerm_cognitive_account.text-translation.secondary_access_key
  description = "Primary access key"
  sensitive   = true
}
