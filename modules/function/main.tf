# Storage

resource "azurerm_storage_account" "storage" {
  name                     = "${var.project}${var.environment}storage"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  location                 = var.location
  resource_group_name      = var.resource_group_name
}
resource "azurerm_storage_container" "function-container" {
  name                 = "azure-function-releases"
  storage_account_name = azurerm_storage_account.storage.name
}

# App
resource "azurerm_service_plan" "asp" {
  name                = "${var.project}${var.environment}appserviceplan"
  resource_group_name = var.resource_group_name

  location = var.location
  os_type  = "Linux"
  sku_name = "Y1"
}



resource "azurerm_linux_function_app" "function-app" {
  name                       = "${var.project}-function-app"
  resource_group_name        = var.resource_group_name
  location                   = var.location
  service_plan_id            = azurerm_service_plan.asp.id
  storage_account_name       = azurerm_storage_account.storage.name
  storage_account_access_key = azurerm_storage_account.storage.primary_access_key

  app_settings = {
    AzureWebJobsDisableHomepage    = true
    SCM_DO_BUILD_DURING_DEPLOYMENT = true
    ENABLE_ORYX_BUILD              = true
    FUNCTIONS_WORKER_RUNTIME       = "python"
    AZURE_LANGUAGE_ENDPOINT        = var.endpoint
    AZURE_LANGUAGE_KEY             = var.key

  }

  site_config {
    application_stack {
      python_version = "3.10"
    }
  }
  identity {
    type = "SystemAssigned"
  }


}

# Monitoring / Logs
resource "azurerm_application_insights" "insights" {
  name                = "${var.project}-${var.environment}-insights"
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "other"

}

# Actual Endpoints
resource "azurerm_function_app_function" "http_example" {
  name            = "http_example"
  function_app_id = azurerm_linux_function_app.function-app.id
  language        = "Python"
  test_data = jsonencode({
    "name" = "Azure"
  })

  file {
    name    = "function_app.py"
    content = file("azure_function/function_app.py")
  }
  config_json = jsonencode({
    "bindings" : [
      {
        "direction" : "in",
        "type" : "httpTrigger",
        "authLevel" : "ANONYMOUS",
        "name" = "req"

        "methods" = [
          "get",
          "post",
        ]
      },
      {
        "direction" : "out",
        "type" : "http",
        "name" : "$return"
      }
    ]
  })
}

