# modules/blue-green/outputs.tf - Outputs for Blue-Green deployment module

output "load_balancer_dns" {
  description = "DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "load_balancer_arn" {
  description = "ARN of the load balancer"
  value       = aws_lb.main.arn
}

output "blue_target_group_arn" {
  description = "ARN of the blue target group"
  value       = aws_lb_target_group.blue.arn
}

output "green_target_group_arn" {
  description = "ARN of the green target group"
  value       = aws_lb_target_group.green.arn
}

output "blue_service_name" {
  description = "Name of the blue ECS service"
  value       = aws_ecs_service.blue.name
}

output "green_service_name" {
  description = "Name of the green ECS service"
  value       = aws_ecs_service.green.name
}

output "current_deployment_color" {
  description = "The currently active deployment color"
  value       = var.deployment_color
}

output "blue_environment_url" {
  description = "URL for the blue environment"
  value       = "http://${aws_lb.main.dns_name}:8001"
}

output "green_environment_url" {
  description = "URL for the green environment"
  value       = "http://${aws_lb.main.dns_name}:8002"
}

output "production_url" {
  description = "URL for the production environment"
  value       = "http://${aws_lb.main.dns_name}"
}