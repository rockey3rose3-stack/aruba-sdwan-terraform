###############################################################################
# security_groups.tf
# All Security Groups
# NOTE: Aruba SGs (ArubaMgmtSG, ArubaWanSG, ArubaLanSG) are RETAINED
#       for future Aruba EC2 deployment. They are currently attached to
#       the 6 pre-provisioned Aruba ENIs in aruba_enis.tf.
###############################################################################

# =============================================================================
# Aruba Mgmt0 — SSH / HTTP / HTTPS from admin IP only
# Reserved for future Aruba EC2 instances
# =============================================================================
resource "aws_security_group" "aruba_mgmt" {
  name        = "Aruba-mgmt-SG"
  description = "Aruba mgmt - restricted admin access (reserved for future Aruba EC2)"
  vpc_id      = aws_vpc.hub.id

  ingress {
    description = "SSH from admin"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.restricted_ip]
  }

  ingress {
    description = "HTTP from admin"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.restricted_ip]
  }

  ingress {
    description = "HTTPS from admin"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.restricted_ip]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "Aruba-mgmt-SG" }
}

# =============================================================================
# Aruba WAN0 — IPsec IKEv2 + NAT-T
# Reserved for future Aruba EC2 instances
# =============================================================================
resource "aws_security_group" "aruba_wan" {
  name        = "Aruba-wan-SG"
  description = "Aruba wan - IPsec underlay UDP 500/4500 (reserved for future Aruba EC2)"
  vpc_id      = aws_vpc.hub.id

  ingress {
    description = "IKEv2"
    from_port   = 500
    to_port     = 500
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "IPsec NAT-T"
    from_port   = 4500
    to_port     = 4500
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "Aruba-wan-SG" }
}

# =============================================================================
# Aruba LAN0 — internal east-west traffic
# Reserved for future Aruba EC2 instances
# =============================================================================
resource "aws_security_group" "aruba_lan" {
  name        = "Aruba-lan-SG"
  description = "Aruba lan - internal east-west (reserved for future Aruba EC2)"
  vpc_id      = aws_vpc.hub.id

  ingress {
    description = "Hub VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr_hub]
  }

  ingress {
    description = "Compute VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr_compute]
  }

  ingress {
    description = "Dev VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr_dev]
  }

  ingress {
    description = "Egress VPC - return traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr_egress]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "Aruba-lan-SG" }
}

# =============================================================================
# Public ALB — HTTP/HTTPS from internet
# =============================================================================
resource "aws_security_group" "alb" {
  name        = "ALB-SG"
  description = "Public ALB in Hub"
  vpc_id      = aws_vpc.hub.id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "ALB-SG" }
}

# =============================================================================
# Compute web tier — allow HTTP/HTTPS from Hub ALB subnets
# =============================================================================
resource "aws_security_group" "web_compute" {
  name        = "Web-Compute-SG"
  description = "Web tier in Compute (allow from Hub ALB subnets)"
  vpc_id      = aws_vpc.compute.id

  ingress {
    description = "HTTP from ALB AZ1"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.160.10.16/28"]
  }

  ingress {
    description = "HTTP from ALB AZ2"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.160.10.64/28"]
  }

  ingress {
    description = "HTTPS from ALB AZ1"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.160.10.16/28"]
  }

  ingress {
    description = "HTTPS from ALB AZ2"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.160.10.64/28"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "Web-Compute-SG" }
}

# =============================================================================
# Dev web tier — allow HTTP/HTTPS from Hub ALB subnets
# =============================================================================
resource "aws_security_group" "web_dev" {
  name        = "Web-Dev-SG"
  description = "Web tier in Dev (allow from Hub ALB subnets)"
  vpc_id      = aws_vpc.dev.id

  ingress {
    description = "HTTP from ALB AZ1"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.160.10.16/28"]
  }

  ingress {
    description = "HTTP from ALB AZ2"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.160.10.64/28"]
  }

  ingress {
    description = "HTTPS from ALB AZ1"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.160.10.16/28"]
  }

  ingress {
    description = "HTTPS from ALB AZ2"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.160.10.64/28"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "Web-Dev-SG" }
}
