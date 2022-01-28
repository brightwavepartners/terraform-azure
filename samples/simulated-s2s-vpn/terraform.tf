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
  subscription_id = "35e439a2-e9f6-4dbf-a47e-cda3c1aef78e"
}