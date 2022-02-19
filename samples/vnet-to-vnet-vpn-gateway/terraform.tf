terraform {
  required_version = "~> 1.1.4"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.93.1"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}