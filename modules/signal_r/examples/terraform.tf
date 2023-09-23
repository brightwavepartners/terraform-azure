terraform {
  backend "local" {}
  required_version = "~> 1.5.7"
  required_providers {
    azurerm = {
      source  = "registry.terraform.io/hashicorp/azurerm"
      version = "~>2.81"
    }
  }
}

provider "azurerm" {
  features {}
}