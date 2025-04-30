# Terraform ECS Configuration

This repository contains Terraform configurations for deploying an Amazon ECS (Elastic Container Service) cluster following AWS best practices.

## Directory Structure

```
.
├── main.tf                 # Main Terraform configuration
├── variables.tf            # Input variables
├── outputs.tf              # Output values
├── terraform.tfvars.example # Example variable values (do not store actual secrets here)
├── modules/                # Modular components
│   ├── networking/         # VPC, subnets, security groups
│   ├── ecs/                # ECS cluster, services, task definitions
│   ├── autoscaling/        # Auto scaling configurations
│   ├── monitoring/         # CloudWatch alarms and monitoring
│   └── blue-green/         # Blue-Green deployment strategy
├── environments/           # Environment-specific configurations
│   ├── dev/
│   └── prod/
└── pipeline-templates/     # CI/CD pipeline templates
    └── terraform-cicd-pipeline.yml # Main CI/CD pipeline template
```

## Features

- **Modularity**: Separate concerns into reusable modules
- **Security**: No hardcoded secrets, proper IAM permissions
- **Scalability**: Auto-scaling based on metrics
- **Right-sizing**: Configurable instance types and resource allocation
- **Tagging**: Comprehensive resource tagging strategy
- **AWS Well-Architected Framework**: Follows best practices for operational excellence, security, reliability, performance efficiency, and cost optimization
- **CI/CD Pipeline**: Comprehensive pipeline with build, test, and deploy stages
- **Blue-Green Deployment**: Zero-downtime deployment strategy

## Usage

1. Clone this repository
2. Copy `terraform.tfvars.example` to `terraform.tfvars` and fill in your values
3. Run `terraform init` to initialize
4. Run `terraform plan` to preview changes
5. Run `terraform apply` to deploy the infrastructure

## Validation and Documentation

This repository includes scripts for validating Terraform and YAML templates, as well as generating documentation:

- **Terraform Validation**: Run `./scripts/validate-terraform.sh` to validate all Terraform configurations
- **YAML Validation**: Run `./scripts/validate-yaml.sh` to validate all YAML files
- **Documentation Generation**: Run `./scripts/generate-docs.sh` to generate documentation for all modules and configurations

These scripts are also integrated into the CI/CD pipeline to ensure code quality and up-to-date documentation.

## Requirements

- Terraform >= 1.0.0
- AWS CLI configured with appropriate permissions

## CI/CD Pipeline

This repository includes a comprehensive CI/CD pipeline template for deploying Terraform infrastructure. The pipeline includes:

- **Build Stage**: Validation, code quality analysis (SonarQube), and security scanning (Snyk)
- **Test Stage**: Terraform plan, unit tests, and compliance checks
- **Deploy Stage**: Approval gates, blue-green deployment, and notifications

### Using the Pipeline

To use the CI/CD pipeline:

1. Set up the required service connections and variable groups in your CI/CD platform
2. Configure the pipeline using the template at `pipeline-templates/terraform-cicd-pipeline.yml`
3. Run the pipeline to deploy your infrastructure

For detailed instructions, see the [Pipeline Templates README](./pipeline-templates/README.md).

## Blue-Green Deployment

This repository includes a module for implementing blue-green deployments with ECS. This enables zero-downtime deployments by:

1. Deploying new versions to a separate environment
2. Testing the new environment
3. Switching traffic to the new environment when ready

For more information, see the [Blue-Green Module README](./modules/blue-green/README.md).
