# Create a new host with instance type of m2.micro with Auto Placement
# and Host Recovery enabled.
resource "aws_ec2_host" "lab-vm" {
  ami		= var.ami
  instance_type = var.instance_type
  vpc_security_group_ids = [var.sg]
  
}
