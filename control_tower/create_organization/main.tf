resource "aws_organizations_organization" "org" {
  feature_set = "ALL"
}

resource "aws_organizations_organizational_unit" "prod" {
  name      = "production"
  parent_id = aws_organizations_organization.org.roots[0].id
}

resource "aws_organizations_account" "org" {
  name      = "DCT-Production"
  email     = "testtic10@yahoo.com"
  role_name = "OrganizationAccountAccessRole"
  parent_id = aws_organizations_organizational_unit.prod.id

  depends_on = [
    aws_organizations_organizational_unit.prod
  ]
}
