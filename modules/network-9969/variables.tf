variable "humber_id" {
  description = "Last 4 digits of Humber ID, prefixed to every resource name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group to create the network in"
  type        = string
}

variable "tags" {
  description = "Tags applied to all network resources"
  type        = map(string)
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_address_prefixes" {
  description = "Address prefixes for the subnet"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "inbound_ports" {
  description = "Inbound allow rules: rule label => port"
  type        = map(number)
  default = {
    ssh   = 22
    rdp   = 3389
    winrm = 5985
    http  = 80
  }
}

variable "rule_priority_start" {
  description = "Priority of the first NSG rule"
  type        = number
  default     = 100
}

variable "rule_priority_step" {
  description = "Gap between consecutive NSG rule priorities"
  type        = number
  default     = 10
}

variable "rule_protocol" {
  description = "Protocol for the inbound rules"
  type        = string
  default     = "Tcp"
}

variable "allowed_source_prefix" {
  description = "Source address prefix allowed by the inbound rules"
  type        = string
  default     = "*"
}
