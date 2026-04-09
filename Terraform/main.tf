

# Fetch the latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  owners = ["099720109477"] # Canonical
}

# Creat 3 VM's that can be accessed using the generated key pair
resource "aws_instance" "lab-vm" {
  count                  = var.vm_count
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.ssh_public.key_name
  subnet_id              = module.vpc.public_subnets[count.index % length(module.vpc.public_subnets)] # Distribute instances across public subnets
  vpc_security_group_ids = [aws_security_group.ssh_access.id]

  associate_public_ip_address = true

  tags = {
    Name         = "lab-ubuntu-${count.index + 1}"
    Role         = "web"
    Env          = "lab"
    ManagedBy    = "Terraform"
    Terraform    = "true"
    AnsibleGroup = "webservers"
  }
}

# Output the public IP addresses of the created instances
output "instance_public_ips" {
  description = "Public IP addresses of the created instances"
  value       = aws_instance.lab-vm[*].public_ip
}

# Create a security group to allow SSH/HTTP access
resource "aws_security_group" "ssh_access" {
  name        = "ssh_access"
  description = "Allow SSH access to new Ubuntu instances"
  vpc_id      = module.vpc.vpc_id


  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_https_access.id]
    description     = "Allow HTTP only from ALB"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create a security group for Load Balancer to allow HTTP/S access
resource "aws_security_group" "lb_https_access" {
  name        = "lb_https_access"
  description = "Allow HTTPS access to Load Balancer"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP from anywhere"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.alb_sg_name}-alb-sg"
  }
}

# Create ALB for load balancing traffic to the instances
resource "aws_lb" "main" {
  name               = "a${var.alb_sg_name}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_https_access.id]
  subnets            = module.vpc.public_subnets

  # Access to logs in S3 bucket (optional, can be configured later)
  # access_logs {
  #   bucket  = aws_s3_bucket.lb_logs.bucket
  #   prefix  = "alb-logs"
  #   enabled = true
  # }


  tags = {
    Name = "app-lb"
    Env  = "lab"
  }
}

# Target group for the ALB to route traffic to the instances
resource "aws_lb_target_group" "app_targets" {
  name        = "app-targets"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "instance"

  health_check {
    enabled             = true
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }
}

# Register instances with the target group
resource "aws_lb_target_group_attachment" "app_targets_attachment" {
  count            = 3
  target_group_arn = aws_lb_target_group.app_targets.arn
  target_id        = aws_instance.lab-vm[count.index].id
  port             = 80
}

# Create a listener for the ALB to forward HTTP traffic to the target group
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_targets.arn
  }
}


# Upload key from host Ubuntu system
resource "aws_key_pair" "ssh_public" {
  key_name   = "vm-key"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDS/y5L1Iwxm19SouBBOVVJzla76JrgUmwxPVgX2dAwX appoc@Appoc14"
}

# use a module to keep the VPC configuration clean and reusable
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "lab_vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-west-1a", "us-west-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.10.0/24", "10.0.20.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true # keep costs down by using a single NAT gateway

  map_public_ip_on_launch = true

  tags = {
  }
}

