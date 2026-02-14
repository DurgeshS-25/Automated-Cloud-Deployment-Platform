# ============================================
# Monitoring Module - CloudWatch Dashboards & Alarms
# ============================================

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-dashboard-${var.environment}"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "TargetResponseTime", { stat = "Average" }],
            [".", "RequestCount", { stat = "Sum" }],
            [".", "HTTPCode_Target_5XX_Count", { stat = "Sum" }],
            [".", "HTTPCode_Target_4XX_Count", { stat = "Sum" }]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
          title  = "Application Load Balancer Metrics"
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", { stat = "Average" }],
            [".", "NetworkIn", { stat = "Sum" }],
            [".", "NetworkOut", { stat = "Sum" }]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
          title  = "EC2 Instance Metrics"
        }
      }
    ]
  })
}

# Alarm: Unhealthy Targets
resource "aws_cloudwatch_metric_alarm" "alb_target_health" {
  alarm_name          = "${var.project_name}-unhealthy-targets-${var.environment}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "HealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "Alert when less than 1 healthy target"
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = split("/", var.alb_arn)[1]
    TargetGroup  = split("/", var.target_group_arns[0])[1]
  }
}

# Alarm: High Response Time
resource "aws_cloudwatch_metric_alarm" "alb_response_time" {
  alarm_name          = "${var.project_name}-high-response-time-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "Alert when response time exceeds 1 second"
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = split("/", var.alb_arn)[1]
  }
}

# Alarm: HTTP 5XX Errors
resource "aws_cloudwatch_metric_alarm" "alb_http_5xx" {
  alarm_name          = "${var.project_name}-http-5xx-errors-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Sum"
  threshold           = "10"
  alarm_description   = "Alert when 5XX errors exceed 10 per minute"
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = split("/", var.alb_arn)[1]
  }
}

# Log Group for Application Logs
resource "aws_cloudwatch_log_group" "app" {
  name              = "/aws/ec2/${var.project_name}-${var.environment}"
  retention_in_days = 7

  tags = {
    Name = "${var.project_name}-logs-${var.environment}"
  }
}
