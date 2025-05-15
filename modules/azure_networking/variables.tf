variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "location" {
  description = "Azure location"
  type        = string
}

variable "network_resource_group" {
  description = "Azure Networking Resource Group Name (for VNET, subnets, VPN Gateway/Connection)"
  type        = string
}

variable "vnet_address_space" {
  description = "Address space for the VNET"
  type        = string
}

variable "container_subnet_prefix" {
  description = "Address prefix for container subnet"
  type        = string
}

variable "transit_subnet_prefix" {
  description = "Address prefix for transit subnet"
  type        = string
}

variable "vpn_client_address_pool" {
  description = "VPN client address pool (CIDR block)"
  type        = string
}

variable "aws_transit_gateway_vpn_ip" {
  description = "AWS Transit Gateway VPN endpoint IP from the shared services VPC"
  type        = string
}

variable "vpn_shared_key" {
  description = "Shared key for the VPN connection"
  type        = string
}

variable "aws_address_space" {
  description = "Address space for the AWS network (for the local network gateway)"
  type        = string
}

variable "azure_side_asn" {
  default = 65515
}

variable "amazon_side_asn" {
  default = 64512
  description = "ASN of the Amazon side of BGP connection"
}