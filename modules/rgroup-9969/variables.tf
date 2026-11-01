variable "humber_id" {
  description = "Last 4 digits of Humber ID, prefixed to every resource name"
  type        = string
}

variable "location" {
  description = "Azure region for the resource group"
  type        = string
}

variable "rg_suffix" {
  description = "Suffix for the resource group name"
  type        = string
  default     = "RG"
}

variable "tags" {
  description = "Tags applied to the resource group"
  type        = map(string)
}
