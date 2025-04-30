# modules/ecs/variables.tf - Variables for the ECS module

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs of the private subnets"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "IDs of the public subnets"
  type        = list(string)
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "container_insights" {
  description = "Enable CloudWatch Container Insights for the cluster"
  type        = bool
  default     = true
}

variable "container_name" {
  description = "Name of the container"
  type        = string
}

variable "container_image" {
  description = "Docker image to run in the ECS cluster"
  type        = string
}

variable "container_port" {
  description = "Port exposed by the container"
  type        = number
}

variable "container_cpu" {
  description = "CPU units for the container (1024 = 1 vCPU)"
  type        = number
}

variable "container_memory" {
  description = "Memory for the container in MiB"
  type        = number
}

variable "container_environment" {
  description = "Environment variables for the container"
  type        = map(string)
  default     = {}
}

variable "container_secrets" {
  description = "Secrets for the container from SSM Parameter Store or Secrets Manager"
  type        = map(string)
  default     = {}
}

variable "desired_count" {
  description = "Desired count of task instances"
  type        = number
  default     = 2
}

variable "deployment_maximum_percent" {
  description = "Maximum percent of tasks that can be running during a deployment"
  type        = number
  default     = 200
}

variable "deployment_minimum_healthy_percent" {
  description = "Minimum percent of tasks that must remain healthy during a deployment"
  type        = number
  default     = 100
}

variable "execution_role_arn" {
  description = "ARN of the ECS execution role"
  type        = string
}

variable "task_role_arn" {
  description = "ARN of the ECS task role"
  type        = string
}

variable "create_load_balancer" {
  description = "Whether to create a load balancer for the ECS service"
  type        = bool
  default     = true
}

variable "health_check_path" {
  description = "Path for load balancer health check"
  type        = string
  default     = "/"
}

variable "certificate_arn" {
  description = "ARN of the SSL certificate for HTTPS"
  type        = string
  default     = ""
}

variable "ecs_tasks_security_group_id" {
  description = "ID of the security group for ECS tasks"
  type        = string
  default     = ""
}

variable "alb_security_group_id" {
  description = "ID of the security group for ALB"
  type        = string
  default     = ""
}