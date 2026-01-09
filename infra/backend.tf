terraform {
  backend "azurerm" {
    resource_group_name  = "bestrong-tfstate-rg"
    storage_account_name = "bestrongtfctgk2d"
    container_name       = "tfstate"
    key                  = "infra-clean.tfstate"
  }
}
