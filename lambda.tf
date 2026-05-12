###############################################################################
# lambda.tf
# Lambda function — auto-registers/deregisters Compute ASG IPs with ALB target group
###############################################################################

# =============================================================================
# CloudWatch Log Group
# =============================================================================
resource "aws_cloudwatch_log_group" "lambda_target_reg" {
  name              = "/aws/lambda/asg-target-registration"
  retention_in_days = 14
  tags              = { Name = "Lambda-TargetReg-LogGroup" }
}

# =============================================================================
# IAM Role for Lambda
# =============================================================================
resource "aws_iam_role" "target_reg_lambda" {
  name = "sdwan-lambda-target-reg-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = { Name = "Lambda-TargetReg-Role" }
}

resource "aws_iam_role_policy_attachment" "lambda_basic_exec" {
  role       = aws_iam_role.target_reg_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_reg_policy" {
  name = "RegTgPolicy"
  role = aws_iam_role.target_reg_lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["elasticloadbalancing:RegisterTargets", "elasticloadbalancing:DeregisterTargets"]
        Resource = aws_lb_target_group.main.arn
      },
      {
        Effect   = "Allow"
        Action   = "ec2:DescribeInstances"
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = "autoscaling:CompleteLifecycleAction"
        Resource = "arn:aws:autoscaling:${var.aws_region}:*:autoScalingGroup:*:autoScalingGroupName/${aws_autoscaling_group.compute.name}"
      }
    ]
  })
}

# =============================================================================
# Lambda Function (inline Python 3.12)
# =============================================================================
resource "aws_lambda_function" "target_reg" {
  function_name = "asg-target-registration"
  role          = aws_iam_role.target_reg_lambda.arn
  runtime       = "python3.12"
  handler       = "index.handler"
  timeout       = 60
  filename      = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      TARGET_GROUP_ARN = aws_lb_target_group.main.arn
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic_exec,
    aws_cloudwatch_log_group.lambda_target_reg,
  ]

  tags = { Name = "asg-target-registration" }
}

# Package the inline Python code as a zip for Terraform
resource "local_file" "lambda_source" {
  filename = "${path.module}/lambda/index.py"
  content  = <<-PYTHON
import boto3, json, os
elbv2 = boto3.client('elbv2')
ec2   = boto3.client('ec2')
asg   = boto3.client('autoscaling')
TG_ARN = os.environ['TARGET_GROUP_ARN']

def ip_of_instance(instance_id):
    r = ec2.describe_instances(InstanceIds=[instance_id])
    for res in r['Reservations']:
        for inst in res['Instances']:
            for eni in inst.get('NetworkInterfaces', []):
                if eni.get('Attachment', {}).get('DeviceIndex', 0) == 0:
                    for addr in eni.get('PrivateIpAddresses', []):
                        if addr.get('Primary', False):
                            return addr['PrivateIpAddress']
    return None

def handler(event, context):
    try:
        msg       = event['Records'][0]['Sns']['Message']
        data      = json.loads(msg)
        lifecycle = data['LifecycleTransition'].split(':')[-1]
        iid       = data['EC2InstanceId']
        hook      = data['LifecycleHookName']
        asg_name  = data['AutoScalingGroupName']
        token     = data['LifecycleActionToken']

        ip = ip_of_instance(iid)
        if ip:
            target = {'Id': ip, 'Port': 80}
            if lifecycle == 'EC2_INSTANCE_LAUNCHING':
                elbv2.register_targets(TargetGroupArn=TG_ARN, Targets=[target])
            elif lifecycle == 'EC2_INSTANCE_TERMINATING':
                elbv2.deregister_targets(TargetGroupArn=TG_ARN, Targets=[target])

        asg.complete_lifecycle_action(
            LifecycleHookName=hook,
            AutoScalingGroupName=asg_name,
            LifecycleActionToken=token,
            LifecycleActionResult='CONTINUE'
        )
        return {"status": "ok", "lifecycle": lifecycle, "instance": iid, "ip": ip}
    except Exception as e:
        print(f"Error: {str(e)}")
        return {"status": "error", "error": str(e)}
  PYTHON
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda.zip"
  depends_on  = [local_file.lambda_source]
}

# =============================================================================
# SNS → Lambda subscription and permission
# =============================================================================
resource "aws_sns_topic_subscription" "lambda" {
  topic_arn = aws_sns_topic.asg_hooks.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.target_reg.arn
}

resource "aws_lambda_permission" "allow_sns" {
  statement_id  = "AllowSNSInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.target_reg.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.asg_hooks.arn
}
