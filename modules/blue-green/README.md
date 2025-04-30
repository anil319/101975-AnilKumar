# Blue-Green Deployment Module for ECS

This module implements a blue-green deployment strategy for Amazon ECS services. It creates two separate ECS services (blue and green) and uses an Application Load Balancer to route traffic between them.

## Features

- Two separate ECS services (blue and green)
- Application Load Balancer for traffic routing
- Separate test endpoints for blue and green environments
- Configurable health checks
- Support for gradual traffic shifting

## Usage

```hcl
module "blue_green" {
  source = "./modules/blue-green"

  project_name         = "my-app"
  environment          = "prod"
  vpc_id               = module.networking.vpc_id
  private_subnet_ids   = module.networking.private_subnet_ids
  public_subnet_ids    = module.networking.public_subnet_ids
  ecs_cluster_id       = module.ecs.cluster_id
  task_definition_arn  = module.ecs.task_definition_arn
  container_name       = "app"
  container_port       = 80
  desired_count        = 3
  health_check_path    = "/health"
  lb_security_group_id = module.networking.lb_security_group_id
  ecs_security_group_id = module.networking.ecs_security_group_id
  
  # Blue-Green specific variables
  deployment_color             = "blue"
  enable_blue_green_deployment = true
  blue_green_deployment_state  = "active"
}
```

## Blue-Green Deployment Process

1. **Initial Setup**: Both blue and green environments are created, but only the active one (default: blue) receives traffic.

2. **Preparing for Deployment**:
   - Set `deployment_color` to the target environment (e.g., "green")
   - Set `blue_green_deployment_state` to "preparing"
   - Apply the changes to deploy the new version to the target environment without routing production traffic to it

3. **Testing the New Environment**:
   - Use the test endpoints (`blue_environment_url` or `green_environment_url`) to verify the new deployment

4. **Switching Traffic**:
   - Set `blue_green_deployment_state` to "active"
   - Apply the changes to route production traffic to the new environment

5. **Rollback (if needed)**:
   - Set `deployment_color` back to the previous environment
   - Set `blue_green_deployment_state` to "active"
   - Apply the changes to route traffic back to the previous environment

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| project_name | Name of the project | string | - | yes |
| environment | Environment (dev, staging, prod) | string | - | yes |
| vpc_id | ID of the VPC | string | - | yes |
| private_subnet_ids | IDs of the private subnets | list(string) | - | yes |
| public_subnet_ids | IDs of the public subnets | list(string) | - | yes |
| ecs_cluster_id | ID of the ECS cluster | string | - | yes |
| task_definition_arn | ARN of the task definition | string | - | yes |
| container_name | Name of the container | string | - | yes |
| container_port | Port exposed by the container | number | - | yes |
| desired_count | Desired count of task instances | number | 2 | no |
| health_check_path | Path for load balancer health check | string | "/" | no |
| lb_security_group_id | ID of the security group for the load balancer | string | - | yes |
| ecs_security_group_id | ID of the security group for the ECS tasks | string | - | yes |
| deployment_color | The deployment color to use (blue or green) | string | "blue" | no |
| enable_blue_green_deployment | Whether to enable blue-green deployment | bool | true | no |
| blue_green_deployment_state | The state of the blue-green deployment (preparing or active) | string | "active" | no |

## Outputs

| Name | Description |
|------|-------------|
| load_balancer_dns | DNS name of the load balancer |
| load_balancer_arn | ARN of the load balancer |
| blue_target_group_arn | ARN of the blue target group |
| green_target_group_arn | ARN of the green target group |
| blue_service_name | Name of the blue ECS service |
| green_service_name | Name of the green ECS service |
| current_deployment_color | The currently active deployment color |
| blue_environment_url | URL for the blue environment |
| green_environment_url | URL for the green environment |
| production_url | URL for the production environment |