output "container_service_endpoint" {
  description = "Private IP of the deployed ACI Container Group"
  value       = azurerm_container_group.this.ip_address
}