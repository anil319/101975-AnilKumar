# modules/autoscaling/variables.tf - Variables for the autoscaling module

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

variable "min_capacity" {
  description = "Minimum number of tasks"
  type        = number
  default     = 2
}

variable "max_capacity" {
  description = "Maximum number of tasks"
  type        = number
  default     = 10
}

variable "cpu_target_value" {
  description = "Target CPU utilization percentage for auto scaling"
  type        = number
  default     = 70
}

variable "memory_target_value" {
  description = "Target memory utilization percentage for auto scaling"
  type        = number
  default     = 80
}

variable "scale_in_cooldown" {
  description = "Cooldown period in seconds before allowing another scale in activity"
  type        = number
  default     = 300
}

variable "scale_out_cooldown" {
  description = "Cooldown period in seconds before allowing another scale out activity"
  type        = number
  default     = 60
}

variable "enable_request_scaling" {
  description = "Whether to enable request count based scaling"
  type        = bool
  default     = false
}

variable "alb_arn_suffix" {
  description = "ARN suffix of the ALB (required for request count scaling)"
  type        = string
  default     = ""
}

variable "target_group_arn_suffix" {
  description = "ARN suffix of the target group (required for request count scaling)"
  type        = string
  default     = ""
}

variable "request_count_target_value" {
  description = "Target request count per target for auto scaling"
  type        = number
  default     = 1000
}

variable "scheduled_actions" {
  description = "List of scheduled scaling actions"
  type = list(object({
    schedule     = string
    min_capacity = number
    max_capacity = number
  }))
  default = []
}