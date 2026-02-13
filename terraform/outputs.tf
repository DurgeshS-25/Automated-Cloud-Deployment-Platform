# ============================================
# Infrastructure Outputs
# ============================================

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "alb_dns_name" {
  description = "DNS name of Application Load Balancer"
  value       = module.compute.alb_dns_name
}

output "alb_url" {
  description = "Full URL to access the application"
  value       = "http://${module.compute.alb_dns_name}"
}

output "blue_target_group_arn" {
  description = "ARN of blue target group"
  value       = module.compute.blue_target_group_arn
}

output "green_target_group_arn" {
  description = "ARN of green target group"
  value       = module.compute.green_target_group_arn
}

output "ecr_repository_url" {
  description = "ECR repository URL for Docker images"
  value       = aws_ecr_repository.app.repository_url
}

output "deployment_instructions" {
  description = "Next steps for deployment"
  value       = <<-EOT
  
  ============================================
  ?? Infrastructure Deployed Successfully!
  ============================================
  
  Application URL: http://${module.compute.alb_dns_name}
  
  Next Steps:
  1. Push Docker image to: ${aws_ecr_repository.app.repository_url}
  2. Trigger GitHub Actions deployment
  3. Monitor at: https://console.aws.amazon.com/cloudwatch
  
  Blue-Green Deployment:
  - Blue Target Group:  ${module.compute.blue_target_group_arn}
  - Green Target Group: ${module.compute.green_target_group_arn}
  
  To destroy: terraform destroy
  ============================================
  EOT
}
