resource "azurerm_log_analytics_workspace" "log_workspace" {
  name                = "${var.resource_prefix}-log-analytics"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = local.tags
}

resource "azurerm_application_insights" "app_insights" {
  name                = "${var.resource_prefix}-app-insights"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  workspace_id        = azurerm_log_analytics_workspace.log_workspace.id
  application_type    = "web"

  tags = local.tags
}