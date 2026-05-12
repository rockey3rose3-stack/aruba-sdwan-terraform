# Aruba SD-WAN Terraform Project

This repository contains Terraform configurations for deploying Aruba SD-WAN infrastructure on AWS, including VPC, EC2 instances, load balancers, security groups, and related resources.

## Architecture Overview

The infrastructure includes:
- VPC with subnets
- EC2 Auto Scaling Groups
- Application Load Balancers
- Transit Gateway for SD-WAN connectivity
- CloudWatch monitoring
- Lambda functions
- Flow logs

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0.0
- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate credentials
- AWS account with necessary permissions

## Quick Start

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd aruba-sdwan-terraform
   ```

2. **Configure variables:**
   Copy `terraform.tfvars.example` to `terraform.tfvars` and update with your values:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your AWS settings
   ```

3. **Initialize Terraform:**
   ```bash
   terraform init
   ```

4. **Plan the deployment:**
   ```bash
   terraform plan
   ```

5. **Apply the configuration:**
   ```bash
   terraform apply
   ```

## Project Structure

```
.
├── main.tf                 # Main Terraform configuration
├── variables.tf            # Input variables
├── outputs.tf              # Output values
├── terraform.tfvars        # Variable values (not committed)
├── alb.tf                  # Application Load Balancer configuration
├── aruba_enis.tf           # Aruba ENIs configuration
├── cloudwatch.tf           # CloudWatch monitoring
├── compute_asg.tf          # EC2 Auto Scaling Groups
├── dev_servers.tf          # Development servers
├── flow_logs.tf            # VPC Flow Logs
├── lambda.tf               # Lambda functions
├── security_groups.tf      # Security groups
├── tgw.tf                  # Transit Gateway
├── vpc.tf                  # VPC and networking
├── .gitignore              # Git ignore rules
└── README.md               # This file
```

## Variables

Key variables include:
- `aws_region`: AWS region for deployment
- `vpc_cidr`: VPC CIDR block
- `environment`: Environment name (dev/staging/prod)
- `project_name`: Project identifier

See `variables.tf` for complete list and descriptions.

## Outputs

The deployment provides outputs for:
- VPC ID
- Subnet IDs
- Load balancer DNS name
- Instance IPs
- Transit Gateway ID

## Security Considerations

- Never commit `terraform.tfvars` to version control
- Use AWS IAM roles with least privilege
- Enable encryption for sensitive data
- Regularly rotate access keys

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run `terraform fmt` and `terraform validate`
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues and questions, please open a GitHub issue.