terraform {
  backend "local" {}
  required_version = "~> 1.1.3"
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