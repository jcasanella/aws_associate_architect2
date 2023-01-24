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

resource "aws_organizations_policy" "this" {
  name = "DenyAccessToASpecificRole"

  content = <<CONTENT
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "DenyAccessToASpecificRole",
        "Effect": "Deny",
        "Action": [
            "iam:AttachRolePolicy",
            "iam:DeleteRole",
            "iam:DeleteRolePermissionsBoundary",
            "iam:DeleteRolePolicy",
            "iam:DetachRolePolicy",
            "iam:PutRolePermissionsBoundary",
            "iam:PutRolePolicy",
            "iam:UpdateAssumeRolePolicy",
            "iam:UpdateRole",
            "iam:UpdateRoleDescription"
        ],
        "Resource": [
            "arn:aws:iam::${aws_organizations_account.org.id}:role/DenyRoleModificationTest"
        ]
      }
    ]
}
CONTENT
}

resource "aws_organizations_policy_attachment" "account" {
  policy_id = aws_organizations_policy.this.id
  target_id = aws_organizations_organizational_unit.prod.id
}
