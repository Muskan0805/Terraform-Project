variable "humber_id" {
  type = string
}
variable "location" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "tags" {
  type = map(string)
}
variable "vnet_address_space" {
  type    = list(string)
  default = ["10.0.0.0/16"]
}
variable "subnet_address_prefixes" {
  type    = list(string)
  default = ["10.0.1.0/24"]
}
variable "inbound_ports" {
  description = "Rule label => port"
  type        = map(number)
  default = {
    ssh   = 22
    rdp   = 3389
    winrm = 5985
    http  = 80
  }
}
