output "instance_ip" {
  description = "The public ip for ssh access"
  value       = aws_instance.public.public_ip
}
