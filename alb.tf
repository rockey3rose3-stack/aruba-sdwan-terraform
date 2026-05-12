###############################################################################
# alb.tf
# Public Application Load Balancer in Hub — IP target type
###############################################################################

resource "aws_lb" "public" {
  name               = "Public-ALB"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.hub_mgmt_az1.id, aws_subnet.hub_mgmt_az2.id]
  security_groups    = [aws_security_group.alb.id]

  enable_deletion_protection = false

  tags = { Name = "Public-ALB" }
}

resource "aws_lb_target_group" "main" {
  name        = "ALB-TG"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.hub.id
  target_type = "ip"

  health_check {
    path                = "/index.html"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = { Name = "ALB-TG" }
}

# HTTP listener — always created
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.public.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

# HTTPS listener — only created when ALBCertificateArn is provided
resource "aws_lb_listener" "https" {
  count             = var.alb_certificate_arn != "" ? 1 : 0
  load_balancer_arn = aws_lb.public.arn
  port              = 443
  protocol          = "HTTPS"

  certificate_arn = var.alb_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}
