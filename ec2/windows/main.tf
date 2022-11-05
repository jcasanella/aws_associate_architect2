# Generates a secure private key and encodes it as PEM
# resource "tls_private_key" "key_pair" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }
# Create the Key Pair
# resource "aws_key_pair" "key_pair" {
#   key_name   = "linux-key-pair"
#   public_key = tls_private_key.key_pair.public_key_openssh
# }

# resource "local_file" "ssh_key" {
#   filename = "${aws_key_pair.key_pair.key_name}.pem"
#   content  = tls_private_key.key_pair.private_key_pem
# }

# Data provider to get the ami id
data "aws_ami" "this" {
  most_recent = true

  filter {
    name   = "name"
    values = ["Windows_Server-2022-English*"]
  }

  owners = ["amazon"]
}

# Data provider to get the subnets
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "this" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Create security group and ec2 instance
resource "aws_security_group" "this" {
  name        = "WebAccess"
  description = "Security Group for WebAccess"
}

resource "aws_security_group_rule" "ssh" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.this.id
}

resource "aws_security_group_rule" "rdp" {
  type        = "ingress"
  from_port   = 3389
  to_port     = 3389
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.this.id
}

resource "aws_security_group_rule" "egress" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.this.id
}



resource "aws_instance" "this" {
  ami             = "ami-0307655fcb954b39f"
  instance_type   = "t2.micro"
  subnet_id       = tolist(data.aws_subnets.this.ids)[0]
  security_groups = [aws_security_group.this.id]

  tags = {
    Name = "Windows Terraform"
  }
}
