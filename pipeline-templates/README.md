# Terraform CI/CD Pipeline Templates

This directory contains reusable CI/CD pipeline templates for Terraform deployments.

## Main Pipeline Template

The `terraform-cicd-pipeline.yml` template provides a comprehensive CI/CD pipeline for Terraform deployments with the following features:

### Features

- **Build, Test, and Deploy stages**: Complete pipeline workflow
- **SonarQube integration**: Code quality analysis
- **Snyk integration**: Security scanning
- **Centralized secrets management**: Secure handling of credentials
- **Approval gates**: Manual validation for production deployments
- **Slack notifications**: Automated notifications at key pipeline stages
- **Parallel jobs**: Efficient execution of independent tasks
- **Blue-Green deployment strategy**: Zero-downtime deployments

### Prerequisites

Before using this pipeline template, ensure you have:

1. **Azure DevOps**: Set up an Azure DevOps organization and project
2. **Service Connections**:
   - AWS service connection named `AWS-Terraform-ServiceConnection`
   - SonarQube service connection named `SonarQube`
   - Snyk service connection named `Snyk`
   - Slack service connection named `SlackConnection`

3. **Variable Groups**:
   - Create a variable group named `terraform-secrets` with the following variables:
     - `AWS_ACCESS_KEY_ID`: AWS access key with appropriate permissions
     - `AWS_SECRET_ACCESS_KEY`: AWS secret key
     - `TerraformStateBucket`: S3 bucket name for Terraform state
     - `TerraformLockTable`: DynamoDB table name for state locking
     - `SNS_EMAIL_LIST`: Comma-separated list of emails for notifications
     - `ApproverEmails`: Comma-separated list of emails for approval notifications
     - `SlackChannel`: Slack channel for notifications
     - `SlackTeam`: Slack team name

   See `terraform-secrets-example.yml` for a sample variable group configuration.

### Usage

To use this pipeline template in your Azure DevOps project:

1. Create a new pipeline in Azure DevOps
2. Select "YAML" as the pipeline type
3. Select "Use the classic editor" to create a pipeline without YAML
4. Select your repository and branch
5. Choose "Existing Azure Pipelines YAML file"
6. Enter the path to the template: `pipeline-templates/terraform-cicd-pipeline.yml`
7. Configure the pipeline parameters as needed

### Parameters

The pipeline accepts the following parameters:

| Parameter | Description | Default |
|-----------|-------------|---------|
| `environment` | Deployment environment (dev, prod) | `dev` |
| `terraformVersion` | Terraform version to use | `1.5.7` |
| `awsRegion` | AWS region for deployment | `us-west-2` |
| `runSonarQube` | Whether to run SonarQube analysis | `true` |
| `runSnyk` | Whether to run Snyk security scan | `true` |
| `slackNotifications` | Whether to send Slack notifications | `true` |
| `blueGreenDeployment` | Whether to use Blue-Green deployment | `true` |

## Environment-Specific Pipelines

This directory also includes environment-specific pipeline files that extend the main template:

### Development Pipeline

The `dev-pipeline.yml` file configures the pipeline for the development environment:

- Uses the main template with dev-specific parameters
- Disables blue-green deployment for simplicity
- Adds dev-specific variables

To use the dev pipeline:

```yaml
trigger:
  branches:
    include:
      - develop
  paths:
    include:
      - 'environments/dev/**'

extends:
  template: pipeline-templates/dev-pipeline.yml
```

### Production Pipeline

The `prod-pipeline.yml` file configures the pipeline for the production environment:

- Uses the main template with prod-specific parameters
- Enables blue-green deployment for zero downtime
- Adds prod-specific variables
- Includes approval gates

To use the prod pipeline:

```yaml
trigger:
  branches:
    include:
      - main
  paths:
    include:
      - 'environments/prod/**'

extends:
  template: pipeline-templates/prod-pipeline.yml
```

### Blue-Green Deployment

For Blue-Green deployments to work, your Terraform code needs to support the following variables:

- `deployment_color`: The target deployment color (blue or green)
- `enable_blue_green_deployment`: Whether Blue-Green deployment is enabled
- `blue_green_deployment_state`: The state of the deployment (preparing or active)

Your Terraform code should also output:
- `current_deployment_color`: The currently active deployment color
- `blue_environment_url`: URL for the blue environment
- `green_environment_url`: URL for the green environment

## Centralized Secrets Management

The pipeline uses a variable group named `terraform-secrets` for centralized secrets management. See `terraform-secrets-example.yml` for a sample configuration.

To set up the variable group:

1. Create a variable group named `terraform-secrets` in Azure DevOps
2. Add the required variables as shown in the example file
3. Mark sensitive values as secrets
4. Link the variable group to your pipeline

## Customization

You can customize this pipeline template by:

1. Forking the repository
2. Modifying the YAML file to suit your needs
3. Referencing your custom template in your pipeline

## Troubleshooting

Common issues:

1. **Missing service connections**: Ensure all required service connections are configured
2. **Missing variable group**: Create the `terraform-secrets` variable group with all required variables
3. **Terraform state issues**: Verify S3 bucket and DynamoDB table exist and are accessible
4. **Permission issues**: Ensure AWS credentials have appropriate permissions