###############################################################################
# vpc.tf
# VPCs, Subnets, Internet Gateways, and Route Tables
###############################################################################

# =============================================================================
# VPCs
# =============================================================================
resource "aws_vpc" "hub" {
  cidr_block           = var.vpc_cidr_hub
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "SDWAN-Hub-VPC" }
}

resource "aws_vpc" "compute" {
  cidr_block           = var.vpc_cidr_compute
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "VPC-Compute" }
}

resource "aws_vpc" "dev" {
  cidr_block           = var.vpc_cidr_dev
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "VPC-Dev"
    Environment = "Development"
  }
}

resource "aws_vpc" "egress" {
  cidr_block           = var.vpc_cidr_egress
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "VPC-Egress" }
}

# =============================================================================
# Hub Subnets — Mgmt (public), WAN (public), LAN (private)
# =============================================================================
resource "aws_subnet" "hub_mgmt_az1" {
  vpc_id                  = aws_vpc.hub.id
  cidr_block              = "10.160.10.16/28"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true
  tags                    = { Name = "EC1-mgmt-Subnet-AZ1" }
}

resource "aws_subnet" "hub_mgmt_az2" {
  vpc_id                  = aws_vpc.hub.id
  cidr_block              = "10.160.10.64/28"
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true
  tags                    = { Name = "EC2-mgmt-Subnet-AZ2" }
}

resource "aws_subnet" "hub_wan_az1" {
  vpc_id                  = aws_vpc.hub.id
  cidr_block              = "10.160.10.32/28"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true
  tags                    = { Name = "EC1-wan-Subnet-AZ1" }
}

resource "aws_subnet" "hub_wan_az2" {
  vpc_id                  = aws_vpc.hub.id
  cidr_block              = "10.160.10.80/28"
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true
  tags                    = { Name = "EC2-wan-Subnet-AZ2" }
}

resource "aws_subnet" "hub_lan_az1" {
  vpc_id                  = aws_vpc.hub.id
  cidr_block              = "10.160.10.48/28"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true
  tags                    = { Name = "EC1-lan-Subnet-AZ1" }
}

resource "aws_subnet" "hub_lan_az2" {
  vpc_id                  = aws_vpc.hub.id
  cidr_block              = "10.160.10.96/28"
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true
  tags                    = { Name = "EC2-lan-Subnet-AZ2" }
}

# =============================================================================
# Compute Subnets — private
# =============================================================================
resource "aws_subnet" "compute_az1" {
  vpc_id                  = aws_vpc.compute.id
  cidr_block              = "10.161.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = false
  tags                    = { Name = "Compute_Sub-AZ1" }
}

resource "aws_subnet" "compute_az2" {
  vpc_id                  = aws_vpc.compute.id
  cidr_block              = "10.161.2.0/24"
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = false
  tags                    = { Name = "Compute_Sub-AZ2" }
}

# =============================================================================
# Dev Subnets — private
# =============================================================================
resource "aws_subnet" "dev_az1" {
  vpc_id                  = aws_vpc.dev.id
  cidr_block              = "10.162.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = false
  tags                    = { Name = "Dev_Sub-AZ1" }
}

resource "aws_subnet" "dev_az2" {
  vpc_id                  = aws_vpc.dev.id
  cidr_block              = "10.162.2.0/24"
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = false
  tags                    = { Name = "Dev_Sub-AZ2" }
}

# =============================================================================
# Egress Subnets — public (NAT) + TGW attachment
# =============================================================================
resource "aws_subnet" "egress_public_az1" {
  vpc_id                  = aws_vpc.egress.id
  cidr_block              = "10.163.10.0/25"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true
  tags                    = { Name = "Egress-Public-AZ1" }
}

resource "aws_subnet" "egress_tgw_az1" {
  vpc_id                  = aws_vpc.egress.id
  cidr_block              = "10.163.10.128/25"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = false
  tags                    = { Name = "Egress-TGW-AZ1" }
}

resource "aws_subnet" "egress_public_az2" {
  vpc_id                  = aws_vpc.egress.id
  cidr_block              = "10.163.11.0/25"
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true
  tags                    = { Name = "Egress-Public-AZ2" }
}

resource "aws_subnet" "egress_tgw_az2" {
  vpc_id                  = aws_vpc.egress.id
  cidr_block              = "10.163.11.128/25"
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = false
  tags                    = { Name = "Egress-TGW-AZ2" }
}

# =============================================================================
# Internet Gateways
# =============================================================================
resource "aws_internet_gateway" "hub" {
  vpc_id = aws_vpc.hub.id
  tags   = { Name = "Hub-IGW" }
}

resource "aws_internet_gateway" "egress" {
  vpc_id = aws_vpc.egress.id
  tags   = { Name = "Egress-IGW" }
}

# =============================================================================
# Hub Public Route Table
# =============================================================================
resource "aws_route_table" "hub_public" {
  vpc_id = aws_vpc.hub.id
  tags   = { Name = "Hub-Public-RT" }
}

resource "aws_route" "hub_default" {
  route_table_id         = aws_route_table.hub_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.hub.id
}

resource "aws_route" "hub_to_compute" {
  route_table_id         = aws_route_table.hub_public.id
  destination_cidr_block = var.vpc_cidr_compute
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
  depends_on             = [aws_ec2_transit_gateway_vpc_attachment.hub]
}

resource "aws_route" "hub_to_dev" {
  route_table_id         = aws_route_table.hub_public.id
  destination_cidr_block = var.vpc_cidr_dev
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
  depends_on             = [aws_ec2_transit_gateway_vpc_attachment.dev]
}

# Associate all Hub subnets to the public RT
resource "aws_route_table_association" "hub_mgmt_az1" {
  subnet_id      = aws_subnet.hub_mgmt_az1.id
  route_table_id = aws_route_table.hub_public.id
}

resource "aws_route_table_association" "hub_mgmt_az2" {
  subnet_id      = aws_subnet.hub_mgmt_az2.id
  route_table_id = aws_route_table.hub_public.id
}

resource "aws_route_table_association" "hub_wan_az1" {
  subnet_id      = aws_subnet.hub_wan_az1.id
  route_table_id = aws_route_table.hub_public.id
}

resource "aws_route_table_association" "hub_wan_az2" {
  subnet_id      = aws_subnet.hub_wan_az2.id
  route_table_id = aws_route_table.hub_public.id
}

resource "aws_route_table_association" "hub_lan_az1" {
  subnet_id      = aws_subnet.hub_lan_az1.id
  route_table_id = aws_route_table.hub_public.id
}

resource "aws_route_table_association" "hub_lan_az2" {
  subnet_id      = aws_subnet.hub_lan_az2.id
  route_table_id = aws_route_table.hub_public.id
}

# =============================================================================
# Compute Route Table — default via TGW
# =============================================================================
resource "aws_route_table" "compute" {
  vpc_id = aws_vpc.compute.id
  tags   = { Name = "Compute-RT" }
}

resource "aws_route" "compute_default" {
  route_table_id         = aws_route_table.compute.id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
  depends_on             = [aws_ec2_transit_gateway_vpc_attachment.compute]
}

resource "aws_route_table_association" "compute_az1" {
  subnet_id      = aws_subnet.compute_az1.id
  route_table_id = aws_route_table.compute.id
}

resource "aws_route_table_association" "compute_az2" {
  subnet_id      = aws_subnet.compute_az2.id
  route_table_id = aws_route_table.compute.id
}

# =============================================================================
# Dev Route Table — default via TGW
# =============================================================================
resource "aws_route_table" "dev" {
  vpc_id = aws_vpc.dev.id
  tags   = { Name = "Dev-RT" }
}

resource "aws_route" "dev_default" {
  route_table_id         = aws_route_table.dev.id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
  depends_on             = [aws_ec2_transit_gateway_vpc_attachment.dev]
}

resource "aws_route_table_association" "dev_az1" {
  subnet_id      = aws_subnet.dev_az1.id
  route_table_id = aws_route_table.dev.id
}

resource "aws_route_table_association" "dev_az2" {
  subnet_id      = aws_subnet.dev_az2.id
  route_table_id = aws_route_table.dev.id
}

# =============================================================================
# Egress NAT Gateways + EIPs
# =============================================================================
resource "aws_eip" "egress_nat_az1" {
  domain = "vpc"
  tags   = { Name = "Egress-NAT-EIP-AZ1" }
}

resource "aws_eip" "egress_nat_az2" {
  domain = "vpc"
  tags   = { Name = "Egress-NAT-EIP-AZ2" }
}

resource "aws_nat_gateway" "egress_az1" {
  subnet_id     = aws_subnet.egress_public_az1.id
  allocation_id = aws_eip.egress_nat_az1.id
  tags          = { Name = "Egress-NAT-AZ1" }
}

resource "aws_nat_gateway" "egress_az2" {
  subnet_id     = aws_subnet.egress_public_az2.id
  allocation_id = aws_eip.egress_nat_az2.id
  tags          = { Name = "Egress-NAT-AZ2" }
}

# =============================================================================
# Egress Public Route Table
# =============================================================================
resource "aws_route_table" "egress_public" {
  vpc_id = aws_vpc.egress.id
  tags   = { Name = "Egress-Public-RT" }
}

resource "aws_route" "egress_public_default" {
  route_table_id         = aws_route_table.egress_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.egress.id
}

resource "aws_route" "egress_public_to_hub" {
  route_table_id         = aws_route_table.egress_public.id
  destination_cidr_block = var.vpc_cidr_hub
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
  depends_on             = [aws_ec2_transit_gateway_vpc_attachment.egress]
}

resource "aws_route" "egress_public_to_compute" {
  route_table_id         = aws_route_table.egress_public.id
  destination_cidr_block = var.vpc_cidr_compute
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
  depends_on             = [aws_ec2_transit_gateway_vpc_attachment.egress]
}

resource "aws_route" "egress_public_to_dev" {
  route_table_id         = aws_route_table.egress_public.id
  destination_cidr_block = var.vpc_cidr_dev
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
  depends_on             = [aws_ec2_transit_gateway_vpc_attachment.egress]
}

resource "aws_route_table_association" "egress_public_az1" {
  subnet_id      = aws_subnet.egress_public_az1.id
  route_table_id = aws_route_table.egress_public.id
}

resource "aws_route_table_association" "egress_public_az2" {
  subnet_id      = aws_subnet.egress_public_az2.id
  route_table_id = aws_route_table.egress_public.id
}

# =============================================================================
# Egress TGW Route Tables (private, route default to NAT, spoke CIDRs to TGW)
# =============================================================================
resource "aws_route_table" "egress_tgw_az1" {
  vpc_id = aws_vpc.egress.id
  tags   = { Name = "Egress-TGW-RT-AZ1" }
}

resource "aws_route" "egress_tgw_default_az1" {
  route_table_id         = aws_route_table.egress_tgw_az1.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.egress_az1.id
}

resource "aws_route" "egress_tgw_to_hub_az1" {
  route_table_id         = aws_route_table.egress_tgw_az1.id
  destination_cidr_block = var.vpc_cidr_hub
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
  depends_on             = [aws_ec2_transit_gateway_vpc_attachment.egress]
}

resource "aws_route" "egress_tgw_to_compute_az1" {
  route_table_id         = aws_route_table.egress_tgw_az1.id
  destination_cidr_block = var.vpc_cidr_compute
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
  depends_on             = [aws_ec2_transit_gateway_vpc_attachment.egress]
}

resource "aws_route" "egress_tgw_to_dev_az1" {
  route_table_id         = aws_route_table.egress_tgw_az1.id
  destination_cidr_block = var.vpc_cidr_dev
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
  depends_on             = [aws_ec2_transit_gateway_vpc_attachment.egress]
}

resource "aws_route_table" "egress_tgw_az2" {
  vpc_id = aws_vpc.egress.id
  tags   = { Name = "Egress-TGW-RT-AZ2" }
}

resource "aws_route" "egress_tgw_default_az2" {
  route_table_id         = aws_route_table.egress_tgw_az2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.egress_az2.id
}

resource "aws_route" "egress_tgw_to_hub_az2" {
  route_table_id         = aws_route_table.egress_tgw_az2.id
  destination_cidr_block = var.vpc_cidr_hub
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
  depends_on             = [aws_ec2_transit_gateway_vpc_attachment.egress]
}

resource "aws_route" "egress_tgw_to_compute_az2" {
  route_table_id         = aws_route_table.egress_tgw_az2.id
  destination_cidr_block = var.vpc_cidr_compute
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
  depends_on             = [aws_ec2_transit_gateway_vpc_attachment.egress]
}

resource "aws_route" "egress_tgw_to_dev_az2" {
  route_table_id         = aws_route_table.egress_tgw_az2.id
  destination_cidr_block = var.vpc_cidr_dev
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
  depends_on             = [aws_ec2_transit_gateway_vpc_attachment.egress]
}

resource "aws_route_table_association" "egress_tgw_az1" {
  subnet_id      = aws_subnet.egress_tgw_az1.id
  route_table_id = aws_route_table.egress_tgw_az1.id
}

resource "aws_route_table_association" "egress_tgw_az2" {
  subnet_id      = aws_subnet.egress_tgw_az2.id
  route_table_id = aws_route_table.egress_tgw_az2.id
}
