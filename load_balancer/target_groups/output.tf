output "alb" {
  description = "Name of the Application Load Balancer"
  value       = aws_lb_target_group.alb.name
}

output "nlb" {
  description = "Name of the Network Load Balancer"
  value       = aws_lb_target_group.nlb.name
}
