output "autoscaling_group" {
  description = "Id of the autoscaling group"
  value       = aws_autoscaling_group.this.id
}

output "launch_template" {
  description = "Id of the launch template"
  value       = aws_launch_configuration.this.id
}
