###############################################################################
# aruba_enis.tf
# 6 Aruba Network Interfaces — RETAINED for future Aruba EC2 deployment.
#
# These ENIs are pre-provisioned in the correct subnets with the correct
# security groups. When Aruba EC2 instances are ready to be deployed:
#   Node 1 — use aruba1_mgmt_eni as eth0, then attach aruba1_wan_eni (eth1)
#             and aruba1_lan_eni (eth2) via aws_network_interface_attachment
#   Node 2 — use aruba2_mgmt_eni as eth0, then attach aruba2_wan_eni (eth1)
#             and aruba2_lan_eni (eth2) via aws_network_interface_attachment
#
# ENI IDs are exported as outputs for use in the Aruba deployment module.
###############################################################################

# =============================================================================
# Node 1 ENIs
# =============================================================================
resource "aws_network_interface" "aruba1_mgmt" {
  subnet_id         = aws_subnet.hub_mgmt_az1.id
  security_groups   = [aws_security_group.aruba_mgmt.id]
  source_dest_check = false
  description       = "Aruba Node1 Mgmt (eth0) - reserved for future Aruba EC2 deployment"
  tags              = { Name = "Aruba1-mgmt-ENI" }
}

resource "aws_network_interface" "aruba1_wan" {
  subnet_id         = aws_subnet.hub_wan_az1.id
  security_groups   = [aws_security_group.aruba_wan.id]
  source_dest_check = false
  description       = "Aruba Node1 WAN (eth1) - reserved for future Aruba EC2 deployment"
  tags              = { Name = "Aruba1-wan-ENI" }
}

resource "aws_network_interface" "aruba1_lan" {
  subnet_id         = aws_subnet.hub_lan_az1.id
  security_groups   = [aws_security_group.aruba_lan.id]
  source_dest_check = false
  description       = "Aruba Node1 LAN (eth2) - reserved for future Aruba EC2 deployment"
  tags              = { Name = "Aruba1-lan-ENI" }
}

# =============================================================================
# Node 2 ENIs
# =============================================================================
resource "aws_network_interface" "aruba2_mgmt" {
  subnet_id         = aws_subnet.hub_mgmt_az2.id
  security_groups   = [aws_security_group.aruba_mgmt.id]
  source_dest_check = false
  description       = "Aruba Node2 Mgmt (eth0) - reserved for future Aruba EC2 deployment"
  tags              = { Name = "Aruba2-mgmt-ENI" }
}

resource "aws_network_interface" "aruba2_wan" {
  subnet_id         = aws_subnet.hub_wan_az2.id
  security_groups   = [aws_security_group.aruba_wan.id]
  source_dest_check = false
  description       = "Aruba Node2 WAN (eth1) - reserved for future Aruba EC2 deployment"
  tags              = { Name = "Aruba2-wan-ENI" }
}

resource "aws_network_interface" "aruba2_lan" {
  subnet_id         = aws_subnet.hub_lan_az2.id
  security_groups   = [aws_security_group.aruba_lan.id]
  source_dest_check = false
  description       = "Aruba Node2 LAN (eth2) - reserved for future Aruba EC2 deployment"
  tags              = { Name = "Aruba2-lan-ENI" }
}
