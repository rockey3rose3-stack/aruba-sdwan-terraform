###############################################################################
# terraform.tfvars
# Override defaults here. Do NOT commit this file if it contains secrets.
###############################################################################

aws_region            = "us-east-1"
key_pair_name         = "AWS-sid-EC-KP"
restricted_ip         = "184.147.66.76/32"
admin_email           = "rockey3rose3@gmail.com"
compute_instance_type = "t3.micro"
ubuntu_ami            = "ami-0a59ec92177ec3fad"  # Ubuntu 20.04 LTS us-east-1

# Leave empty to skip HTTPS listener
alb_certificate_arn = ""

# VPC CIDRs — change only if you need different ranges
vpc_cidr_hub     = "10.160.0.0/16"
vpc_cidr_compute = "10.161.0.0/16"
vpc_cidr_dev     = "10.162.0.0/16"
vpc_cidr_egress  = "10.163.0.0/16"
