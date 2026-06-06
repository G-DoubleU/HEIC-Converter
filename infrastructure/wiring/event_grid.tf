resource "azurerm_eventgrid_system_topic" "storage_events" {
  name = "${var.resource_prefix}-storage-events"
  resource_group_name = data.terraform_remote_state.core.outputs.resource_group_name
  location = var.location
  source_resource_id = data.terraform_remote_state.core.outputs.storage_account_id
  topic_type = "Microsoft.Storage.StorageAccounts"

  tags = local.tags
}

resource "azurerm_eventgrid_system_topic_event_subscription" "file_uploaded" {
  name = "${var.resource_prefix}-file-upload"
  system_topic = azurerm_eventgrid_system_topic.storage_events.name
  resource_group_name = data.terraform_remote_state.core.outputs.resource_group_name

  included_event_types = ["Microsoft.Storage.BlobCreated"]
  
  subject_filter {
    subject_begins_with = "/blobServices/default/containers/uploads/"
    subject_ends_with = ".heic"
  }

  azure_function_endpoint {
    function_id = "${data.terraform_remote_state.core.outputs.function_app_id}/functions/OnFileUpload"
  }
}