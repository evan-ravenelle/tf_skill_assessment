variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "container_subnet_id" {
  description = "ID of the subnet where the container group will be deployed (VNET integration)"
  type        = string
}

variable "container_image" {
  description = "Container image to deploy"
  type        = string
  default     = "carrumhealth/helloworld:stable"
}

variable "location" {
  description = "Azure location"
  type        = string
}

variable "container_resource_group" {
  description = "Azure Container Resource Group Name (for container deployments)"
  type        = string
}