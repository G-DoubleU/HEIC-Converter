resource "azurerm_service_plan" "web_service_plan" {
  name                = "${var.resource_prefix}-web-service-plan"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "B1"

  tags = local.tags

}

resource "azurerm_linux_web_app" "web_app" {
  name                = "${var.resource_prefix}-web-app"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.web_service_plan.id

  site_config {
    always_on = false
    application_stack {
      python_version = "3.13"
    }
    app_command_line = "gunicorn -w 2 -k uvicorn.workers.UvicornWorker --timeout 120 main:app"
  }

  identity { type = "SystemAssigned" }

  app_settings = {
    "AZURE_STORAGE_CONNECTION_STRING" = azurerm_storage_account.file_storage.primary_connection_string
    "AZURE_CONTAINER_NAME"           = azurerm_storage_container.uploads.name
    "AZURE_OUTPUT_CONTAINER"         = azurerm_storage_container.processed.name
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "true"
    "ENABLE_ORYX_BUILD"              = "true"
  }

  tags = local.tags
}