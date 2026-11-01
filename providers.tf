terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}

# azurerm v4 needs to know which subscription to use.
# We don't hardcode it here - set it once per terminal session with:
#   export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
provider "azurerm" {
  features {
    resource_group {
      # lets "terraform destroy" remove the RG even if Azure dropped
      # something extra into it that Terraform doesn't track
      prevent_deletion_if_contains_resources = false
    }
    virtual_machine {
      delete_os_disk_on_deletion = true
    }
  }
}
