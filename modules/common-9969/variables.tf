variable "humber_id" {
  description = "Last 4 digits of Humber ID, prefixed to every resource name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group to create the common services in"
  type        = string
}

variable "tags" {
  description = "Tags applied to all common services"
  type        = map(string)
}

variable "law_sku" {
  description = "Log Analytics workspace pricing tier"
  type        = string
  default     = "PerGB2018"
}

variable "law_retention_days" {
  description = "Days to keep Log Analytics data"
  type        = number
  default     = 30
}

variable "rsv_sku" {
  description = "Recovery Services vault SKU"
  type        = string
  default     = "Standard"
}

variable "rsv_storage_mode" {
  description = "Recovery Services vault storage redundancy"
  type        = string
  default     = "LocallyRedundant"
}

variable "storage_name_suffix" {
  description = "Suffix for the storage account name (lowercase letters and numbers only)"
  type        = string
  default     = "ccgc5502sa"
}

variable "storage_account_tier" {
  description = "Storage account performance tier"
  type        = string
  default     = "Standard"
}

variable "storage_replication_type" {
  description = "Storage account redundancy"
  type        = string
  default     = "LRS"

  validation {
    condition     = contains(["LRS", "ZRS", "GRS", "RAGRS", "GZRS", "RAGZRS"], var.storage_replication_type)
    error_message = "storage_replication_type must be one of LRS, ZRS, GRS, RAGRS, GZRS, RAGZRS."
  }
}

variable "storage_min_tls_version" {
  description = "Minimum TLS version for the storage account"
  type        = string
  default     = "TLS1_2"
}
