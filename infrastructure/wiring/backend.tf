terraform {
  backend "azurerm" {
    resource_group_name = "tfstate"
    storage_account_name = "tfstaterv1ss"
    container_name = "tfstate"
    key = "HEIC_Converter_wiring.tfstate"
  }
}