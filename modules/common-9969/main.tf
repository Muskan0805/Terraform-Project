resource "azurerm_log_analytics_workspace" "law" {
  name                = "${var.humber_id}-LAW"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.law_sku
  retention_in_days   = var.law_retention_days
  tags                = var.tags
}

# Vault names must start with a letter, so the ID can't come first
resource "azurerm_recovery_services_vault" "rsv" {
  name                = "rsv-${var.humber_id}-vault"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.rsv_sku
  storage_mode_type   = var.rsv_storage_mode
  tags                = var.tags
}

# Separate from the backend storage account; used for VM boot diagnostics
resource "azurerm_storage_account" "sa" {
  name                     = "${var.humber_id}${var.storage_name_suffix}"
  location                 = var.location
  resource_group_name      = var.resource_group_name
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_replication_type
  min_tls_version          = var.storage_min_tls_version
  tags                     = var.tags
}
