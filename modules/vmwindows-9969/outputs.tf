output "hostnames" {
  value = azurerm_windows_virtual_machine.vm[*].computer_name
}
output "fqdns" {
  value = azurerm_public_ip.pip[*].fqdn
}
output "private_ips" {
  value = azurerm_windows_virtual_machine.vm[*].private_ip_address
}
output "public_ips" {
  value = azurerm_windows_virtual_machine.vm[*].public_ip_address
}

# keys are built from the index (known before apply), which the
# datadisk module needs for its for_each
output "vm_ids" {
  value = { for i, vm in azurerm_windows_virtual_machine.vm : "windows-vm${i + 1}" => vm.id }
}
