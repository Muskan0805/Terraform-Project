resource "azurerm_log_analytics_workspace" "law" {
  name                = "${var.humber_id}-LAW"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

# Azure requires vault names to START WITH A LETTER, so the ID can't be the
# very first character here. "rsv" goes in front - the only exception to
# the prefix rule, forced by Azure.
resource "azurerm_recovery_services_vault" "rsv" {
  name                = "rsv-${var.humber_id}-vault"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  storage_mode_type   = "LocallyRedundant"
  tags                = var.tags
}

# Storage account names: 3-24 chars, lowercase letters and numbers only,
# globally unique. Separate from the backend's "<id>tfstatesa" account.
resource "azurerm_storage_account" "sa" {
  name                     = "${var.humber_id}ccgc5502sa"
  location                 = var.location
  resource_group_name      = var.resource_group_name
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  tags                     = var.tags
}
