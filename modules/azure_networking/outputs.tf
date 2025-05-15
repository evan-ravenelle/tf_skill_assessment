output "vnet_name" {
  description = "The name of the Virtual Network"
  value       = azurerm_virtual_network.this.name
}

output "container_subnet_name" {
  description = "Name of the container subnet"
  value       = azurerm_subnet.container.name
}

output "container_subnet_id" {
  description = "The ID of the container subnet in the VNET"
  value       = azurerm_subnet.container.id
}

output "transit_subnet_name" {
  description = "Name of the transit subnet"
  value       = azurerm_subnet.transit.name
}

output "vpn_gateway_id" {
  description = "VPN Gateway resource ID"
  value       = azurerm_virtual_network_gateway.this.id
}

output "vpn_gateway_public_ip" {
  value = azurerm_public_ip.vpn.ip_address
}