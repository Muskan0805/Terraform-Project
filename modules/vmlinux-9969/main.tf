# for_each over var.linux_vms (label => zone). Every resource is keyed by the
# same labels, so vm1's IP, NIC and extensions all line up as "vm1".

resource "azurerm_public_ip" "pip" {
  for_each            = var.linux_vms
  name                = "${var.humber_id}-linux-${each.key}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = var.public_ip_allocation_method
  sku                 = var.public_ip_sku
  zones               = [each.value]
  domain_name_label   = "vm${var.humber_id}-linux-${each.key}"
  tags                = var.tags
}

resource "azurerm_network_interface" "nic" {
  for_each            = var.linux_vms
  name                = "${var.humber_id}-linux-${each.key}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = var.ip_config_name
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = var.private_ip_allocation
    public_ip_address_id          = azurerm_public_ip.pip[each.key].id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  for_each              = var.linux_vms
  name                  = "${var.humber_id}-linux-${each.key}"
  computer_name         = "${var.humber_id}-linux-${each.key}"
  location              = var.location
  resource_group_name   = var.resource_group_name
  size                  = var.vm_size
  zone                  = each.value
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.nic[each.key].id]
  tags                  = var.tags

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.public_key_path)
  }

  os_disk {
    name                 = "${var.humber_id}-linux-${each.key}-osdisk"
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

  # The Azure Monitor agent authenticates with this managed identity
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_virtual_machine_extension" "network_watcher" {
  for_each                   = var.linux_vms
  name                       = var.network_watcher_extension.type
  virtual_machine_id         = azurerm_linux_virtual_machine.vm[each.key].id
  publisher                  = var.network_watcher_extension.publisher
  type                       = var.network_watcher_extension.type
  type_handler_version       = var.network_watcher_extension.version
  auto_upgrade_minor_version = var.network_watcher_extension.auto_upgrade
  tags                       = var.tags
}

resource "azurerm_virtual_machine_extension" "azure_monitor" {
  for_each                   = var.linux_vms
  name                       = var.azure_monitor_extension.type
  virtual_machine_id         = azurerm_linux_virtual_machine.vm[each.key].id
  publisher                  = var.azure_monitor_extension.publisher
  type                       = var.azure_monitor_extension.type
  type_handler_version       = var.azure_monitor_extension.version
  auto_upgrade_minor_version = var.azure_monitor_extension.auto_upgrade
  tags                       = var.tags

  # two extensions installing on one VM at the same time can collide
  depends_on = [azurerm_virtual_machine_extension.network_watcher]
}
