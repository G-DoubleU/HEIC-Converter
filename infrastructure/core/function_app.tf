resource "azurerm_service_plan" "func_service_plan" {
  name                = "${var.resource_prefix}-func-service-plan"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "FC1"

  tags = local.tags
}

resource "azurerm_function_app_flex_consumption" "func_app" {
  name                = "${var.resource_prefix}-func-app"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.func_service_plan.id

  storage_container_type      = "blobContainer"
  storage_container_endpoint  = "${azurerm_storage_account.file_storage.primary_blob_endpoint}deployments"
  storage_authentication_type = "SystemAssignedIdentity"
  runtime_name                = "python"
  runtime_version             = "3.13"
  instance_memory_in_mb       = 2048
  maximum_instance_count      = 10

  site_config {}

  identity { type = "SystemAssigned" }

  app_settings = {
  "AzureWebJobsStorage" = azurerm_storage_account.file_storage.primary_connection_string
  
  "BLOB_STORAGE_CONNECTION" = azurerm_storage_account.file_storage.primary_connection_string
  "INPUT_CONTAINER"         = azurerm_storage_container.uploads.name
  "OUTPUT_CONTAINER"        = azurerm_storage_container.processed.name
}

  tags = local.tags

}
