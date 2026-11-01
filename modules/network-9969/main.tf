resource "azurerm_virtual_network" "vnet" {
  name                = "${var.humber_id}-VNET"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.vnet_address_space
  tags                = var.tags
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.humber_id}-SUBNET"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_address_prefixes
}

# One rule per entry in var.inbound_ports, written as dynamic blocks inside the NSG
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.humber_id}-NSG"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  dynamic "security_rule" {
    for_each = var.inbound_ports
    content {
      name                       = "allow-${security_rule.key}-${security_rule.value}"
      priority                   = var.rule_priority_start + index(keys(var.inbound_ports), security_rule.key) * var.rule_priority_step
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = var.rule_protocol
      source_port_range          = "*"
      destination_port_range     = tostring(security_rule.value)
      source_address_prefix      = var.allowed_source_prefix
      destination_address_prefix = "*"
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "assoc" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
