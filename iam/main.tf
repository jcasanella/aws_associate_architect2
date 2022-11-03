terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "eu-west-1"
}

resource "aws_iam_group" "developers" {
  name = "developers"
}

resource "aws_iam_user" "developers" {
  count = length(var.developer_names)
  name  = var.developer_names[count.index]

  tags = {
    "name" = "test-developers"
  }
}

resource "aws_iam_group_membership" "developers" {
  name  = "developers-group-membership"
  users = var.developer_names
  group = aws_iam_group.developers.name
}

resource "aws_iam_policy" "s3_list" {
  name        = "s3_list"
  description = "S3 list buckets"
  policy      = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:ListAllMyBuckets"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOT
}

resource "aws_iam_group_policy_attachment" "s3_list_attach" {
  group      = aws_iam_group.developers.name
  policy_arn = aws_iam_policy.s3_list.arn
}
