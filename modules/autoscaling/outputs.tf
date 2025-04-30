# modules/autoscaling/outputs.tf - Outputs from the autoscaling module

output "autoscaling_target_arn" {
  description = "ARN of the auto scaling target"
  value       = aws_appautoscaling_target.ecs_target.arn
}

output "autoscaling_target_id" {
  description = "ID of the auto scaling target"
  value       = aws_appautoscaling_target.ecs_target.id
}

output "cpu_scaling_policy_arn" {
  description = "ARN of the CPU scaling policy"
  value       = aws_appautoscaling_policy.ecs_cpu_policy.arn
}

output "memory_scaling_policy_arn" {
  description = "ARN of the memory scaling policy"
  value       = aws_appautoscaling_policy.ecs_memory_policy.arn
}

output "request_count_scaling_policy_arn" {
  description = "ARN of the request count scaling policy"
  value       = var.enable_request_scaling ? aws_appautoscaling_policy.ecs_request_count_policy[0].arn : null
}