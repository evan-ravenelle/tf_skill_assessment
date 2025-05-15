environment = "prod"

# AWS Networking - Shared Services
aws_shared_vpc_cidr         = "172.16.0.0/22"
aws_shared_public_subnet    = "172.16.0.0/23"
aws_shared_private_subnet   = "172.16.2.0/23"
amazon_side_asn                 = 64512

# AWS Networking - Production
aws_prod_vpc_cidr           = "10.10.0.0/20"
aws_prod_public_subnet      = "10.10.1.0/24"
aws_prod_private_subnet     = "10.10.4.0/24"

# Azure Networking
azure_vnet_address_space    = "10.20.0.0/20"
azure_transit_subnet        = "10.20.0.0/26"
azure_container_subnet      = "10.20.4.0/24"
azure_vpn_client_address_pool       = "10.20.1.0/24"
azure_side_asn                   = 65515

# Resource Names
tgw_shared_secret_name      = "vpn_psk_name"

# Placeholder values for circular dependency
# These will need to be updated after initial deployment
use_ip_placeholder = true