# ============================================
# Main Terraform Configuration
# Orchestrates all modules
# ============================================

# Get latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  project_name       = var.project_name
  environment        = var.environment
  enable_nat_gateway = var.enable_nat_gateway
  enable_flow_logs   = var.enable_flow_logs
}

# Compute Module (EC2, ALB, ASG)
module "compute" {
  source = "./modules/compute"

  vpc_id                    = module.vpc.vpc_id
  public_subnet_ids         = module.vpc.public_subnet_ids
  private_subnet_ids        = module.vpc.private_subnet_ids
  project_name              = var.project_name
  environment               = var.environment
  app_port                  = var.app_port
  health_check_path         = var.health_check_path
  instance_type             = var.instance_type
  ami_id                    = data.aws_ami.amazon_linux_2.id
  min_instances             = var.min_instances
  max_instances             = var.max_instances
  desired_instances         = var.desired_instances
  ecr_repository_url        = aws_ecr_repository.app.repository_url
  aws_region                = var.aws_region
  enable_detailed_monitoring = var.enable_monitoring
}

# Monitoring Module
module "monitoring" {
  source = "./modules/monitoring"

  project_name       = var.project_name
  environment        = var.environment
  alb_arn            = module.compute.alb_arn
  target_group_arns  = [module.compute.blue_target_group_arn, module.compute.green_target_group_arn]
  asg_names          = [module.compute.blue_asg_name, module.compute.green_asg_name]
}
