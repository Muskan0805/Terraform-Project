# count (as the brief asks). Raise vm_count and every VM lands in the same
# availability set, spread across fault and update domains.

resource "azurerm_availability_set" "avset" {
  name                         = "${var.humber_id}-win-avset"
  location                     = var.location
  resource_group_name          = var.resource_group_name
  platform_fault_domain_count  = var.fault_domain_count
  platform_update_domain_count = var.update_domain_count
  managed                      = true
  tags                         = var.tags
}

resource "azurerm_public_ip" "pip" {
  count               = var.vm_count
  name                = "${var.humber_id}-win-vm${count.index + 1}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = var.public_ip_allocation_method
  sku                 = var.public_ip_sku
  domain_name_label   = "vm${var.humber_id}-win-vm${count.index + 1}"
  tags                = var.tags
}

resource "azurerm_network_interface" "nic" {
  count               = var.vm_count
  name                = "${var.humber_id}-win-vm${count.index + 1}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = var.ip_config_name
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = var.private_ip_allocation
    public_ip_address_id          = azurerm_public_ip.pip[count.index].id
  }
}

resource "azurerm_windows_virtual_machine" "vm" {
  count                 = var.vm_count
  name                  = "${var.humber_id}-win-vm${count.index + 1}"
  computer_name         = "${var.humber_id}-win-vm${count.index + 1}"
  location              = var.location
  resource_group_name   = var.resource_group_name
  size                  = var.vm_size
  availability_set_id   = azurerm_availability_set.avset.id
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  network_interface_ids = [azurerm_network_interface.nic[count.index].id]
  tags                  = var.tags

  os_disk {
    name                 = "${var.humber_id}-win-vm${count.index + 1}-osdisk"
    caching              = var.os_disk_caching
    storage_account_type = var.os_disk_storage_type
  }

  source_image_reference {
    publisher = var.image.publisher
    offer     = var.image.offer
    sku       = var.image.sku
    version   = var.image.version
  }

  boot_diagnostics {
    storage_account_uri = var.boot_diag_uri
  }
}

resource "azurerm_virtual_machine_extension" "antimalware" {
  count                      = var.vm_count
  name                       = var.antimalware_extension.type
  virtual_machine_id         = azurerm_windows_virtual_machine.vm[count.index].id
  publisher                  = var.antimalware_extension.publisher
  type                       = var.antimalware_extension.type
  type_handler_version       = var.antimalware_extension.version
  auto_upgrade_minor_version = var.antimalware_extension.auto_upgrade
  tags                       = var.tags

  settings = jsonencode({
    AntimalwareEnabled        = true
    RealtimeProtectionEnabled = tostring(var.antimalware_realtime_protection)
    ScheduledScanSettings = {
      isEnabled = tostring(var.antimalware_scan.enabled)
      day       = tostring(var.antimalware_scan.day)
      time      = tostring(var.antimalware_scan.time)
      scanType  = var.antimalware_scan.type
    }
  })
}
