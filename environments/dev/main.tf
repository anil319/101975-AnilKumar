# environments/dev/main.tf - Development environment configuration

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region

  # Default tags applied to all resources
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = "dev"
      ManagedBy   = "terraform"
    }
  }
}

# Configure Terraform backend for state management
# Uncomment and configure as needed
# terraform {
#   backend "s3" {
#     bucket         = "your-terraform-state-bucket"
#     key            = "ecs-cluster/dev/terraform.tfstate"
#     region         = "us-west-2"
#     dynamodb_table = "terraform-locks"
#     encrypt        = true
#   }
# }

# Use the root module with environment-specific variables
module "ecs_cluster" {
  source = "../../"

  # General configuration
  project_name = var.project_name
  environment  = "dev"
  aws_region   = var.aws_region

  # Networking configuration
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

  # ECS configuration
  container_insights = true
  container_name     = var.container_name
  container_image    = var.container_image
  container_port     = var.container_port
  container_cpu      = 512  # Lower CPU for dev
  container_memory   = 1024 # Lower memory for dev
  desired_count      = 2    # Fewer tasks for dev

  # Auto scaling configuration
  enable_autoscaling = true
  min_capacity       = 2
  max_capacity       = 4  # Lower max capacity for dev
  cpu_target_value   = 70
  memory_target_value = 80

  # Monitoring configuration
  enable_monitoring = true
  create_sns_topic  = true
  sns_email_list    = var.sns_email_list
}