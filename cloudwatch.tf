###############################################################################
# cloudwatch.tf
# SNS admin topic + CloudWatch Alarms
# NOTE: Aruba CPU/Status alarms are NOT included here.
#       Re-add them in a separate aruba_monitoring.tf when Aruba EC2
#       instances are deployed.
###############################################################################

# =============================================================================
# Admin SNS Topic — only created when admin_email is set
# =============================================================================
resource "aws_sns_topic" "admin_alerts" {
  count        = var.admin_email != "" ? 1 : 0
  name         = "Admin-Alerts-Topic"
  display_name = "SD-WAN Admin Alerts"
  tags         = { Name = "Admin-Alerts-Topic" }
}

resource "aws_sns_topic_subscription" "admin_email" {
  count     = var.admin_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.admin_alerts[0].arn
  protocol  = "email"
  endpoint  = var.admin_email
}

# Helper local — returns admin SNS ARN or null
locals {
  admin_sns_arn = var.admin_email != "" ? aws_sns_topic.admin_alerts[0].arn : null
}

# =============================================================================
# ALB Alarms
# =============================================================================
resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_hosts" {
  alarm_name          = "ALB-UnhealthyHosts"
  alarm_description   = "ALB unhealthy targets > 0"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "UnHealthyHostCount"
  statistic           = "Maximum"
  period              = 60
  evaluation_periods  = 2
  threshold           = 0
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    TargetGroup  = aws_lb_target_group.main.arn_suffix
    LoadBalancer = aws_lb.public.arn_suffix
  }

  alarm_actions = local.admin_sns_arn != null ? [local.admin_sns_arn] : []
}

resource "aws_cloudwatch_metric_alarm" "alb_high_response_time" {
  alarm_name          = "ALB-HighResponseTime"
  alarm_description   = "ALB target response time > 1 second"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "TargetResponseTime"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 2
  threshold           = 1
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = aws_lb.public.arn_suffix
  }

  alarm_actions = local.admin_sns_arn != null ? [local.admin_sns_arn] : []
}

resource "aws_cloudwatch_metric_alarm" "alb_5xx_errors" {
  alarm_name          = "ALB-High5xxErrors"
  alarm_description   = "ALB 5xx errors > 10 in 5 minutes"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "HTTPCode_Target_5XX_Count"
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 10
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = aws_lb.public.arn_suffix
  }

  alarm_actions = local.admin_sns_arn != null ? [local.admin_sns_arn] : []
}

# =============================================================================
# NAT Gateway Alarms
# =============================================================================
resource "aws_cloudwatch_metric_alarm" "nat_az1_errors" {
  alarm_name          = "NATGateway-AZ1-Errors"
  alarm_description   = "NAT Gateway AZ1 error count > 10"
  namespace           = "AWS/NATGateway"
  metric_name         = "ErrorPortAllocation"
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 10
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    NatGatewayId = aws_nat_gateway.egress_az1.id
  }

  alarm_actions = local.admin_sns_arn != null ? [local.admin_sns_arn] : []
}

resource "aws_cloudwatch_metric_alarm" "nat_az2_errors" {
  alarm_name          = "NATGateway-AZ2-Errors"
  alarm_description   = "NAT Gateway AZ2 error count > 10"
  namespace           = "AWS/NATGateway"
  metric_name         = "ErrorPortAllocation"
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 10
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    NatGatewayId = aws_nat_gateway.egress_az2.id
  }

  alarm_actions = local.admin_sns_arn != null ? [local.admin_sns_arn] : []
}

# =============================================================================
# Lambda Alarms
# =============================================================================
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "Lambda-TargetReg-Errors"
  alarm_description   = "Lambda target registration errors > 3"
  namespace           = "AWS/Lambda"
  metric_name         = "Errors"
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 3
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = aws_lambda_function.target_reg.function_name
  }

  alarm_actions = local.admin_sns_arn != null ? [local.admin_sns_arn] : []
}

resource "aws_cloudwatch_metric_alarm" "lambda_throttles" {
  alarm_name          = "Lambda-TargetReg-Throttles"
  alarm_description   = "Lambda throttles detected"
  namespace           = "AWS/Lambda"
  metric_name         = "Throttles"
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 0
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = aws_lambda_function.target_reg.function_name
  }

  alarm_actions = local.admin_sns_arn != null ? [local.admin_sns_arn] : []
}
