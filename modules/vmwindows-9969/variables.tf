variable "humber_id" {
  description = "Last 4 digits of Humber ID, prefixed to every resource name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group to create the VM in"
  type        = string
}

variable "subnet_id" {
  description = "Subnet the VM NIC connects to"
  type        = string
}

variable "boot_diag_uri" {
  description = "Blob endpoint of the storage account used for boot diagnostics"
  type        = string
}

variable "tags" {
  description = "Tags applied to all Windows VM resources"
  type        = map(string)
}

variable "vm_count" {
  description = "Number of Windows VMs to create"
  type        = number
  default     = 1

  validation {
    condition     = var.vm_count >= 1
    error_message = "vm_count must be at least 1."
  }
}

variable "vm_size" {
  description = "VM size (1 or 2 vCPU)"
  type        = string
}

variable "admin_username" {
  description = "Local administrator username"
  type        = string
}

variable "admin_password" {
  description = "Local administrator password"
  type        = string
  sensitive   = true
}

variable "fault_domain_count" {
  description = "Fault domains in the availability set"
  type        = number
  default     = 2
}

variable "update_domain_count" {
  description = "Update domains in the availability set"
  type        = number
  default     = 5
}

variable "ip_config_name" {
  description = "Name of the NIC IP configuration"
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
  description = "Marketplace image for the Windows VM"
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
}

variable "antimalware_extension" {
  description = "Antimalware extension settings"
  type = object({
    publisher    = string
    type         = string
    version      = string
    auto_upgrade = bool
  })
  default = {
    publisher    = "Microsoft.Azure.Security"
    type         = "IaaSAntimalware"
    version      = "1.3"
    auto_upgrade = true
  }
}

variable "antimalware_realtime_protection" {
  description = "Turn on real-time protection"
  type        = bool
  default     = true
}

variable "antimalware_scan" {
  description = "Scheduled scan: day (1=Sun ... 7=Sat, 8=daily), time (minutes after midnight), type (Quick/Full)"
  type = object({
    enabled = bool
    day     = number
    time    = number
    type    = string
  })
  default = {
    enabled = true
    day     = 7
    time    = 120
    type    = "Quick"
  }
}
