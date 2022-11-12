
resource "aws_iam_role" "this" {
  name = "ec2_role_s3"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Effect" : "Allow",
        "Sid" : ""
      }
    ]
  })
  tags = {
    Name = "AmazonLinux Terraform"
  }
}

resource "aws_iam_instance_profile" "this" {
  name = "ip_ec2_role_s3"
  role = aws_iam_role.this.name
}

resource "aws_iam_role_policy" "s3_read" {
  name = "test_policy"
  role = aws_iam_role.this.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:Get*",
          "s3:List*",
          "s3-object-lambda:Get*",
          "s3-object-lambda:List*"
        ],
        "Resource" : "*"
      }
    ]
  })
}
