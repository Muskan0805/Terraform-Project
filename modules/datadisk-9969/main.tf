# One 10 GB disk + one attachment per VM passed in (4 VMs = 8 resources).
resource "azurerm_managed_disk" "disk" {
  for_each             = var.vms
  name                 = "${var.humber_id}-${each.key}-datadisk"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.disk_size_gb
  # a disk can only attach to a VM in the same zone; null = no zone (Windows)
  zone = each.value.zone
  tags = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "attach" {
  for_each           = var.vms
  managed_disk_id    = azurerm_managed_disk.disk[each.key].id
  virtual_machine_id = each.value.vm_id
  lun                = 0
  caching            = "ReadWrite"
}
