output "all_arns_developers" {
  value       = aws_iam_user.developers[*].arn
  description = "The ARNs for all developers users"
}
