variable "environment" {
    type = string
    default = "dev"
}

variable "tgw_shared_secret_name" {
    default = null
    description = "Name of the secret to retrieve as the shared key for IPSec cnxn."
}

variable "use_ip_placeholder" {
    default = false
}

variable "azure_vnet_address_space" {
    type    = string
    default = "10.20.0.0/20" # 10.20.0.0 - 10.20.15.255
}

variable "azure_transit_subnet" {
    type    = string
    default = "10.20.0.0/26"
}

variable "azure_vpn_client_address_pool" {
    type    = string
    default = "10.20.1.0/24"
}

variable "azure_container_subnet" {
    type    = string
    default = "10.20.4.0/24"
}

variable "aws_prod_vpc_cidr" {
    type    = string
    default = "10.10.0.0/20"
}

variable "aws_prod_public_subnet" {
    type    = string
    default = "10.10.1.0/24"
}

variable "aws_prod_private_subnet" {
    type    = string
    default = "10.10.4.0/24"
}

variable "aws_shared_vpc_cidr" {
    type    = string
    default = "172.16.0.0/22"
}

variable "aws_shared_public_subnet" {
    type    = string
    default = "172.16.0.0/23"
}

variable "aws_shared_private_subnet" {
    type    = string
    default = "172.16.2.0/23"
}

variable "amazon_side_asn" {
    type    = string
    default = "64512"
}

variable "azure_side_asn" {
    type    = string
    default = "65515"
}