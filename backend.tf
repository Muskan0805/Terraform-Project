# Remote state lives in its OWN storage account, in its OWN resource group,
# created ONCE by scripts/create-backend.sh (outside Terraform).
# That's on purpose: if Terraform managed the account holding its own state,
# "terraform destroy" would delete its own state file halfway through.
#
# Backend blocks can't use variables, so these values are literal.
# Run scripts/personalize.sh to swap 9969 for your Humber ID digits.
terraform {
  backend "azurerm" {
    resource_group_name  = "9969-tfstate-RG"
    storage_account_name = "9969tfstatesa"
    container_name       = "tfstate"
    key                  = "project-9969.tfstate"
  }
}
