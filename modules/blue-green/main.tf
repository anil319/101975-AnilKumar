# modules/blue-green/main.tf - Blue-Green deployment module for ECS

locals {
  is_blue_active  = var.deployment_color == "blue" && var.blue_green_deployment_state == "active"
  is_green_active = var.deployment_color == "green" && var.blue_green_deployment_state == "active"
  
  # Determine which environment gets the traffic
  active_target_group_arn = local.is_blue_active ? aws_lb_target_group.blue.arn : (
    local.is_green_active ? aws_lb_target_group.green.arn : aws_lb_target_group.blue.arn
  )
  
  # Tags for resources
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
  
  blue_tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-blue"
    Color = "blue"
  })
  
  green_tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-green"
    Color = "green"
  })
}

# Create load balancer
resource "aws_lb" "main" {
  name               = "${var.project_name}-${var.environment}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.lb_security_group_id]
  subnets            = var.public_subnet_ids
  
  tags = local.common_tags
}

# Create blue target group
resource "aws_lb_target_group" "blue" {
  name        = "${var.project_name}-${var.environment}-blue-tg"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  
  health_check {
    enabled             = true
    interval            = 30
    path                = var.health_check_path
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    protocol            = "HTTP"
    matcher             = "200-299"
  }
  
  tags = local.blue_tags
  
  lifecycle {
    create_before_destroy = true
  }
}

# Create green target group
resource "aws_lb_target_group" "green" {
  name        = "${var.project_name}-${var.environment}-green-tg"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  
  health_check {
    enabled             = true
    interval            = 30
    path                = var.health_check_path
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    protocol            = "HTTP"
    matcher             = "200-299"
  }
  
  tags = local.green_tags
  
  lifecycle {
    create_before_destroy = true
  }
}

# Create listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = local.active_target_group_arn
  }
  
  tags = local.common_tags
}

# Create blue ECS service
resource "aws_ecs_service" "blue" {
  name            = "${var.project_name}-${var.environment}-blue"
  cluster         = var.ecs_cluster_id
  task_definition = var.task_definition_arn
  desired_count   = local.is_blue_active || !var.enable_blue_green_deployment ? var.desired_count : 0
  launch_type     = "FARGATE"
  
  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = false
  }
  
  load_balancer {
    target_group_arn = aws_lb_target_group.blue.arn
    container_name   = var.container_name
    container_port   = var.container_port
  }
  
  deployment_controller {
    type = "ECS"
  }
  
  tags = local.blue_tags
  
  lifecycle {
    ignore_changes = [desired_count]
  }
}

# Create green ECS service
resource "aws_ecs_service" "green" {
  name            = "${var.project_name}-${var.environment}-green"
  cluster         = var.ecs_cluster_id
  task_definition = var.task_definition_arn
  desired_count   = local.is_green_active || !var.enable_blue_green_deployment ? var.desired_count : 0
  launch_type     = "FARGATE"
  
  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = false
  }
  
  load_balancer {
    target_group_arn = aws_lb_target_group.green.arn
    container_name   = var.container_name
    container_port   = var.container_port
  }
  
  deployment_controller {
    type = "ECS"
  }
  
  tags = local.green_tags
  
  lifecycle {
    ignore_changes = [desired_count]
  }
}

# Create test endpoints for blue/green environments
resource "aws_lb_listener" "blue_test" {
  load_balancer_arn = aws_lb.main.arn
  port              = 8001
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue.arn
  }
  
  tags = local.blue_tags
}

resource "aws_lb_listener" "green_test" {
  load_balancer_arn = aws_lb.main.arn
  port              = 8002
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.green.arn
  }
  
  tags = local.green_tags
}