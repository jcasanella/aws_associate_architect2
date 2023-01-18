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


output "route" {
  value       = aws_route_table.private_route.arn
  description = "route arn"
}
