package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// TestNetworkingModule tests the networking module
func TestNetworkingModule(t *testing.T) {
	// Construct the terraform options with default retryable errors
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// Set the path to the Terraform code that will be tested
		TerraformDir: "../modules/networking",

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"vpc_name":             "test-vpc",
			"vpc_cidr":             "10.0.0.0/16",
			"availability_zones":   []string{"us-west-2a", "us-west-2b"},
			"public_subnet_cidrs":  []string{"10.0.1.0/24", "10.0.2.0/24"},
			"private_subnet_cidrs": []string{"10.0.11.0/24", "10.0.12.0/24"},
			"environment":          "test",
		},
	})

	// Clean up resources with "terraform destroy" at the end of the test
	defer terraform.Destroy(t, terraformOptions)

	// Run "terraform init" and "terraform plan" and return the plan output
	planOutput := terraform.InitAndPlan(t, terraformOptions)

	// Verify that the plan would create the expected resources
	// This is a simple check to ensure the plan contains the expected resources
	assert.Contains(t, planOutput, "aws_vpc.main")
	assert.Contains(t, planOutput, "aws_subnet.public")
	assert.Contains(t, planOutput, "aws_subnet.private")
	assert.Contains(t, planOutput, "aws_internet_gateway.main")
	assert.Contains(t, planOutput, "aws_nat_gateway.main")
}

// TestBlueGreenModule tests the blue-green deployment module
func TestBlueGreenModule(t *testing.T) {
	// Skip this test in CI environment since it requires actual AWS resources
	t.Skip("Skipping blue-green module test in CI environment")

	// Construct the terraform options with default retryable errors
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// Set the path to the Terraform code that will be tested
		TerraformDir: "../modules/blue-green",

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"project_name":                "test-project",
			"environment":                 "test",
			"vpc_id":                      "vpc-12345",
			"private_subnet_ids":          []string{"subnet-1", "subnet-2"},
			"public_subnet_ids":           []string{"subnet-3", "subnet-4"},
			"ecs_cluster_id":              "ecs-cluster-1",
			"task_definition_arn":         "arn:aws:ecs:us-west-2:123456789012:task-definition/test:1",
			"container_name":              "test-container",
			"container_port":              80,
			"lb_security_group_id":        "sg-12345",
			"ecs_security_group_id":       "sg-67890",
			"deployment_color":            "blue",
			"enable_blue_green_deployment": true,
			"blue_green_deployment_state": "active",
		},
	})

	// Run "terraform init" and "terraform plan" and return the plan output
	planOutput := terraform.InitAndPlan(t, terraformOptions)

	// Verify that the plan would create the expected resources
	assert.Contains(t, planOutput, "aws_lb.main")
	assert.Contains(t, planOutput, "aws_lb_target_group.blue")
	assert.Contains(t, planOutput, "aws_lb_target_group.green")
	assert.Contains(t, planOutput, "aws_ecs_service.blue")
	assert.Contains(t, planOutput, "aws_ecs_service.green")
}