resource "azurerm_postgresql_flexible_server" "db" {
  name                          = "${var.humber_id}-pgsql-ccgc5502"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  version                       = var.postgres_version
  sku_name                      = var.sku_name
  storage_mb                    = var.storage_mb
  storage_tier                  = var.storage_tier
  backup_retention_days         = var.backup_retention_days
  geo_redundant_backup_enabled  = var.geo_redundant_backup
  public_network_access_enabled = var.public_network_access
  administrator_login           = var.admin_username
  administrator_password        = var.admin_password
  tags                          = var.tags

  # Azure picks a zone; ignore it so later plans don't try to change it
  lifecycle {
    ignore_changes = [zone]
  }
}
