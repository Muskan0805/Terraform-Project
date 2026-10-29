variable "humber_id" {
  type = string
}
variable "location" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "subnet_id" {
  type = string
}
variable "boot_diag_uri" {
  type = string
}
variable "vm_size" {
  type = string
}
variable "admin_username" {
  type = string
}
variable "public_key_path" {
  type = string
}
variable "private_key_path" {
  type = string
}
variable "tags" {
  type = map(string)
}
variable "linux_vms" {
  description = "VM label => availability zone. One VM is built per entry."
  type        = map(string)
}
variable "ip_config_name" {
  type    = string
  default = "internal"
}
variable "image" {
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
