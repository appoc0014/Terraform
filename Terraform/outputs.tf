# Output the public IP addresses of new VM's
output "public_ip" {
  value = aws_instance.lab-vm[*].public_ip
}

output "info_aws" {
  value = format("%s", "ssh -i ~/.ssh/vm-key.pem ubuntu@${aws_instance.lab-vm[0].public_ip}")
}


# Output DNS name of Load Balancer
output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.main.dns_name
}
