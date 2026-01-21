# Configure the AWS Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Select AWS region
provider "aws" {
  region = "us-west-1"
}

# Generate a new SSH key pair
resource "tls_private_key" "lab-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Variable for key pair name
variable "key_pair_name" {
  description = "Name of the SSH key pair"
  type        = string
  default     = "lab-key"
}

# Fetch the latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  owners = ["099720109477"] # Canonical
}

# Create AWS Key Pair using the generated public key
resource "aws_key_pair" "lab-key-pair" {
  key_name   = var.key_pair_name
  public_key = tls_private_key.lab-key.public_key_openssh
}

# Save the private key to a local file
resource "local_file" "private_key" {
  content  = tls_private_key.lab-key.private_key_pem
  filename = "var.key_pair_name/lab-key.pem"
}

# Creat 3 VM's that can be accessed using the generated key pair
resource "aws_instance" "lab-vm" {
  count         = 3
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.lab-key-pair.key_name

  tags = {
    Name = "Lab-VM's"
  }
}

# Output the public IP addresses of the created instances
output "instance_public_ips" {
  description = "Public IP addresses of the created instances"
  value       = aws_instance.lab-vm[*].public_ip
}


