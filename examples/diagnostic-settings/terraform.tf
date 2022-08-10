terraform {
  required_version = "~> 1.2.6"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.17.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.2.3"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.0.1"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.1.1"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  subscription_id = "35e439a2-e9f6-4dbf-a47e-cda3c1aef78e"
}
