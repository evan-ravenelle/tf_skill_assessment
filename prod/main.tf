terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 4.0"
        }
        azurerm = {
            source = "hashicorp/azurerm"
            version = "~> 3.0"
        }
    }
}


locals {
    # set environment only once
    environment = var.environment
    az_resource_group_name_prefix = "carrum-app-${local.environment}"
}



module "aws_transit_gateway_networking" {
    source = "../modules/aws_networking"
    providers = {
        aws = aws.shared
    }
    environment = local.environment

    availability_zone = "us-west-2b"

    vpc_cidr            = var.aws_shared_vpc_cidr
    public_subnet_cidr  = var.aws_shared_public_subnet
    private_subnet_cidr = var.aws_shared_private_subnet

    amazon_side_asn = var.amazon_side_asn

    create_transit_gateway = true
    create_vpn_endpoint    = true

    azure_vpn_gateway_ip = module.azure_prod_networking.vpn_gateway_public_ip
}


module "aws_prod_networking" {
    source = "../modules/aws_networking"
    providers = {
        aws = aws
    }
    environment = local.environment

    availability_zone = "us-west-2b"

    vpc_cidr            = var.aws_prod_vpc_cidr
    public_subnet_cidr  = var.aws_prod_public_subnet
    private_subnet_cidr = var.aws_prod_private_subnet
    transit_gateway_id = module.aws_transit_gateway_networking.transit_gateway_id
    azure_vpn_gateway_ip = var.use_ip_placeholder ? "169.254.169.254" : module.azure_prod_networking.vpn_gateway_public_ip
    vpn_psk_tun1 = data.aws_secretsmanager_secret_version.ipsec_psk.secret_string
    vpn_psk_tun2 = data.aws_secretsmanager_secret_version.ipsec_psk.secret_string
}

module "aws_prod_container" {
    source = "../modules/aws_container"
    providers = {
        aws = aws
    }

    environment = local.environment
    subnet_id = module.aws_prod_networking.private_subnet_id  # assuming this should have a private IP
    vpc_id = module.aws_prod_networking.vpc_id
}


data "aws_secretsmanager_secret_version" "ipsec_psk" {
    provider = aws.shared
    secret_id = "tun1_psk"
}


module "azure_prod_networking" {
    source = "../modules/azure_networking"
    providers = {
        azurerm = azurerm
    }
    environment = local.environment

    aws_address_space          = module.aws_prod_networking.vpc_cidr
    aws_transit_gateway_vpn_ip = var.use_ip_placeholder ? "169.254.169.254" : module.aws_transit_gateway_networking.vpn_endpoint_ip

    location               = "westus2"
    network_resource_group = "${local.az_resource_group_name_prefix}-networking"

    vnet_address_space      = var.azure_vnet_address_space
    transit_subnet_prefix   = var.azure_transit_subnet
    vpn_client_address_pool = var.azure_vpn_client_address_pool
    container_subnet_prefix = var.azure_container_subnet

    vpn_shared_key             = data.aws_secretsmanager_secret_version.ipsec_psk

}


module "azure_prod_container" {
    source = "../modules/azure_container"
    providers = {
        azurerm = azurerm
    }
    environment = local.environment

    container_resource_group = "${local.az_resource_group_name_prefix}-containers"
    container_subnet_id      = module.azure_prod_networking.container_subnet_id
    location                 = "westus2"

}


