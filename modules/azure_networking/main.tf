terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# Azure Networking Module
# Creates an Azure VNET with two subnets (one for container workloads and one for transit connectivity).
# Provisions a VPN Gateway and VPN connection that connects to the AWS hub's VPN endpoint.
resource "azurerm_virtual_network" "this" {
  name                = "${var.environment}-vnet"
  address_space       = [var.vnet_address_space]
  location            = var.location
  resource_group_name = var.network_resource_group
}

resource "azurerm_subnet" "container" {
  name                 = "${var.environment}-container-subnet"
  resource_group_name  = var.network_resource_group
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.container_subnet_prefix]
}

resource "azurerm_subnet" "transit" {
  name                 = "${var.environment}-transit-subnet"
  resource_group_name  = var.network_resource_group
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.transit_subnet_prefix]
}

resource "azurerm_public_ip" "vpn" {
  name                = "${var.environment}-vpn-ip"
  location            = var.location
  resource_group_name = var.network_resource_group
  allocation_method   = "Dynamic"
}


resource "azurerm_virtual_network_gateway" "this" {
  name                = "${var.environment}-vpn-gateway"
  location            = var.location
  resource_group_name = var.network_resource_group
  type                = "Vpn"
  vpn_type            = "RouteBased"
  sku                 = "VpnGw1"

  ip_configuration {
    name                 = "vnetGatewayConfig"
    public_ip_address_id = azurerm_public_ip.vpn.id
    subnet_id            = azurerm_subnet.transit.id
  }

  vpn_client_configuration {
    address_space = [var.vpn_client_address_pool]
  }

  # Add BGP configuration for dynamic connections
  enable_bgp = true
  bgp_settings {
    asn = var.azure_side_asn
    peering_addresses {
      ip_configuration_name = "vnetGatewayConfig"
      apipa_addresses = [
      cidrhost("169.254.21.0/30", 2),
      cidrhost("169.254.22.0/30", 2)
      ]
    }
  }
}

# Define a local network gateway representing the AWS side.
resource "azurerm_local_network_gateway" "aws_vpn" {
  name                = "${var.environment}-aws-local-network-gateway"
  location            = var.location
  resource_group_name = var.network_resource_group
  gateway_address     = var.aws_transit_gateway_vpn_ip
  address_space       = [var.aws_address_space]

  bgp_settings {
    asn                 = var.amazon_side_asn
    bgp_peering_address = cidrhost("169.254.21.0/30", 1)
  }
}

resource "azurerm_virtual_network_gateway_connection" "this" {
  name                       = "${var.environment}-vpn-connection"
  location                   = var.location
  resource_group_name        = var.network_resource_group
  virtual_network_gateway_id = azurerm_virtual_network_gateway.this.id
  local_network_gateway_id   = azurerm_local_network_gateway.aws_vpn.id
  type                       = "IPsec"
  shared_key                 = var.vpn_shared_key
  enable_bgp                 = true

}
