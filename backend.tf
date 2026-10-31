terraform {
  backend "azurerm" {
    resource_group_name  = "9969-tfstate-RG"
    storage_account_name = "9969tfstatesa"
    container_name       = "tfstate"
    key                  = "project-9969.tfstate"
  }
}
