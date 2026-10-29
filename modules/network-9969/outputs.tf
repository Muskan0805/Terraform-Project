output "vnet_name" {
  value = azurerm_virtual_network.vnet.name
}
output "subnet_name" {
  value = azurerm_subnet.subnet.name
}
# Taken from the association (not the subnet) on purpose: anything that uses
# this ID now waits until the NSG is attached, so the VMs come up with
# port 22 already open and remote-exec can connect.
output "subnet_id" {
  value = azurerm_subnet_network_security_group_association.assoc.subnet_id
}
