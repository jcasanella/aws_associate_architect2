output "instance_ip" {
  description = "The public ip for ssh access"
  value       = aws_instance.this.public_ip
}

output "administrator_password" {
  value = rsadecrypt(aws_instance.this.password_data, file("${aws_key_pair.key_pair.key_name}.pem"))
}
