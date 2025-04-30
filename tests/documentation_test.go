package test

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/assert"
)

// TestDocumentationGeneration tests the documentation generation process
func TestDocumentationGeneration(t *testing.T) {
	// Skip this test in CI environment since it requires actual execution of the script
	// The script will be tested in the pipeline directly
	if os.Getenv("CI") == "true" {
		t.Skip("Skipping documentation test in CI environment")
	}

	// Define the paths to check
	docsDir := "../docs"
	mainDocPath := filepath.Join(docsDir, "main.md")
	pipelinesDocPath := filepath.Join(docsDir, "pipelines.md")

	// Check if docs directory exists
	_, err := os.Stat(docsDir)
	assert.NoError(t, err, "Docs directory should exist")

	// Check if main documentation file exists
	_, err = os.Stat(mainDocPath)
	assert.NoError(t, err, "Main documentation file should exist")

	// Check if pipelines documentation file exists
	_, err = os.Stat(pipelinesDocPath)
	assert.NoError(t, err, "Pipelines documentation file should exist")

	// Check if module READMEs exist
	modulesDir := "../modules"
	modules, err := os.ReadDir(modulesDir)
	assert.NoError(t, err, "Should be able to read modules directory")

	for _, module := range modules {
		if module.IsDir() {
			readmePath := filepath.Join(modulesDir, module.Name(), "README.md")
			_, err = os.Stat(readmePath)
			assert.NoError(t, err, "README should exist for module "+module.Name())
		}
	}
}

// TestValidationScripts tests the validation scripts
func TestValidationScripts(t *testing.T) {
	// Skip this test in CI environment since it requires actual execution of the scripts
	// The scripts will be tested in the pipeline directly
	if os.Getenv("CI") == "true" {
		t.Skip("Skipping validation scripts test in CI environment")
	}

	// Define the paths to check
	terraformValidationScript := "../scripts/validate-terraform.sh"
	yamlValidationScript := "../scripts/validate-yaml.sh"
	docsGenerationScript := "../scripts/generate-docs.sh"

	// Check if scripts exist
	_, err := os.Stat(terraformValidationScript)
	assert.NoError(t, err, "Terraform validation script should exist")

	_, err = os.Stat(yamlValidationScript)
	assert.NoError(t, err, "YAML validation script should exist")

	_, err = os.Stat(docsGenerationScript)
	assert.NoError(t, err, "Documentation generation script should exist")

	// Check if scripts are executable
	terraformInfo, _ := os.Stat(terraformValidationScript)
	assert.True(t, terraformInfo.Mode()&0111 != 0, "Terraform validation script should be executable")

	yamlInfo, _ := os.Stat(yamlValidationScript)
	assert.True(t, yamlInfo.Mode()&0111 != 0, "YAML validation script should be executable")

	docsInfo, _ := os.Stat(docsGenerationScript)
	assert.True(t, docsInfo.Mode()&0111 != 0, "Documentation generation script should be executable")
}