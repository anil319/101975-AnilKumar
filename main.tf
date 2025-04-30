# main.tf - Main Terraform configuration file for ECS deployment

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region

  # Default tags applied to all resources
  default_tags {
    tags = var.default_tags
  }
}

# Configure Terraform backend for state management
# Uncomment and configure as needed
# terraform {
#   backend "s3" {
#     bucket         = "your-terraform-state-bucket"
#     key            = "ecs-cluster/terraform.tfstate"
#     region         = "us-west-2"
#     dynamodb_table = "terraform-locks"
#     encrypt        = true
#   }
# }

# Create networking infrastructure
module "networking" {
  source = "./modules/networking"

  vpc_name             = "${var.project_name}-${var.environment}"
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  environment          = var.environment
}

# Create ECS cluster and related resources
module "ecs" {
  source = "./modules/ecs"

  project_name       = var.project_name
  environment        = var.environment
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
  public_subnet_ids  = module.networking.public_subnet_ids
  
  # ECS specific variables
  ecs_cluster_name   = "${var.project_name}-${var.environment}"
  container_insights = var.container_insights
  
  # Container configuration
  container_name     = var.container_name
  container_image    = var.container_image
  container_port     = var.container_port
  container_cpu      = var.container_cpu
  container_memory   = var.container_memory
  
  # Load balancer configuration
  create_load_balancer = var.create_load_balancer
  health_check_path    = var.health_check_path
  
  # Service configuration
  desired_count      = var.desired_count
  deployment_maximum_percent          = var.deployment_maximum_percent
  deployment_minimum_healthy_percent  = var.deployment_minimum_healthy_percent
  
  # Security
  execution_role_arn = module.iam.ecs_execution_role_arn
  task_role_arn      = module.iam.ecs_task_role_arn
}

# Create IAM roles and policies
module "iam" {
  source = "./modules/iam"

  project_name = var.project_name
  environment  = var.environment
}

# Configure auto scaling for ECS services
module "autoscaling" {
  source = "./modules/autoscaling"

  project_name       = var.project_name
  environment        = var.environment
  ecs_cluster_name   = module.ecs.cluster_name
  ecs_service_name   = module.ecs.service_name
  
  # Auto scaling configuration
  min_capacity       = var.min_capacity
  max_capacity       = var.max_capacity
  
  # Scaling metrics
  cpu_target_value   = var.cpu_target_value
  memory_target_value = var.memory_target_value
  
  # Only create if auto scaling is enabled
  count = var.enable_autoscaling ? 1 : 0
}

# Configure monitoring and alerting
module "monitoring" {
  source = "./modules/monitoring"

  project_name     = var.project_name
  environment      = var.environment
  ecs_cluster_name = module.ecs.cluster_name
  ecs_service_name = module.ecs.service_name
  
  # Alarm thresholds
  cpu_utilization_threshold    = var.cpu_utilization_threshold
  memory_utilization_threshold = var.memory_utilization_threshold
  
  # SNS topic for notifications
  create_sns_topic = var.create_sns_topic
  sns_email_list   = var.sns_email_list
  
  # Only create if monitoring is enabled
  count = var.enable_monitoring ? 1 : 0
}