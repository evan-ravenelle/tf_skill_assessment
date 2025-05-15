terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# Azure Container Module
# Deploys a containerized application on Azure Container Instances (ACI) with VNET integration.
resource "azurerm_container_group" "this" {
  name                = "${var.environment}-aci"
  location            = var.location
  resource_group_name = var.container_resource_group
  os_type             = "Linux"

  # Deploy ACI into the subnet provided via VNET integration.
  subnet_ids = [var.container_subnet_id]

  container {
    name   = "app"
    image  = var.container_image
    cpu    = 0.5
    memory = 1.0
    ports {
      port     = 80
      protocol = "TCP"
    }
  }

  tags = {
    environment = var.environment
  }
}