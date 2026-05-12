###############################################################################
# main.tf
# Aruba SD-WAN HA Hub — Provider & Backend
# REV 5.0  |  Region: us-east-1
# Aruba EC2 instances and EIPs removed.
# Aruba ENIs and Security Groups retained for future Aruba deployment.
###############################################################################

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }

  # ── Remote state backend (update bucket/key to match your setup) ──────────
  backend "s3" {
    bucket       = "homeys3f1"
    key          = "sdwan/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "SD-WAN"
      ManagedBy   = "Terraform"
      Environment = "Production"
    }
  }
}
