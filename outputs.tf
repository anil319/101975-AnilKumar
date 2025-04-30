# outputs.tf - Output values from the ECS Terraform configuration

# Networking outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.networking.private_subnet_ids
}

# ECS outputs
output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs.cluster_name
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = module.ecs.cluster_arn
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = module.ecs.service_name
}

output "task_definition_arn" {
  description = "ARN of the task definition"
  value       = module.ecs.task_definition_arn
}

# Load balancer outputs
output "load_balancer_dns" {
  description = "DNS name of the load balancer"
  value       = var.create_load_balancer ? module.ecs.load_balancer_dns : null
}

output "load_balancer_arn" {
  description = "ARN of the load balancer"
  value       = var.create_load_balancer ? module.ecs.load_balancer_arn : null
}

# Auto scaling outputs
output "autoscaling_target_arn" {
  description = "ARN of the auto scaling target"
  value       = var.enable_autoscaling ? module.autoscaling[0].autoscaling_target_arn : null
}

output "cpu_scaling_policy_arn" {
  description = "ARN of the CPU scaling policy"
  value       = var.enable_autoscaling ? module.autoscaling[0].cpu_scaling_policy_arn : null
}

output "memory_scaling_policy_arn" {
  description = "ARN of the memory scaling policy"
  value       = var.enable_autoscaling ? module.autoscaling[0].memory_scaling_policy_arn : null
}

# Monitoring outputs
output "cloudwatch_log_group" {
  description = "Name of the CloudWatch log group"
  value       = module.ecs.cloudwatch_log_group
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic for alarms"
  value       = var.enable_monitoring && var.create_sns_topic ? module.monitoring[0].sns_topic_arn : null
}

# IAM outputs
output "ecs_execution_role_arn" {
  description = "ARN of the ECS execution role"
  value       = module.iam.ecs_execution_role_arn
}

output "ecs_task_role_arn" {
  description = "ARN of the ECS task role"
  value       = module.iam.ecs_task_role_arn
}