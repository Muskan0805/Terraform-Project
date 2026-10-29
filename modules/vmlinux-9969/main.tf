# for_each over the map of VMs (label => zone). Every resource below is keyed
# by the same labels, so vm1's NIC, IP and extensions all line up as "vm1".

resource "azurerm_public_ip" "pip" {
  for_each            = var.linux_vms
  name                = "${var.humber_id}-linux-${each.key}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard" # Basic public IPs are retired in Azure
  zones               = [each.value]
  # DNS labels must start with a letter, hence the "vm" in front of the ID
  domain_name_label = "vm${var.humber_id}-linux-${each.key}"
  tags              = var.tags
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
    private_ip_address_allocation = "Dynamic"
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
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
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

  # The Azure Monitor agent authenticates with the VM's managed identity
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_virtual_machine_extension" "network_watcher" {
  for_each                   = var.linux_vms
  name                       = "NetworkWatcherAgentLinux"
  virtual_machine_id         = azurerm_linux_virtual_machine.vm[each.key].id
  publisher                  = "Microsoft.Azure.NetworkWatcher"
  type                       = "NetworkWatcherAgentLinux"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
  tags                       = var.tags
}

resource "azurerm_virtual_machine_extension" "azure_monitor" {
  for_each                   = var.linux_vms
  name                       = "AzureMonitorLinuxAgent"
  virtual_machine_id         = azurerm_linux_virtual_machine.vm[each.key].id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorLinuxAgent"
  type_handler_version       = "1.21"
  auto_upgrade_minor_version = false
  tags                       = var.tags

  # Two extensions installing at the same moment on one VM can collide,
  # so this one waits for Network Watcher to finish.
  depends_on = [azurerm_virtual_machine_extension.network_watcher]
}
