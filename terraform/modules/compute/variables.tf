# ============================================
# Compute Module Input Variables
# ============================================

variable "vpc_id" {
  description = "VPC ID where resources will be created"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for ALB"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for EC2 instances"
  type        = list(string)
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "app_port" {
  description = "Application port number"
  type        = number
}

variable "health_check_path" {
  description = "Health check endpoint path"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
}

variable "min_instances" {
  description = "Minimum number of instances in ASG"
  type        = number
}

variable "max_instances" {
  description = "Maximum number of instances in ASG"
  type        = number
}

variable "desired_instances" {
  description = "Desired number of instances in ASG"
  type        = number
}

variable "ecr_repository_url" {
  description = "ECR repository URL for Docker images"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "enable_detailed_monitoring" {
  description = "Enable detailed CloudWatch monitoring"
  type        = bool
  default     = true
}
