output "resource_group_name" {
  description = "Resource group with all resources"
  value       = azurerm_resource_group.rg.name
}

output "function_app_name" {
  description = "The Function App's name. You will need this for deploying the code with 'func azure functionapp publish <name>"
  value       = azurerm_function_app_flex_consumption.func_app.name
}

output "function_app_id" {
  description = ".tf files in the wiring dir will need this"
  value       = azurerm_function_app_flex_consumption.func_app.id
}

output "web_app_service_name" {
  description = "Name of the App Service Web App. You will need this for deploying web app code with 'az webapp deploy --name <name>'"
  value       = azurerm_linux_web_app.web_app.name
}

output "web_app_url" {
  description = "URL of the web app"
  value       = "https://${azurerm_linux_web_app.web_app.default_hostname}"
}

output "storage_account_name" {
  description = "Storage account name"
  value       = azurerm_storage_account.file_storage.name
}

output "storage_account_id" {
  description = "This will also be needed for wiring"
  value       = azurerm_storage_account.file_storage.id
}
