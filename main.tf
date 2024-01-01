# main.tf



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

  location = azurerm_resource_group.rg.location
  kind     = "FunctionApp"
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



resource "azurerm_function_app" "function-app" {
  name                       = "${var.project}-function-app"
  resource_group_name        = azurerm_resource_group.rg.name
  location                   = azurerm_resource_group.rg.location
  app_service_plan_id        = azurerm_app_service_plan.asp.id
  storage_account_name       = azurerm_storage_account.storage.name
  storage_account_access_key = azurerm_storage_account.storage.primary_access_key
  version                    = "~4"
  os_type                    = "linux"
  identity {
    type = "SystemAssigned"
  }
  app_settings = {
    "AZURE_LANGUAGE_ENDPOINT"  = azurerm_cognitive_account.text-analytics.endpoint
    "AZURE_LANGUAGE_KEY"       = azurerm_cognitive_account.text-analytics.primary_access_key
    "AzureWebJobsFeatureFlags" = "EnableWorkerIndexing"
    "FUNCTIONS_WORKER_RUNTIME" = "python"
    "WEBSITE_RUN_FROM_PACKAGE" = azurerm_storage_blob.storage_blob_function.url
  }
  site_config {
  }

}

resource "azurerm_application_insights" "insights" {
  name                = "${var.project}-${var.environment}-insights"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "other"

}
# zip the source
# https://xebia.com/blog/deploying-an-azure-function-with-terraform/
data "archive_file" "function" {
  type        = "zip"
  source_dir  = "${path.module}/azure_function"
  output_path = "${path.module}/azure_function.zip"

  depends_on = [null_resource.pip]
}
resource "null_resource" "pip" {
  triggers = {
    requirements_md5 = "${filemd5("${path.module}/azure_function/requirements.txt")}"
    main_md5 = "${filemd5("${path.module}/main.tf")}"
  }
  provisioner "local-exec" {
    command     = "pip install --target='.python_packages/lib/site-packages' -r requirements.txt"
    working_dir = "${path.module}/azure_function"
  }
}



resource "azurerm_storage_container" "function-container" {
  name                 = "azure-function-releases"
  storage_account_name = azurerm_storage_account.storage.name
}

resource "azurerm_storage_blob" "storage_blob_function" {
  name                   = "functions-${substr(data.archive_file.function.output_md5, 0, 6)}.zip"
  storage_account_name   = azurerm_storage_account.storage.name
  storage_container_name = azurerm_storage_container.function-container.name
  type                   = "Block"
  content_md5            = data.archive_file.function.output_md5
  source                 = "${path.module}/azure_function.zip"
}
