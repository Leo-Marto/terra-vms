terraform {
  required_version = ">=0.12"

  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~>1.5"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.0.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {

  features {
        resource_group {
        prevent_deletion_if_contains_resources = false
  }
  }
    subscription_id = "9231757f-3f4f-4855-b9b4-6c33f4f49163"

}

terraform { 
  cloud { 
    
    organization = "Leomarto" 

    workspaces { 
      name = "leo1" 
    } 
  } 
}