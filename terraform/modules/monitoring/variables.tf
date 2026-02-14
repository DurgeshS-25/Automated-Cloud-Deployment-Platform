# ============================================
# Monitoring Module Input Variables
# ============================================

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "alb_arn" {
  description = "ARN of the Application Load Balancer"
  type        = string
}

variable "target_group_arns" {
  description = "List of target group ARNs to monitor"
  type        = list(string)
}

variable "asg_names" {
  description = "List of Auto Scaling Group names to monitor"
  type        = list(string)
}
