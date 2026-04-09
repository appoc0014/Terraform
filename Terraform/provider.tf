# Configure the AWS Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.36.0"
    }
  }
}

# Select AWS region
provider "aws" {
  region = var.provider_region
}
