# Variable for key pair name
variable "key_pair_name" {
  description = "Name of the SSH key pair"
  type        = string
  default     = "vm:-key"
}

# Variable for AWS region
variable "provider_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-west-1"
}

# Variable for ALB security group name
variable "alb_sg_name" {
  description = "Name of the security group for the application load balancer"
  type        = string
  default     = "alb"
}

# Variable for cound (Number of instances to create)
variable "vm_count" {
  description = "Number for how many instances to create"
  type        = number
  default     = 3
}
