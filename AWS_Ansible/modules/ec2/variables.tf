variable "project_name" { type = string }
variable "vpc_id" { type = string }
variable "subnet_id" { type = string }

variable "ami_id" { type = string }
variable "instance_type" { type = string }
variable "instance_count" { type = number }

variable "key_name" {
  type    = string
  default = null
}

variable "allowed_ssh_cidr" {
  type    = string
  default = "0.0.0.0/0"
}

