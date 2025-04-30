# variables.tf - Input variables for the ECS Terraform configuration

# General variables
variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "ecs-app"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-west-2"
}

variable "default_tags" {
  description = "Default tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "ecs-app"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

# Networking variables
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}

# ECS variables
variable "container_insights" {
  description = "Enable CloudWatch Container Insights for the cluster"
  type        = bool
  default     = true
}

variable "container_name" {
  description = "Name of the container"
  type        = string
  default     = "app"
}

variable "container_image" {
  description = "Docker image to run in the ECS cluster"
  type        = string
  default     = "nginx:latest"
}

variable "container_port" {
  description = "Port exposed by the container"
  type        = number
  default     = 80
}

variable "container_cpu" {
  description = "CPU units for the container (1024 = 1 vCPU)"
  type        = number
  default     = 256
}

variable "container_memory" {
  description = "Memory for the container in MiB"
  type        = number
  default     = 512
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

# Load balancer variables
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

# Auto scaling variables
variable "enable_autoscaling" {
  description = "Whether to enable auto scaling for the ECS service"
  type        = bool
  default     = true
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

# Monitoring variables
variable "enable_monitoring" {
  description = "Whether to enable enhanced monitoring and alerting"
  type        = bool
  default     = true
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

variable "create_sns_topic" {
  description = "Whether to create an SNS topic for notifications"
  type        = bool
  default     = true
}

variable "sns_email_list" {
  description = "List of email addresses for alarm notifications"
  type        = list(string)
  default     = []
  sensitive   = true
}