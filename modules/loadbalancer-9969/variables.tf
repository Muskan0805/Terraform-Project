variable "humber_id" {
  type = string
}
variable "location" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "linux_nic_ids" {
  description = "VM label => NIC id for every VM that goes behind the LB"
  type        = map(string)
}
variable "ip_config_name" {
  type = string
}
variable "tags" {
  type = map(string)
}
