# Cheapest setup: Burstable B1ms, 32 GB storage, no HA, no geo-backup.
# Server names are global, lowercase only.
resource "azurerm_postgresql_flexible_server" "db" {
  name                          = "${var.humber_id}-pgsql-ccgc5502"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  version                       = "16"
  sku_name                      = "B_Standard_B1ms"
  storage_mb                    = 32768
  storage_tier                  = "P4"
  backup_retention_days         = 7
  geo_redundant_backup_enabled  = false
  public_network_access_enabled = true
  administrator_login           = var.admin_username
  administrator_password        = var.admin_password
  tags                          = var.tags

  # Azure picks a zone for us; without this, the next plan would
  # want to "change" it back to nothing.
  lifecycle {
    ignore_changes = [zone]
  }
}
