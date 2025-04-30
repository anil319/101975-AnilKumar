# modules/monitoring/main.tf - CloudWatch alarms and monitoring for ECS

# Create SNS topic for alarms if enabled
resource "aws_sns_topic" "alarms" {
  count = var.create_sns_topic ? 1 : 0
  name  = "${var.project_name}-${var.environment}-alarms"

  tags = {
    Name        = "${var.project_name}-${var.environment}-alarms"
    Environment = var.environment
  }
}

# Subscribe email addresses to the SNS topic
resource "aws_sns_topic_subscription" "email_subscription" {
  count     = var.create_sns_topic ? length(var.sns_email_list) : 0
  topic_arn = aws_sns_topic.alarms[0].arn
  protocol  = "email"
  endpoint  = var.sns_email_list[count.index]
}

# CPU utilization alarm
resource "aws_cloudwatch_metric_alarm" "cpu_utilization_high" {
  alarm_name          = "${var.project_name}-${var.environment}-cpu-utilization-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = var.cpu_utilization_threshold
  alarm_description   = "This metric monitors ECS CPU utilization"
  alarm_actions       = var.create_sns_topic ? [aws_sns_topic.alarms[0].arn] : []
  ok_actions          = var.create_sns_topic ? [aws_sns_topic.alarms[0].arn] : []

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-cpu-alarm"
    Environment = var.environment
  }
}

# Memory utilization alarm
resource "aws_cloudwatch_metric_alarm" "memory_utilization_high" {
  alarm_name          = "${var.project_name}-${var.environment}-memory-utilization-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = var.memory_utilization_threshold
  alarm_description   = "This metric monitors ECS memory utilization"
  alarm_actions       = var.create_sns_topic ? [aws_sns_topic.alarms[0].arn] : []
  ok_actions          = var.create_sns_topic ? [aws_sns_topic.alarms[0].arn] : []

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-memory-alarm"
    Environment = var.environment
  }
}

# Service running tasks alarm
resource "aws_cloudwatch_metric_alarm" "service_tasks_low" {
  alarm_name          = "${var.project_name}-${var.environment}-service-tasks-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "RunningTaskCount"
  namespace           = "ECS/ContainerInsights"
  period              = 60
  statistic           = "Average"
  threshold           = var.minimum_running_tasks
  alarm_description   = "This metric monitors the number of running ECS tasks"
  alarm_actions       = var.create_sns_topic ? [aws_sns_topic.alarms[0].arn] : []
  ok_actions          = var.create_sns_topic ? [aws_sns_topic.alarms[0].arn] : []

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-tasks-alarm"
    Environment = var.environment
  }
}

# Create a CloudWatch dashboard for the ECS service
resource "aws_cloudwatch_dashboard" "ecs_dashboard" {
  count          = var.create_dashboard ? 1 : 0
  dashboard_name = "${var.project_name}-${var.environment}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ClusterName", var.ecs_cluster_name, "ServiceName", var.ecs_service_name]
          ]
          period = 300
          stat   = "Average"
          region = data.aws_region.current.name
          title  = "CPU Utilization"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ECS", "MemoryUtilization", "ClusterName", var.ecs_cluster_name, "ServiceName", var.ecs_service_name]
          ]
          period = 300
          stat   = "Average"
          region = data.aws_region.current.name
          title  = "Memory Utilization"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["ECS/ContainerInsights", "RunningTaskCount", "ClusterName", var.ecs_cluster_name, "ServiceName", var.ecs_service_name]
          ]
          period = 300
          stat   = "Average"
          region = data.aws_region.current.name
          title  = "Running Tasks"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", var.alb_arn_suffix]
          ]
          period = 300
          stat   = "Sum"
          region = data.aws_region.current.name
          title  = "Request Count"
        }
      }
    ]
  })
}

# Create a CloudWatch Log Metric Filter for error logs
resource "aws_cloudwatch_log_metric_filter" "error_logs" {
  count          = var.create_error_metric ? 1 : 0
  name           = "${var.project_name}-${var.environment}-error-logs"
  pattern        = var.error_log_pattern
  log_group_name = var.log_group_name

  metric_transformation {
    name      = "${var.project_name}-${var.environment}-error-count"
    namespace = "ECS/Errors"
    value     = "1"
  }
}

# Create an alarm for error logs
resource "aws_cloudwatch_metric_alarm" "error_logs_alarm" {
  count               = var.create_error_metric ? 1 : 0
  alarm_name          = "${var.project_name}-${var.environment}-error-logs-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "${var.project_name}-${var.environment}-error-count"
  namespace           = "ECS/Errors"
  period              = 60
  statistic           = "Sum"
  threshold           = var.error_threshold
  alarm_description   = "This metric monitors error logs in the ECS service"
  alarm_actions       = var.create_sns_topic ? [aws_sns_topic.alarms[0].arn] : []
  ok_actions          = var.create_sns_topic ? [aws_sns_topic.alarms[0].arn] : []

  tags = {
    Name        = "${var.project_name}-${var.environment}-error-logs-alarm"
    Environment = var.environment
  }
}

# Data source for current region
data "aws_region" "current" {}