data "terraform_remote_state" "core" {
    backend = "azurerm"
    config = {
        resource_group_name = "tfstate"
        storage_account_name = "tfstaterv1ss"
        container_name = "tfstate"
        key = "HEIC_Converter_core.tfstate"
    }
  
}