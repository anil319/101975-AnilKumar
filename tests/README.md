# Terraform ECS Tests

This directory contains tests for the Terraform ECS modules using [Terratest](https://terratest.gruntwork.io/).

## Prerequisites

- Go 1.19 or later
- Terraform 1.0.0 or later
- AWS credentials configured

## Running Tests

To run all tests:

```bash
go test -v ./...
```

To run a specific test:

```bash
go test -v -run TestNetworkingModule
```

## Test Structure

- `networking_test.go`: Tests for the networking module
- Additional test files for other modules

## CI Integration

These tests are automatically run as part of the CI/CD pipeline. The pipeline will:

1. Run the tests in a clean environment
2. Report test results
3. Fail the build if tests fail

## Writing New Tests

When adding new modules or features, please add corresponding tests. A typical test should:

1. Set up Terraform options with test variables
2. Run `terraform init` and `terraform plan` (or `terraform apply` if needed)
3. Validate the expected resources and outputs
4. Clean up resources with `terraform destroy`

Example:

```go
func TestNewModule(t *testing.T) {
    terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
        TerraformDir: "../modules/new-module",
        Vars: map[string]interface{}{
            "key": "value",
        },
    })
    
    defer terraform.Destroy(t, terraformOptions)
    
    planOutput := terraform.InitAndPlan(t, terraformOptions)
    assert.Contains(t, planOutput, "expected_resource")
}
```