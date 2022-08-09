terraform {
  required_version = "~> 1.2.6"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.17.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "35e439a2-e9f6-4dbf-a47e-cda3c1aef78e"
}