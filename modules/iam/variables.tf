# modules/iam/variables.tf - Variables for the IAM module

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

variable "secrets_arns" {
  description = "List of ARNs for secrets that the ECS task needs access to"
  type        = list(string)
  default     = []
}

variable "task_policy_statements" {
  description = "List of IAM policy statements for the ECS task role"
  type        = list(any)
  default     = []
}