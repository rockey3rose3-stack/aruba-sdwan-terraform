###############################################################################
# flow_logs.tf
# VPC Flow Logs — all four VPCs → CloudWatch Logs (30-day retention)
###############################################################################

# =============================================================================
# IAM Role for VPC Flow Logs delivery
# =============================================================================
resource "aws_iam_role" "flow_logs" {
  name = "sdwan-vpc-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "vpc-flow-logs.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = { Name = "sdwan-vpc-flow-logs-role" }
}

resource "aws_iam_role_policy" "flow_logs" {
  name = "CloudWatchLogPolicy"
  role = aws_iam_role.flow_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ]
      Resource = "*"
    }]
  })
}

# =============================================================================
# CloudWatch Log Groups
# =============================================================================
resource "aws_cloudwatch_log_group" "hub_flow" {
  name              = "/aws/vpc/flowlogs/hub"
  retention_in_days = 30
  tags              = { Name = "Hub-FlowLog-Group" }
}

resource "aws_cloudwatch_log_group" "compute_flow" {
  name              = "/aws/vpc/flowlogs/compute"
  retention_in_days = 30
  tags              = { Name = "Compute-FlowLog-Group" }
}

resource "aws_cloudwatch_log_group" "dev_flow" {
  name              = "/aws/vpc/flowlogs/dev"
  retention_in_days = 30
  tags              = { Name = "Dev-FlowLog-Group" }
}

resource "aws_cloudwatch_log_group" "egress_flow" {
  name              = "/aws/vpc/flowlogs/egress"
  retention_in_days = 30
  tags              = { Name = "Egress-FlowLog-Group" }
}

# =============================================================================
# Flow Logs
# =============================================================================
resource "aws_flow_log" "hub" {
  vpc_id          = aws_vpc.hub.id
  traffic_type    = "ALL"
  iam_role_arn    = aws_iam_role.flow_logs.arn
  log_destination = aws_cloudwatch_log_group.hub_flow.arn
  tags            = { Name = "Hub-VPC-FlowLog" }
}

resource "aws_flow_log" "compute" {
  vpc_id          = aws_vpc.compute.id
  traffic_type    = "ALL"
  iam_role_arn    = aws_iam_role.flow_logs.arn
  log_destination = aws_cloudwatch_log_group.compute_flow.arn
  tags            = { Name = "Compute-VPC-FlowLog" }
}

resource "aws_flow_log" "dev" {
  vpc_id          = aws_vpc.dev.id
  traffic_type    = "ALL"
  iam_role_arn    = aws_iam_role.flow_logs.arn
  log_destination = aws_cloudwatch_log_group.dev_flow.arn
  tags            = { Name = "Dev-VPC-FlowLog" }
}

resource "aws_flow_log" "egress" {
  vpc_id          = aws_vpc.egress.id
  traffic_type    = "ALL"
  iam_role_arn    = aws_iam_role.flow_logs.arn
  log_destination = aws_cloudwatch_log_group.egress_flow.arn
  tags            = { Name = "Egress-VPC-FlowLog" }
}
