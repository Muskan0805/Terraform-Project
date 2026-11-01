# One disk + one attachment per VM passed in
resource "azurerm_managed_disk" "disk" {
  for_each             = var.vms
  name                 = "${var.humber_id}-${each.key}-datadisk"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = var.storage_account_type
  create_option        = var.create_option
  disk_size_gb         = var.disk_size_gb
  zone                 = each.value.zone # must match the VM's zone; null for the Windows VM
  tags                 = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "attach" {
  for_each           = var.vms
  managed_disk_id    = azurerm_managed_disk.disk[each.key].id
  virtual_machine_id = each.value.vm_id
  lun                = var.lun
  caching            = var.caching
}
