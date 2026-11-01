variable "humber_id" {
  description = "Last 4 digits of Humber ID, prefixed to every resource name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group to create the disks in"
  type        = string
}

variable "tags" {
  description = "Tags applied to the disks"
  type        = map(string)
}

variable "vms" {
  description = "label => { vm_id, zone }. One data disk is created and attached per entry."
  type = map(object({
    vm_id = string
    zone  = optional(string)
  }))
}

variable "disk_size_gb" {
  description = "Size of each data disk in GB"
  type        = number
  default     = 10

  validation {
    condition     = var.disk_size_gb > 0
    error_message = "disk_size_gb must be greater than 0."
  }
}

variable "storage_account_type" {
  description = "Disk storage type"
  type        = string
  default     = "Standard_LRS"
}

variable "create_option" {
  description = "How the disk is created"
  type        = string
  default     = "Empty"
}

variable "lun" {
  description = "Logical unit number the disk is attached at"
  type        = number
  default     = 0
}

variable "caching" {
  description = "Caching mode for the attached disk"
  type        = string
  default     = "ReadWrite"
}
