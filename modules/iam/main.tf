# modules/iam/main.tf - IAM roles and policies for ECS

# ECS task execution role
resource "aws_iam_role" "ecs_execution_role" {
  name = "${var.project_name}-${var.environment}-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-ecs-execution-role"
    Environment = var.environment
  }
}

# Attach the AWS managed policy for ECS task execution
resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Additional policy for accessing secrets if needed
resource "aws_iam_policy" "secrets_access" {
  count       = length(var.secrets_arns) > 0 ? 1 : 0
  name        = "${var.project_name}-${var.environment}-secrets-access-policy"
  description = "Allow access to specific secrets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["secretsmanager:GetSecretValue", "ssm:GetParameters", "ssm:GetParameter"]
        Effect   = "Allow"
        Resource = var.secrets_arns
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-secrets-access-policy"
    Environment = var.environment
  }
}

# Attach secrets policy if needed
resource "aws_iam_role_policy_attachment" "secrets_policy_attachment" {
  count      = length(var.secrets_arns) > 0 ? 1 : 0
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = aws_iam_policy.secrets_access[0].arn
}

# ECS task role (for application permissions)
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.project_name}-${var.environment}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-ecs-task-role"
    Environment = var.environment
  }
}

# Custom policy for the task role based on required permissions
resource "aws_iam_policy" "ecs_task_policy" {
  count       = length(var.task_policy_statements) > 0 ? 1 : 0
  name        = "${var.project_name}-${var.environment}-ecs-task-policy"
  description = "Custom policy for ECS tasks"

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = var.task_policy_statements
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-ecs-task-policy"
    Environment = var.environment
  }
}

# Attach custom task policy if needed
resource "aws_iam_role_policy_attachment" "ecs_task_policy_attachment" {
  count      = length(var.task_policy_statements) > 0 ? 1 : 0
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_task_policy[0].arn
}

# CloudWatch logs policy for task role
resource "aws_iam_policy" "cloudwatch_logs_policy" {
  name        = "${var.project_name}-${var.environment}-cloudwatch-logs-policy"
  description = "Allow writing to CloudWatch logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:log-group:/ecs/${var.project_name}-${var.environment}:*"
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-cloudwatch-logs-policy"
    Environment = var.environment
  }
}

# Attach CloudWatch logs policy to task role
resource "aws_iam_role_policy_attachment" "cloudwatch_logs_attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.cloudwatch_logs_policy.arn
}