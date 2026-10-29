output "data_disk_names" {
  value = { for k, d in azurerm_managed_disk.disk : k => d.name }
}
