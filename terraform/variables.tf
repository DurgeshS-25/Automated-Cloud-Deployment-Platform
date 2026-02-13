# ============================================
# Global Variables for Infrastructure
# ============================================

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "cloud-platform"
}

# ============================================
# Network Configuration
# ============================================

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

# ============================================
# Compute Configuration
# ============================================

variable "instance_type" {
  description = "EC2 instance type (t3.micro is free tier eligible)"
  type        = string
  default     = "t3.micro"
}

variable "min_instances" {
  description = "Minimum number of instances in ASG"
  type        = number
  default     = 1
}

variable "max_instances" {
  description = "Maximum number of instances in ASG"
  type        = number
  default     = 3
}

variable "desired_instances" {
  description = "Desired number of instances in ASG"
  type        = number
  default     = 1
}

# ============================================
# Application Configuration
# ============================================

variable "app_port" {
  description = "Application port"
  type        = number
  default     = 8080
}

variable "health_check_path" {
  description = "Health check endpoint for ALB"
  type        = string
  default     = "/actuator/health"
}

# ============================================
# Feature Flags (Cost Control)
# ============================================

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway (costs ~$32/month - set false for cost savings)"
  type        = bool
  default     = false
}

variable "enable_monitoring" {
  description = "Enable detailed CloudWatch monitoring"
  type        = bool
  default     = true
}

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs"
  type        = bool
  default     = false
}

# ============================================
# Deployment Strategy
# ============================================

variable "deployment_strategy" {
  description = "Deployment strategy: blue-green or rolling"
  type        = string
  default     = "blue-green"
  
  validation {
    condition     = contains(["blue-green", "rolling"], var.deployment_strategy)
    error_message = "Deployment strategy must be either blue-green or rolling"
  }
}
