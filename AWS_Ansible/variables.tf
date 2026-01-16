variable "aws_region" {
  type = string
  default = "us-west-1"
}

variable "project_name" {
  type = string
  default = "aws-module"
}

variable "vpc_cidr" {
  type = string
  default = "10.10.0.0/16"
}

variable "public_subnet_cidr" {
  type    = string
  default = "10.10.1.0/24"
}

variable "az" {
  type    = string
  default = "us-west-2a"
}

variable "instance_count" {
  type    = number
  default = 2
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

# Use a valid AMI for your region (example: Amazon Linux 2023 / AL2).
variable "ami_id" {
  type = string
}

# Optional: if you want SSH access, create/import a key pair in AWS and set this.
variable "Terraform_SSH" {
  type    = string
  default = null
}

variable "allowed_ssh_cidr" {
  type        = string
  description = "CIDR allowed to SSH (port 22). Use your public IP /32."
  default     = "0.0.0.0/0"
}
