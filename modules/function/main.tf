resource "azurerm_storage_account" "storage" {
  name                     = "${var.project}${var.environment}storage"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  location                 = var.location
  resource_group_name      = var.resource_group_name
}



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
  identity {
    type = "SystemAssigned"
  }
  app_settings = {
    "AZURE_LANGUAGE_ENDPOINT"     = var.endpoint
    "AZURE_LANGUAGE_KEY"          = var.key
    "AzureWebJobsFeatureFlags"    = "EnableWorkerIndexing"
    "FUNCTIONS_WORKER_RUNTIME"    = "python"
    "FUNCTIONS_EXTENSION_VERSION" = "~4"
  }
  site_config {
    application_stack {
      python_version = "3.9"
    }
  }

}

resource "azurerm_function_app_function" "detect_language" {
  name = "detect_language"
  function_app_id = azurerm_linux_function_app.function-app.id
  config_json = jsonencode({
            "name": "detect_language",
            "entryPoint": "detect_language",
            "scriptFile": "function_app.py",
            "language": "python",
            "functionDirectory": "/home/site/wwwroot",
            "bindings": [
                {
                    "direction": "IN",
                    "type": "httpTrigger",
                    "name": "req",
                    "authLevel": "ANONYMOUS",
                    "route": "detect_language"
                },
                {
                    "direction": "OUT",
                    "type": "http",
                    "name": "$return"
                }
            ]
        })
}

resource "azurerm_application_insights" "insights" {
  name                = "${var.project}-${var.environment}-insights"
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "other"

}
# zip the source
# https://xebia.com/blog/deploying-an-azure-function-with-terraform/
data "archive_file" "function" {
  type        = "zip"
  source_dir  = "${path.root}/azure_function"
  output_path = "${path.root}/azure_function.zip"

  depends_on = [null_resource.pip]
}
resource "null_resource" "pip" {
  triggers = {
    requirements_md5 = "${filemd5("${path.root}/azure_function/requirements.txt")}"
    main_md5         = "${filemd5("${path.root}/main.tf")}"
  }
  provisioner "local-exec" {
    command     = "pip install --target='.python_packages/lib/site-packages' -r requirements.txt"
    working_dir = "${path.root}/azure_function"
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
  source                 = "${path.root}/azure_function.zip"
}
