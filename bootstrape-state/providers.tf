terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.110.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6.0"
    }

  }
}

provider "azurerm" {
  features {}
  subscription_id = "d04f9414-d9f2-45a9-921f-3e63632fde59"
}
