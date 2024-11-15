terraform {
  backend "local" {}
  required_version = "~> 1.9.8"
  required_providers {
    azapi = {
      source = "azure/azapi"
      version = "2.0.1"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.3.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.2"
    }
  }
}

provider "azapi" {
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = false
    }
  }
  subscription_id = var.subscription_id
}

