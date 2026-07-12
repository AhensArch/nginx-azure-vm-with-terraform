terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0" # Keeps it within version 3.x
    }
  }
}

provider "azurerm" {
  features {} # This block is mandatory for the azurerm provider
  #skip_provider_registration = true
  #resource_provider_registrations = "none"
}