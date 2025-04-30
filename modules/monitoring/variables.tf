# modules/monitoring/variables.tf - Variables for the monitoring module

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "ecs_service_name" {
  description = "Name of the ECS service"
  type        = string
}

variable "cpu_utilization_threshold" {
  description = "Threshold for CPU utilization alarm"
  type        = number
  default     = 85
}

variable "memory_utilization_threshold" {
  description = "Threshold for memory utilization alarm"
  type        = number
  default     = 85
}

variable "minimum_running_tasks" {
  description = "Minimum number of running tasks"
  type        = number
  default     = 2
}

variable "create_sns_topic" {
  description = "Whether to create an SNS topic for notifications"
  type        = bool
  default     = true
}

variable "sns_email_list" {
  description = "List of email addresses for alarm notifications"
  type        = list(string)
  default     = []
}

variable "create_dashboard" {
  description = "Whether to create a CloudWatch dashboard"
  type        = bool
  default     = true
}

variable "alb_arn_suffix" {
  description = "ARN suffix of the ALB for dashboard metrics"
  type        = string
  default     = ""
}

variable "create_error_metric" {
  description = "Whether to create a metric filter for error logs"
  type        = bool
  default     = true
}

variable "error_log_pattern" {
  description = "Pattern to match for error logs"
  type        = string
  default     = "ERROR"
}

variable "log_group_name" {
  description = "Name of the CloudWatch log group"
  type        = string
  default     = ""
}

variable "error_threshold" {
  description = "Threshold for error logs alarm"
  type        = number
  default     = 5
}