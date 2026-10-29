variable "humber_id" {
  type = string
}
variable "location" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "disk_size_gb" {
  type    = number
  default = 10
}
variable "tags" {
  type = map(string)
}
variable "vms" {
  description = "label => { vm_id, zone } - one data disk is made per entry"
  type = map(object({
    vm_id = string
    zone  = optional(string)
  }))
}
