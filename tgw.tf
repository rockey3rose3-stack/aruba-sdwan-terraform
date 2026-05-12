###############################################################################
# tgw.tf
# Transit Gateway — Hub-and-Spoke topology with dedicated Egress VPC
###############################################################################

# =============================================================================
# Transit Gateway
# =============================================================================
resource "aws_ec2_transit_gateway" "main" {
  description                     = "SD-WAN TGW"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  tags                            = { Name = "SDWAN-TGW" }
}

# =============================================================================
# VPC Attachments
# =============================================================================
resource "aws_ec2_transit_gateway_vpc_attachment" "hub" {
  vpc_id             = aws_vpc.hub.id
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  subnet_ids         = [aws_subnet.hub_lan_az1.id, aws_subnet.hub_lan_az2.id]

  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  options {
    appliance_mode_support = "enable"
  }

  tags = { Name = "Hub-Attach" }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "compute" {
  vpc_id             = aws_vpc.compute.id
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  subnet_ids         = [aws_subnet.compute_az1.id, aws_subnet.compute_az2.id]

  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = { Name = "Compute-Attach" }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "dev" {
  vpc_id             = aws_vpc.dev.id
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  subnet_ids         = [aws_subnet.dev_az1.id, aws_subnet.dev_az2.id]

  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = { Name = "Dev-Attach" }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "egress" {
  vpc_id             = aws_vpc.egress.id
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  subnet_ids         = [aws_subnet.egress_tgw_az1.id, aws_subnet.egress_tgw_az2.id]

  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = { Name = "Egress-Attach" }
}

# =============================================================================
# TGW Route Tables
# Spoke-RT  : used by Compute and Dev — default goes to Egress, Hub via Hub-Attach
# Hub-RT    : used by Hub and Egress — routes to each spoke
# =============================================================================
resource "aws_ec2_transit_gateway_route_table" "spoke" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  tags               = { Name = "Spoke-RT" }
}

resource "aws_ec2_transit_gateway_route_table" "hub" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  tags               = { Name = "Hub-RT" }
}

# =============================================================================
# Route Table Associations
# =============================================================================
resource "aws_ec2_transit_gateway_route_table_association" "compute" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.compute.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke.id
}

resource "aws_ec2_transit_gateway_route_table_association" "dev" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.dev.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke.id
}

resource "aws_ec2_transit_gateway_route_table_association" "hub" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.hub.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.hub.id
}

resource "aws_ec2_transit_gateway_route_table_association" "egress" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.egress.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.hub.id
}

# =============================================================================
# TGW Static Routes
# =============================================================================

# Spoke RT — default internet via Egress
resource "aws_ec2_transit_gateway_route" "spoke_default_to_egress" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.egress.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke.id
}

# Spoke RT — Hub VPC via Hub attachment
resource "aws_ec2_transit_gateway_route" "spoke_to_hub" {
  destination_cidr_block         = var.vpc_cidr_hub
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.hub.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke.id
}

# Hub RT — Compute VPC
resource "aws_ec2_transit_gateway_route" "hub_to_compute" {
  destination_cidr_block         = var.vpc_cidr_compute
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.compute.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.hub.id
}

# Hub RT — Dev VPC
resource "aws_ec2_transit_gateway_route" "hub_to_dev" {
  destination_cidr_block         = var.vpc_cidr_dev
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.dev.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.hub.id
}
