###############################################################################
# outputs.tf
###############################################################################

output "alb_url" {
  description = "Public ALB DNS name"
  value       = aws_lb.public.dns_name
}

output "tgw_id" {
  description = "Transit Gateway ID"
  value       = aws_ec2_transit_gateway.main.id
}

output "egress_nat_eip_az1" {
  description = "Egress NAT Gateway public IP (AZ1)"
  value       = aws_eip.egress_nat_az1.public_ip
}

output "egress_nat_eip_az2" {
  description = "Egress NAT Gateway public IP (AZ2)"
  value       = aws_eip.egress_nat_az2.public_ip
}

output "vpc_flow_logs_status" {
  description = "VPC Flow Logs enabled for all VPCs"
  value       = "Enabled for Hub, Compute, Dev, Egress VPCs → CloudWatch Logs"
}

# =============================================================================
# Aruba ENI IDs — use these when deploying Aruba EC2 instances separately
# =============================================================================
output "aruba1_mgmt_eni_id" {
  description = "Aruba Node1 Mgmt ENI ID — attach as eth0 when deploying Aruba Node1"
  value       = aws_network_interface.aruba1_mgmt.id
}

output "aruba1_wan_eni_id" {
  description = "Aruba Node1 WAN ENI ID — attach as eth1 post-launch"
  value       = aws_network_interface.aruba1_wan.id
}

output "aruba1_lan_eni_id" {
  description = "Aruba Node1 LAN ENI ID — attach as eth2 post-launch"
  value       = aws_network_interface.aruba1_lan.id
}

output "aruba2_mgmt_eni_id" {
  description = "Aruba Node2 Mgmt ENI ID — attach as eth0 when deploying Aruba Node2"
  value       = aws_network_interface.aruba2_mgmt.id
}

output "aruba2_wan_eni_id" {
  description = "Aruba Node2 WAN ENI ID — attach as eth1 post-launch"
  value       = aws_network_interface.aruba2_wan.id
}

output "aruba2_lan_eni_id" {
  description = "Aruba Node2 LAN ENI ID — attach as eth2 post-launch"
  value       = aws_network_interface.aruba2_lan.id
}

# =============================================================================
# Security Group IDs — reference in Aruba deployment module
# =============================================================================
output "aruba_mgmt_sg_id" {
  description = "Aruba Mgmt security group ID"
  value       = aws_security_group.aruba_mgmt.id
}

output "aruba_wan_sg_id" {
  description = "Aruba WAN security group ID"
  value       = aws_security_group.aruba_wan.id
}

output "aruba_lan_sg_id" {
  description = "Aruba LAN security group ID"
  value       = aws_security_group.aruba_lan.id
}
