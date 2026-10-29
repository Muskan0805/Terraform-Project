# Everything the child modules hand back, printed after a successful apply
# (and again whenever you run "terraform output").

# --- Resource group ---
output "resource_group_name" {
  value = module.rgroup.resource_group_name
}

# --- Networking ---
output "vnet_name" {
  value = module.network.vnet_name
}
output "subnet_name" {
  value = module.network.subnet_name
}

# --- Common services ---
output "log_analytics_workspace_name" {
  value = module.common.log_analytics_workspace_name
}
output "recovery_services_vault_name" {
  value = module.common.recovery_services_vault_name
}
output "storage_account_name" {
  value = module.common.storage_account_name
}

# --- Linux VMs ---
output "linux_vm_hostnames" {
  value = module.vmlinux.hostnames
}
output "linux_vm_fqdns" {
  value = module.vmlinux.fqdns
}
output "linux_vm_private_ips" {
  value = module.vmlinux.private_ips
}
output "linux_vm_public_ips" {
  value = module.vmlinux.public_ips
}

# --- Windows VM ---
output "windows_vm_hostname" {
  value = module.vmwindows.hostnames
}
output "windows_vm_fqdn" {
  value = module.vmwindows.fqdns
}
output "windows_vm_private_ip" {
  value = module.vmwindows.private_ips
}
output "windows_vm_public_ip" {
  value = module.vmwindows.public_ips
}

# --- Load balancer ---
output "load_balancer_name" {
  value = module.loadbalancer.load_balancer_name
}

# --- Database ---
output "postgresql_server_name" {
  value = module.database.db_server_name
}
