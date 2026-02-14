# ============================================
# Monitoring Module Outputs
# ============================================

output "dashboard_url" {
  description = "URL to CloudWatch Dashboard"
  value       = "https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#dashboards:name=${aws_cloudwatch_dashboard.main.dashboard_name}"
}

output "alarm_arns" {
  description = "List of CloudWatch Alarm ARNs"
  value = [
    aws_cloudwatch_metric_alarm.alb_target_health.arn,
    aws_cloudwatch_metric_alarm.alb_response_time.arn,
    aws_cloudwatch_metric_alarm.alb_http_5xx.arn
  ]
}
