variable "humber_id" {
  description = "Last 4 digits of Humber ID, prefixed to every resource name"
  type        = string
}

variable "location" {
  description = "Azure region for the database server"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group to create the database in"
  type        = string
}

variable "tags" {
  description = "Tags applied to the database server"
  type        = map(string)
}

variable "admin_username" {
  description = "PostgreSQL administrator login"
  type        = string
}

variable "admin_password" {
  description = "PostgreSQL administrator password"
  type        = string
  sensitive   = true
}

variable "postgres_version" {
  description = "PostgreSQL major version"
  type        = string
  default     = "16"
}

variable "sku_name" {
  description = "Compute tier and size (Burstable B1ms is the cheapest)"
  type        = string
  default     = "B_Standard_B1ms"
}

variable "storage_mb" {
  description = "Storage size in MB"
  type        = number
  default     = 32768
}

variable "storage_tier" {
  description = "Storage performance tier (P4 matches 32 GB)"
  type        = string
  default     = "P4"
}

variable "backup_retention_days" {
  description = "Days to keep automatic backups (7-35)"
  type        = number
  default     = 7

  validation {
    condition     = var.backup_retention_days >= 7 && var.backup_retention_days <= 35
    error_message = "backup_retention_days must be between 7 and 35."
  }
}

variable "geo_redundant_backup" {
  description = "Copy backups to a paired region"
  type        = bool
  default     = false
}

variable "public_network_access" {
  description = "Allow access over the public internet"
  type        = bool
  default     = true
}
