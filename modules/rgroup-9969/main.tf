resource "azurerm_resource_group" "rg" {
  name     = "${var.humber_id}-${var.rg_suffix}"
  location = var.location
  tags     = var.tags
}
