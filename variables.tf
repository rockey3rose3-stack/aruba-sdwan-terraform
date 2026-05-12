###############################################################################
# variables.tf
###############################################################################

variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region for all resources"
}

variable "key_pair_name" {
  type        = string
  default     = "AWS-sid-EC-KP"
  description = "EC2 KeyPair name for SSH access"
}

variable "restricted_ip" {
  type        = string
  default     = "184.147.66.76/32"
  description = "Admin IP/CIDR allowed to access Aruba Mgmt security group"

  validation {
    condition     = can(cidrhost(var.restricted_ip, 0))
    error_message = "restricted_ip must be a valid IPv4 CIDR, e.g. 203.0.113.10/32"
  }
}

variable "admin_email" {
  type        = string
  default     = "rockey3rose3@gmail.com"
  description = "Email for CloudWatch alarm notifications. Leave empty to disable SNS."
}

variable "compute_instance_type" {
  type        = string
  default     = "t3.micro"
  description = "Instance type for Compute ASG nodes"

  validation {
    condition     = contains(["t3.micro", "t3.small", "t3.medium"], var.compute_instance_type)
    error_message = "compute_instance_type must be t3.micro, t3.small, or t3.medium"
  }
}

variable "alb_certificate_arn" {
  type        = string
  default     = ""
  description = "ACM Certificate ARN for HTTPS listener (us-east-1). Leave empty for HTTP only."
}

# Ubuntu 20.04 LTS  us-east-1
variable "ubuntu_ami" {
  type        = string
  default     = "ami-0a59ec92177ec3fad"
  description = "Ubuntu 20.04 LTS AMI ID for us-east-1 (used by DevSrv and Compute ASG)"
}

# ── Networking CIDRs ──────────────────────────────────────────────────────────
variable "vpc_cidr_hub" {
  type    = string
  default = "10.160.0.0/16"
}

variable "vpc_cidr_compute" {
  type    = string
  default = "10.161.0.0/16"
}

variable "vpc_cidr_dev" {
  type    = string
  default = "10.162.0.0/16"
}

variable "vpc_cidr_egress" {
  type    = string
  default = "10.163.0.0/16"
}
