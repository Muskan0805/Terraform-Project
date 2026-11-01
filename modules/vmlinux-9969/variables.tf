variable "humber_id" {
  description = "Last 4 digits of Humber ID, prefixed to every resource name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group to create the VMs in"
  type        = string
}

variable "subnet_id" {
  description = "Subnet the VM NICs connect to"
  type        = string
}

variable "boot_diag_uri" {
  description = "Blob endpoint of the storage account used for boot diagnostics"
  type        = string
}

variable "tags" {
  description = "Tags applied to all Linux VM resources"
  type        = map(string)
}

variable "linux_vms" {
  description = "VM label => availability zone. One VM is created per entry."
  type        = map(string)
}

variable "vm_size" {
  description = "VM size (1 or 2 vCPU)"
  type        = string
}

variable "admin_username" {
  description = "Admin username for SSH login"
  type        = string
}

variable "public_key_path" {
  description = "Path to the SSH public key copied onto the VMs"
  type        = string
}

variable "private_key_path" {
  description = "Path to the SSH private key used by the provisioner"
  type        = string
}

variable "ssh_timeout" {
  description = "How long the provisioner waits for SSH to become available"
  type        = string
  default     = "5m"
}

variable "ip_config_name" {
  description = "Name of the NIC IP configuration (also used by the load balancer)"
  type        = string
  default     = "internal"
}

variable "private_ip_allocation" {
  description = "Private IP allocation method"
  type        = string
  default     = "Dynamic"
}

variable "public_ip_allocation_method" {
  description = "Public IP allocation method"
  type        = string
  default     = "Static"
}

variable "public_ip_sku" {
  description = "Public IP SKU (Basic is retired)"
  type        = string
  default     = "Standard"
}

variable "os_disk_caching" {
  description = "OS disk caching mode"
  type        = string
  default     = "ReadWrite"
}

variable "os_disk_storage_type" {
  description = "OS disk storage type"
  type        = string
  default     = "Standard_LRS"
}

variable "image" {
  description = "Marketplace image for the Linux VMs"
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "8_2"
    version   = "latest"
  }
}

variable "network_watcher_extension" {
  description = "Network Watcher agent extension settings"
  type = object({
    publisher    = string
    type         = string
    version      = string
    auto_upgrade = bool
  })
  default = {
    publisher    = "Microsoft.Azure.NetworkWatcher"
    type         = "NetworkWatcherAgentLinux"
    version      = "1.0"
    auto_upgrade = true
  }
}

variable "azure_monitor_extension" {
  description = "Azure Monitor agent extension settings. Pinned to 1.21 with auto-upgrade off: newer versions don't support CentOS 8."
  type = object({
    publisher    = string
    type         = string
    version      = string
    auto_upgrade = bool
  })
  default = {
    publisher    = "Microsoft.Azure.Monitor"
    type         = "AzureMonitorLinuxAgent"
    version      = "1.21"
    auto_upgrade = false
  }
}
