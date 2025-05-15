terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# AWS Networking Module
# This module creates a VPC with public and private subnets.
# Optionally, it creates a Transit Gateway if create_transit_gateway is true,
# and attaches the VPC to that TGW.
# Optionally, it creates an Elastic IP as a VPN endpoint if create_vpn_endpoint is true.

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.environment}-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.environment}-public-subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.availability_zone
  tags = {
    Name = "${var.environment}-private-subnet"
  }
}

# Optionally create a Transit Gateway if requested.
resource "aws_ec2_transit_gateway" "this" {
  count           = var.create_transit_gateway ? 1 : 0
  description     = "${var.environment} Transit Gateway"
  amazon_side_asn = var.amazon_side_asn
  tags = {
    Name = "${var.environment}-tgw"
  }
}

locals {
  tgw_id = var.create_transit_gateway ? aws_ec2_transit_gateway.this[0].id : var.transit_gateway_id
}

# Attach the VPC to the Transit Gateway if one is available.
resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  count              = local.tgw_id != "" ? 1 : 0
  transit_gateway_id = local.tgw_id
  vpc_id             = aws_vpc.this.id
  subnet_ids         = [aws_subnet.private.id]
  tags = {
    Name = "${var.environment}-tgw-attachment"
  }
}

# Optionally create an Elastic IP to serve as the VPN endpoint.
resource "aws_eip" "vpn_endpoint" {
  count = var.create_vpn_endpoint ? 1 : 0
  vpc   = true
  tags = {
    Name = "${var.environment}-vpn-endpoint"
  }
}


resource "aws_vpn_connection" "azure" {
  count = var.create_vpn_endpoint ? 1 : 0
  customer_gateway_id = aws_customer_gateway.this.id
  transit_gateway_id = aws_ec2_transit_gateway.this.id

  type = "ipsec.1"
  tunnel1_preshared_key = var.vpn_psk_tun1
  tunnel1_inside_cidr = "169.254.21.0/30"

  tunnel2_preshared_key = var.vpn_psk_tun2
  tunnel2_inside_cidr = "169.254.22.0/30"


  tags = {
      Name = "${var.environment}-azure-vpn"
    }

}

resource "aws_customer_gateway" "this" {
  count = var.create_vpn_endpoint ? 1 : 0
  bgp_asn = var.azure_side_asn
  ip_address = aws_eip.vpn_endpoint.public_ip

  type = "ipsec.1"
  tags = {
    Name = "${var.environment}-aws-cgw"
  }
}