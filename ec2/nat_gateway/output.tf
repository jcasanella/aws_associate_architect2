output "instance_ip" {
  description = "The public ip for ssh access"
  value       = aws_instance.public.public_ip
}

output "nat_gateway_ip" {
  value = aws_eip.nat_gateway.public_ip
}
