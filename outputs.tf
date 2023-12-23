/* output "function_app_name" {
  value = azurerm_linux_function_app.translator-function-app.name
  description = "Deployed function app name"
}

output "function_app_default_hostname" {
  value = azurerm_linux_function_app.translator-function-app.default_hostname
  description = "Deployed function app hostname"
}
*/

output "azurerm_cognitive_account_endpoint" {
  value = azurerm_cognitive_account.text-analytics.endpoint
  description = "Endpoint of the Text Analytics Service"
}
output "azurerm_cognitive_account_primary_key" {
    value = azurerm_cognitive_account.text-analytics.primary_access_key
    description = "Primary access key"
    sensitive = true
}
output "azurerm_cognitive_account_key_secondary" {
    value = azurerm_cognitive_account.text-analytics.secondary_access_key
    description = "Primary access key"
    sensitive = true
}
