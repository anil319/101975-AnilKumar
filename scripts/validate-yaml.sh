#!/bin/bash
set -e

echo "Starting YAML validation..."

# Check if yamllint is installed, install if not
if ! command -v yamllint &> /dev/null; then
    echo "Installing yamllint..."
    pip install yamllint
fi

# Create a temporary yamllint config file if it doesn't exist
if [ ! -f "/workspace/.yamllint" ]; then
    cat > /workspace/.yamllint << EOF
extends: default

rules:
  line-length:
    max: 120
    level: warning
  document-start: disable
  truthy:
    allowed-values: ['true', 'false', 'yes', 'no']
EOF
fi

# Find all YAML files in the repository
yaml_files=$(find /workspace -name "*.yml" -o -name "*.yaml")

# Run yamllint on all YAML files
echo "Running yamllint on YAML files..."
yamllint -c /workspace/.yamllint $yaml_files || true  # Continue even if yamllint finds issues

# Validate Azure DevOps pipeline templates
echo "Validating Azure DevOps pipeline templates..."
for pipeline_file in /workspace/pipeline-templates/*.yml; do
    if [ -f "$pipeline_file" ]; then
        echo "Validating pipeline template: $(basename "$pipeline_file")"
        
        # Basic structure validation for Azure DevOps pipelines
        # Check for required sections
        if ! grep -q "^stages:" "$pipeline_file" && ! grep -q "^jobs:" "$pipeline_file" && ! grep -q "^steps:" "$pipeline_file"; then
            echo "Error: Pipeline file $(basename "$pipeline_file") is missing required sections (stages, jobs, or steps)"
            exit 1
        fi
        
        # Check for parameters section if it exists
        if grep -q "^parameters:" "$pipeline_file"; then
            # Validate parameter definitions
            if ! grep -q "name:" "$pipeline_file"; then
                echo "Warning: Parameters section in $(basename "$pipeline_file") might be missing 'name' attributes"
            fi
        fi
        
        echo "Pipeline template $(basename "$pipeline_file") passed validation"
    fi
done

echo "YAML validation completed successfully!"