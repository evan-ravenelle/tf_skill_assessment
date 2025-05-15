variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
}

variable "availability_zone" {
  description = "AWS Availability Zone"
  type        = string
}

variable "create_transit_gateway" {
  description = "Flag to create a Transit Gateway within the module."
  type        = bool
  default     = false
}

variable "transit_gateway_id" {
  description = "Transit Gateway ID to attach the VPC to if not created in this module. Ignored if create_transit_gateway is true."
  type        = string
  default     = ""
}
variable "azure_vpn_gateway_ip" {
  type = string
  description = "IP to the Azure VPN Gateway to attach to"
}
variable "vpn_psk_tun1" {
  default = null
  type = string
  description = "IPSec PSK to connect VPN tunnel 1"
}

variable "vpn_psk_tun2" {
  default = null
  type = string
  description = "IPSec PSK to connect VPN tunnel 2"
}

variable "amazon_side_asn" {
  description = "Amazon side ASN for the Transit Gateway."
  type        = number
  default     = 64512
}

variable "azure_side_asn" {
  default = 65515
  description = "ASN of the connecting network"
}


variable "create_vpn_endpoint" {
  description = "Boolean flag to create a VPN endpoint (Elastic IP)"
  type        = bool
  default     = false
}