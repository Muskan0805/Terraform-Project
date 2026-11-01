variable "humber_id" {
  description = "Last 4 digits of Humber ID, prefixed to every resource name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group to create the load balancer in"
  type        = string
}

variable "tags" {
  description = "Tags applied to the load balancer resources"
  type        = map(string)
}

variable "linux_nic_ids" {
  description = "VM label => NIC id for every VM placed behind the load balancer"
  type        = map(string)
}

variable "ip_config_name" {
  description = "Name of the NIC IP configuration added to the backend pool"
  type        = string
}

variable "lb_sku" {
  description = "Load balancer and frontend public IP SKU"
  type        = string
  default     = "Standard"
}

variable "public_ip_allocation_method" {
  description = "Frontend public IP allocation method"
  type        = string
  default     = "Static"
}

variable "frontend_zones" {
  description = "Zones for the frontend public IP (all three = zone-redundant)"
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "rule_protocol" {
  description = "Load-balancing rule protocol"
  type        = string
  default     = "Tcp"
}

variable "frontend_port" {
  description = "Port the load balancer listens on"
  type        = number
  default     = 80
}

variable "backend_port" {
  description = "Port traffic is sent to on the VMs"
  type        = number
  default     = 80
}

variable "probe_protocol" {
  description = "Health probe protocol"
  type        = string
  default     = "Tcp"
}

variable "probe_port" {
  description = "Port the health probe checks"
  type        = number
  default     = 80
}

variable "disable_outbound_snat" {
  description = "VMs have their own public IPs, so the rule doesn't need outbound SNAT"
  type        = bool
  default     = true
}
