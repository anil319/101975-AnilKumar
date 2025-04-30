#!/bin/bash
set -e

echo "Starting Terraform validation..."

# Check if terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "Error: terraform is not installed"
    exit 1
fi

# Check if tflint is installed, install if not
if ! command -v tflint &> /dev/null; then
    echo "Installing TFLint..."
    curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
fi

# Check if checkov is installed, install if not
if ! command -v checkov &> /dev/null; then
    echo "Installing Checkov..."
    pip install checkov
fi

# Run terraform fmt check on the entire repository
echo "Running terraform fmt check..."
terraform fmt -check -recursive -diff

# Validate main configuration
echo "Validating main Terraform configuration..."
terraform -chdir=/workspace init -backend=false
terraform -chdir=/workspace validate

# Validate each module
for module_dir in /workspace/modules/*; do
    if [ -d "$module_dir" ]; then
        module_name=$(basename "$module_dir")
        echo "Validating module: $module_name"
        terraform -chdir="$module_dir" init -backend=false
        terraform -chdir="$module_dir" validate
        
        # Run TFLint on the module
        echo "Running TFLint on module: $module_name"
        tflint --chdir="$module_dir" || true  # Continue even if TFLint finds issues
    fi
done

# Validate each environment
for env_dir in /workspace/environments/*; do
    if [ -d "$env_dir" ]; then
        env_name=$(basename "$env_dir")
        echo "Validating environment: $env_name"
        terraform -chdir="$env_dir" init -backend=false
        terraform -chdir="$env_dir" validate
        
        # Run TFLint on the environment
        echo "Running TFLint on environment: $env_name"
        tflint --chdir="$env_dir" || true  # Continue even if TFLint finds issues
        
        # Run Checkov on the environment
        echo "Running Checkov on environment: $env_name"
        checkov -d "$env_dir" --quiet || true  # Continue even if Checkov finds issues
    fi
done

echo "Terraform validation completed successfully!"