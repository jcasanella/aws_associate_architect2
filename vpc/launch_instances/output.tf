output "vpc" {
  value       = aws_vpc.main.arn
  description = "vpc arn"
}

output "public_subnets" {
  value       = aws_subnet.public.*.arn
  description = "public subnet arns"
}

output "private_subnets" {
  value       = aws_subnet.private.*.arn
  description = "private subnet arns"
}

output "route_private" {
  value       = aws_route_table.private.arn
  description = "route private arn"
}

output "igw" {
  value       = aws_internet_gateway.igw.arn
  description = "igw arn"
}

output "route_public" {
  value       = aws_route_table.public.arn
  description = "route public arn"
}

output "ec2_public" {
  value       = aws_instance.public.*.arn
  description = "ec2 instances in public"
}

output "ec2_private" {
  value       = aws_instance.private.*.arn
  description = "ec2 instances in private"
}
