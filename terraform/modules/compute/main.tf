# ============================================
# Compute Module - EC2, ALB, Auto Scaling
# ============================================

# Security Group for Application Load Balancer
resource "aws_security_group" "alb" {
  name_prefix = "${var.project_name}-alb-${var.environment}-"
  description = "Security group for Application Load Balancer"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-alb-sg-${var.environment}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Security Group for Application Instances
resource "aws_security_group" "app" {
  name_prefix = "${var.project_name}-app-${var.environment}-"
  description = "Security group for application instances"
  vpc_id      = var.vpc_id

  ingress {
    description     = "App port from ALB"
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description = "SSH from anywhere (restrict in production)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-app-sg-${var.environment}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${var.project_name}-alb-${var.environment}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection       = false
  enable_cross_zone_load_balancing = true
  enable_http2                     = true

  tags = {
    Name = "${var.project_name}-alb-${var.environment}"
  }
}

# Target Group - Blue
resource "aws_lb_target_group" "blue" {
  name     = "${var.project_name}-blue-${var.environment}"
  port     = var.app_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = var.health_check_path
    matcher             = "200"
  }

  deregistration_delay = 30

  tags = {
    Name        = "${var.project_name}-blue-tg-${var.environment}"
    Environment = "Blue"
  }
}

# Target Group - Green
resource "aws_lb_target_group" "green" {
  name     = "${var.project_name}-green-${var.environment}"
  port     = var.app_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = var.health_check_path
    matcher             = "200"
  }

  deregistration_delay = 30

  tags = {
    Name        = "${var.project_name}-green-tg-${var.environment}"
    Environment = "Green"
  }
}

# ALB Listener - HTTP
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue.arn
  }
}

# IAM Role for EC2 Instances
resource "aws_iam_role" "ec2" {
  name = "${var.project_name}-ec2-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-ec2-role-${var.environment}"
  }
}

# Attach policies to EC2 role
resource "aws_iam_role_policy_attachment" "ec2_ecr" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ec2_cloudwatch" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "ec2" {
  name = "${var.project_name}-ec2-profile-${var.environment}"
  role = aws_iam_role.ec2.name

  tags = {
    Name = "${var.project_name}-ec2-profile-${var.environment}"
  }
}

# Launch Template for Blue Environment
resource "aws_launch_template" "blue" {
  name_prefix   = "${var.project_name}-blue-${var.environment}-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2.name
  }

  vpc_security_group_ids = [aws_security_group.app.id]

  user_data = base64encode(templatefile("${path.module}/user-data.sh", {
    app_port    = var.app_port
    environment = "blue"
    ecr_repo    = var.ecr_repository_url
    aws_region  = var.aws_region
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.project_name}-blue-${var.environment}"
      Environment = "Blue"
    }
  }

  monitoring {
    enabled = var.enable_detailed_monitoring
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Launch Template for Green Environment
resource "aws_launch_template" "green" {
  name_prefix   = "${var.project_name}-green-${var.environment}-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2.name
  }

  vpc_security_group_ids = [aws_security_group.app.id]

  user_data = base64encode(templatefile("${path.module}/user-data.sh", {
    app_port    = var.app_port
    environment = "green"
    ecr_repo    = var.ecr_repository_url
    aws_region  = var.aws_region
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.project_name}-green-${var.environment}"
      Environment = "Green"
    }
  }

  monitoring {
    enabled = var.enable_detailed_monitoring
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group - Blue
resource "aws_autoscaling_group" "blue" {
  name                = "${var.project_name}-blue-asg-${var.environment}"
  vpc_zone_identifier = var.private_subnet_ids
  target_group_arns   = [aws_lb_target_group.blue.arn]
  health_check_type   = "ELB"
  health_check_grace_period = 300
  min_size            = var.min_instances
  max_size            = var.max_instances
  desired_capacity    = var.desired_instances

  launch_template {
    id      = aws_launch_template.blue.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-blue-${var.environment}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "Blue"
    propagate_at_launch = true
  }
}

# Auto Scaling Group - Green
resource "aws_autoscaling_group" "green" {
  name                = "${var.project_name}-green-asg-${var.environment}"
  vpc_zone_identifier = var.private_subnet_ids
  target_group_arns   = [aws_lb_target_group.green.arn]
  health_check_type   = "ELB"
  health_check_grace_period = 300
  min_size            = 0
  max_size            = var.max_instances
  desired_capacity    = 0

  launch_template {
    id      = aws_launch_template.green.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-green-${var.environment}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "Green"
    propagate_at_launch = true
  }
}
