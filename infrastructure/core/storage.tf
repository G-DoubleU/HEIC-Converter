#Storage account to hold uploads and converted files
resource "azurerm_storage_account" "file_storage" {
  name                     = "geoffheicfilestorage"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = local.tags
}

#Containers to hold uploaded files and processed (converted) files 
resource "azurerm_storage_container" "uploads" {
  name               = "uploads"
  storage_account_id = azurerm_storage_account.file_storage.id
}

resource "azurerm_storage_container" "processed" {
  name               = "processed"
  storage_account_id = azurerm_storage_account.file_storage.id
}

resource "azurerm_storage_container" "deployments" {
  name                  = "deployments"
  storage_account_id    = azurerm_storage_account.file_storage.id
  container_access_type = "private"
}