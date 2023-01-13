output "org" {
  description = "The organization"
  value       = aws_organizations_organization.org.roots[0].id
}

output "production_organizational" {
  description = "Id Production org"
  value       = aws_organizations_organizational_unit.prod.id
}

output "account" {
  description = "Create account"
  value       = aws_organizations_account.org.id
}

