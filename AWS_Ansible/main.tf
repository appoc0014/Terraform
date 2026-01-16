module "vpc" {
  source             = "./modules/vpc" 		# Refering to VPC module file
  project_name       = var.project_name
  vpc_cidr           = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
  az                 = var.az
}

module "ec2" {
  source           = "./modules/ec2" 		# Refering to Ec2 module file
  project_name     = var.project_name
  vpc_id           = module.vpc.vpc_id
  subnet_id        = module.vpc.public_subnet_id
  ami_id           = var.ami_id
  instance_type    = var.instance_type
  instance_count   = var.instance_count
  key_name         = var.key_name
  allowed_ssh_cidr = var.allowed_ssh_cidr
}

