variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the container service will run"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where the container service will run (typically a private subnet)"
  type        = string
}

variable "container_image" {
  description = "Container image to deploy"
  type        = string
  default     = "carrumhealth/helloworld:stable"
}