output "container_service_endpoint" {
  description = "ECS Service Name (as a proxy for the endpoint)"
  value       = aws_ecs_service.this.name
}