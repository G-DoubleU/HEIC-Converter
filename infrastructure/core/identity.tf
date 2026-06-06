resource "azurerm_role_assignment" "fucn_storage_access" {
  scope                = azurerm_storage_account.file_storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_function_app_flex_consumption.func_app.identity[0].principal_id
}

resource "azurerm_role_assignment" "web_app_storage_access" {
  scope                = azurerm_storage_account.file_storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_linux_web_app.web_app.identity[0].principal_id
}