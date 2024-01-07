# Create a TextAnalyticsServices
resource "azurerm_cognitive_account" "text-analytics" {
  name                = "${var.project}-${var.environment}-text-analytic"
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "TextAnalytics"
  sku_name            = "F0" #F0 Free 2M Up to 2M characters translated per month
}



resource "azurerm_cognitive_account" "text-translation" {
  name                = "${var.project}-${var.environment}-text-translation"
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "TextTranslation"
  sku_name            = "F0" #F0 Free 2M Up to 2M characters translated per month
}
