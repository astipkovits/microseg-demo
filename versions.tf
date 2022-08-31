terraform {
  required_providers {
    aviatrix = {
      source  = "aviatrixsystems/aviatrix"
      version = ">=2.23.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=2.64"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "> 3.0"
    }
  }
}