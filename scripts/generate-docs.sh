#!/bin/bash
set -e

echo "Starting documentation generation..."

# Check if terraform-docs is installed, install if not
if ! command -v terraform-docs &> /dev/null; then
    echo "Installing terraform-docs..."
    curl -sSLo ./terraform-docs.tar.gz https://terraform-docs.io/dl/v0.16.0/terraform-docs-v0.16.0-$(uname)-amd64.tar.gz
    tar -xzf terraform-docs.tar.gz
    chmod +x terraform-docs
    sudo mv terraform-docs /usr/local/bin/terraform-docs
    rm -f terraform-docs.tar.gz
fi

# Create docs directory if it doesn't exist
mkdir -p /workspace/docs

# Generate main documentation
echo "Generating main documentation..."
terraform-docs markdown table --output-file /workspace/docs/main.md /workspace

# Generate documentation for each module
echo "Generating module documentation..."
for module_dir in /workspace/modules/*; do
    if [ -d "$module_dir" ]; then
        module_name=$(basename "$module_dir")
        echo "Generating documentation for module: $module_name"
        
        # Create module README if it doesn't exist
        if [ ! -f "$module_dir/README.md" ]; then
            cat > "$module_dir/README.md" << EOF
# $module_name Module

## Overview
This module provides $module_name functionality for the ECS deployment.

## Usage
\`\`\`hcl
module "$module_name" {
  source = "./modules/$module_name"
  # Add required variables here
}
\`\`\`

## Requirements
- Terraform >= 1.0.0
- AWS Provider

EOF
        fi
        
        # Generate documentation and append to README
        terraform-docs markdown table --output-mode inject "$module_dir"
    fi
done

# Generate documentation for environments
echo "Generating environment documentation..."
for env_dir in /workspace/environments/*; do
    if [ -d "$env_dir" ]; then
        env_name=$(basename "$env_dir")
        echo "Generating documentation for environment: $env_name"
        
        # Create environment README if it doesn't exist
        if [ ! -f "$env_dir/README.md" ]; then
            cat > "$env_dir/README.md" << EOF
# $env_name Environment

## Overview
This directory contains the Terraform configuration for the $env_name environment.

## Usage
\`\`\`bash
cd environments/$env_name
terraform init
terraform plan
terraform apply
\`\`\`

EOF
        fi
        
        # Generate documentation and append to README
        terraform-docs markdown table --output-mode inject "$env_dir"
    fi
done

# Generate pipeline documentation
echo "Generating pipeline documentation..."
cat > /workspace/docs/pipelines.md << EOF
# CI/CD Pipeline Documentation

## Overview
This document describes the CI/CD pipelines available in this repository.

## Pipeline Templates

EOF

# Document each pipeline template
for pipeline_file in /workspace/pipeline-templates/*.yml; do
    if [ -f "$pipeline_file" ]; then
        pipeline_name=$(basename "$pipeline_file")
        echo "Documenting pipeline template: $pipeline_name"
        
        # Extract description from pipeline file
        description=$(grep -A 5 "^# " "$pipeline_file" | grep -v "^#" | head -n 1)
        
        # Append to pipeline documentation
        cat >> /workspace/docs/pipelines.md << EOF
### $pipeline_name

\`\`\`yaml
$(cat "$pipeline_file" | head -n 20)
...
\`\`\`

EOF
    fi
done

# Update main README with links to documentation
echo "Updating main README with documentation links..."
if ! grep -q "## Documentation" /workspace/README.md; then
    cat >> /workspace/README.md << EOF

## Documentation

- [Main Configuration Documentation](./docs/main.md)
- [Pipeline Documentation](./docs/pipelines.md)
- [Module Documentation](./modules/)
- [Environment Documentation](./environments/)

EOF
fi

echo "Documentation generation completed successfully!"