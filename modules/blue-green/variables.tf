# modules/blue-green/variables.tf - Variables for Blue-Green deployment module

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

variable "ecs_cluster_id" {
  description = "ID of the ECS cluster"
  type        = string
}

variable "task_definition_arn" {
  description = "ARN of the task definition"
  type        = string
}

variable "container_name" {
  description = "Name of the container"
  type        = string
}

variable "container_port" {
  description = "Port exposed by the container"
  type        = number
}

variable "desired_count" {
  description = "Desired count of task instances"
  type        = number
  default     = 2
}

variable "health_check_path" {
  description = "Path for load balancer health check"
  type        = string
  default     = "/"
}

variable "lb_security_group_id" {
  description = "ID of the security group for the load balancer"
  type        = string
}

variable "ecs_security_group_id" {
  description = "ID of the security group for the ECS tasks"
  type        = string
}

variable "deployment_color" {
  description = "The deployment color to use (blue or green)"
  type        = string
  default     = "blue"
  
  validation {
    condition     = contains(["blue", "green"], var.deployment_color)
    error_message = "The deployment_color must be either 'blue' or 'green'."
  }
}

variable "enable_blue_green_deployment" {
  description = "Whether to enable blue-green deployment"
  type        = bool
  default     = true
}

variable "blue_green_deployment_state" {
  description = "The state of the blue-green deployment (preparing or active)"
  type        = string
  default     = "active"
  
  validation {
    condition     = contains(["preparing", "active"], var.blue_green_deployment_state)
    error_message = "The blue_green_deployment_state must be either 'preparing' or 'active'."
  }
}