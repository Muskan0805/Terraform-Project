
locals {
  humber_id = "9969"          
  location  = "eastus" 

  common_tags = {
    Project        = "CCGC 5502 Terraform Project"
    Name           = "muskan"
    ExpirationDate = "2027-12-31"
    Environment    = "Learning"
  }

  vm_size        = "Standard_D2as_v4" # 2 vCPU / 4 GiB, cheapest of the allowed examples
  admin_username = "azureuser"

  # Map key = short VM label, value = availability zone.
  # Add a 4th entry here and for_each builds another VM - that's the "scalable" part.
  linux_vms = {
    vm1 = "1"
    vm2 = "2"
    vm3 = "3"
  }
}

# Passwords stay OUT of git. Set it before running Terraform:
# Used for the Windows VM and the PostgreSQL admin. Because it's supplied by the
# environment, "terraform apply --auto-approve" never stops to ask for it.
variable "admin_password" {
  type      = string
  sensitive = true
}

module "rgroup" {
  source    = "./modules/rgroup-9969"
  humber_id = local.humber_id
  location  = local.location
  tags      = local.common_tags
}

module "network" {
  source              = "./modules/network-9969"
  humber_id           = local.humber_id
  location            = local.location
  resource_group_name = module.rgroup.resource_group_name
  tags                = local.common_tags
}

module "common" {
  source              = "./modules/common-9969"
  humber_id           = local.humber_id
  location            = local.location
  resource_group_name = module.rgroup.resource_group_name
  tags                = local.common_tags
}

module "vmlinux" {
  source              = "./modules/vmlinux-9969"
  humber_id           = local.humber_id
  location            = local.location
  resource_group_name = module.rgroup.resource_group_name
  subnet_id           = module.network.subnet_id
  boot_diag_uri       = module.common.storage_account_blob_endpoint
  vm_size             = local.vm_size
  admin_username      = local.admin_username
  public_key_path     = "~/.ssh/id_rsa.pub"
  private_key_path    = "~/.ssh/id_rsa"
  linux_vms           = local.linux_vms
  tags                = local.common_tags
}

module "vmwindows" {
  source              = "./modules/vmwindows-9969"
  humber_id           = local.humber_id
  location            = local.location
  resource_group_name = module.rgroup.resource_group_name
  subnet_id           = module.network.subnet_id
  boot_diag_uri       = module.common.storage_account_blob_endpoint
  vm_size             = local.vm_size
  admin_username      = local.admin_username
  admin_password      = var.admin_password
  vm_count            = 1
  tags                = local.common_tags
}

module "datadisk" {
  source              = "./modules/datadisk-9969"
  humber_id           = local.humber_id
  location            = local.location
  resource_group_name = module.rgroup.resource_group_name
  disk_size_gb        = 10
  tags                = local.common_tags

  # One disk per VM. Zonal Linux VMs need their disk in the SAME zone;
  # the Windows VM sits in an availability set, so its disk has no zone.
  vms = merge(
    {
      for k, id in module.vmlinux.vm_ids : "linux-${k}" => {
        vm_id = id
        zone  = local.linux_vms[k]
      }
    },
    {
      for k, id in module.vmwindows.vm_ids : k => {
        vm_id = id
        zone  = null
      }
    }
  )
}

module "loadbalancer" {
  source              = "./modules/loadbalancer-9969"
  humber_id           = local.humber_id
  location            = local.location
  resource_group_name = module.rgroup.resource_group_name
  linux_nic_ids       = module.vmlinux.nic_ids
  ip_config_name      = module.vmlinux.ip_config_name
  tags                = local.common_tags
}

module "database" {
  source              = "./modules/database-9969"
  humber_id           = local.humber_id
  location            = "canadacentral"
  resource_group_name = module.rgroup.resource_group_name
  admin_username      = "pgadmin${local.humber_id}"
  admin_password      = var.admin_password
  tags                = local.common_tags
}
