# modules/monitoring/outputs.tf - Outputs from the monitoring module

output "sns_topic_arn" {
  description = "ARN of the SNS topic for alarms"
  value       = var.create_sns_topic ? aws_sns_topic.alarms[0].arn : null
}

output "cpu_alarm_arn" {
  description = "ARN of the CPU utilization alarm"
  value       = aws_cloudwatch_metric_alarm.cpu_utilization_high.arn
}

output "memory_alarm_arn" {
  description = "ARN of the memory utilization alarm"
  value       = aws_cloudwatch_metric_alarm.memory_utilization_high.arn
}

output "tasks_alarm_arn" {
  description = "ARN of the running tasks alarm"
  value       = aws_cloudwatch_metric_alarm.service_tasks_low.arn
}

output "dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  value       = var.create_dashboard ? aws_cloudwatch_dashboard.ecs_dashboard[0].dashboard_name : null
}

output "error_metric_name" {
  description = "Name of the error metric filter"
  value       = var.create_error_metric ? aws_cloudwatch_log_metric_filter.error_logs[0].name : null
}

output "error_alarm_arn" {
  description = "ARN of the error logs alarm"
  value       = var.create_error_metric ? aws_cloudwatch_metric_alarm.error_logs_alarm[0].arn : null
}