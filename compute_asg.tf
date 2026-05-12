###############################################################################
# compute_asg.tf
# Compute Auto Scaling Group — Ubuntu 20.04 LTS, IMDSv2, lifecycle hooks
###############################################################################

# =============================================================================
# Launch Template
# =============================================================================
resource "aws_launch_template" "compute" {
  name_prefix   = "compute-lt-"
  image_id      = var.ubuntu_ami
  instance_type = var.compute_instance_type
  key_name      = var.key_pair_name

  monitoring { enabled = true }

  metadata_options {
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.web_compute.id]
    delete_on_termination       = true
  }

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size           = 8
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  # IMDSv2-compliant user data: fetches instance ID using token header
  user_data = base64encode(<<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y apache2 curl
    systemctl enable apache2
    systemctl start apache2
    TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
      -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
    INSTANCE_ID=$(curl -s \
      -H "X-aws-ec2-metadata-token: $TOKEN" \
      http://169.254.169.254/latest/meta-data/instance-id)
    echo "<h1>Compute ASG Node: $INSTANCE_ID</h1>" > /var/www/html/index.html
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "Compute-ASG-Node"
      Environment = "Production"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# =============================================================================
# Auto Scaling Group
# =============================================================================
resource "aws_autoscaling_group" "compute" {
  name                      = "Compute-ASG"
  min_size                  = 2
  desired_capacity          = 2
  max_size                  = 4
  vpc_zone_identifier       = [aws_subnet.compute_az1.id, aws_subnet.compute_az2.id]
  health_check_type         = "EC2"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.compute.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "Compute-ASG-Node"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "Production"
    propagate_at_launch = true
  }

  lifecycle {
    ignore_changes = [desired_capacity]
  }
}

# =============================================================================
# SNS Topic for lifecycle hooks
# =============================================================================
resource "aws_sns_topic" "asg_hooks" {
  name         = "ASG-Lifecycle-Topic"
  display_name = "ASG Lifecycle Hooks"
  tags         = { Name = "ASG-Lifecycle-Topic" }
}

# =============================================================================
# IAM Role — allows ASG to publish to SNS
# =============================================================================
resource "aws_iam_role" "asg_hook" {
  name = "sdwan-asg-hook-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "autoscaling.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = { Name = "ASG-Hook-Role" }
}

resource "aws_iam_role_policy" "asg_hook_sns" {
  name = "AllowSNSPublish"
  role = aws_iam_role.asg_hook.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "sns:Publish"
      Resource = aws_sns_topic.asg_hooks.arn
    }]
  })
}

# =============================================================================
# Lifecycle Hooks — Launch and Terminate
# =============================================================================
resource "aws_autoscaling_lifecycle_hook" "launch" {
  name                   = "asg-launch-hook"
  autoscaling_group_name = aws_autoscaling_group.compute.name
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_LAUNCHING"
  heartbeat_timeout      = 300
  default_result         = "CONTINUE"
  notification_target_arn = aws_sns_topic.asg_hooks.arn
  role_arn               = aws_iam_role.asg_hook.arn
}

resource "aws_autoscaling_lifecycle_hook" "terminate" {
  name                   = "asg-terminate-hook"
  autoscaling_group_name = aws_autoscaling_group.compute.name
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_TERMINATING"
  heartbeat_timeout      = 300
  default_result         = "CONTINUE"
  notification_target_arn = aws_sns_topic.asg_hooks.arn
  role_arn               = aws_iam_role.asg_hook.arn
}
