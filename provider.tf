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
    subscription_id = "b5aaf0c5-9029-46d7-84e6-8c62506866c2"

}


terraform { 
  cloud { 
    
    organization = "Leomarto" 

    workspaces { 
      name = "leo1" 
    } 
  } 
}