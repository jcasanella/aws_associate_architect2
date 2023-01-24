# Generates a secure private key and encodes it as PEM
resource "tls_private_key" "key_pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
# Create the Key Pair
resource "aws_key_pair" "key_pair" {
  key_name   = "linux-key-pair"
  public_key = tls_private_key.key_pair.public_key_openssh
}

resource "local_file" "ssh_key" {
  filename = "${aws_key_pair.key_pair.key_name}.pem"
  content  = tls_private_key.key_pair.private_key_pem
}

# Data provider to get the ami id
data "aws_ami" "this" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5*"]
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
  name = "WebAccess"

  #Incoming traffic
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #Outgoing traffic
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "this" {
  ami             = data.aws_ami.this.id
  count           = 2
  instance_type   = "t2.micro"
  subnet_id       = data.aws_subnets.this.ids[0]
  security_groups = [aws_security_group.this.id]
  key_name        = aws_key_pair.key_pair.key_name

  tags = {
    Name = "AmazonLinux Terraform"
  }
}

resource "aws_network_interface" "this" {
  subnet_id       = data.aws_subnets.this.ids[0]
  security_groups = [aws_security_group.this.id]

  attachment {
    instance     = aws_instance.this[0].id
    device_index = 1
  }
}

resource "aws_eip" "lb" {
  vpc                       = true
  network_interface         = aws_network_interface.this.id
  associate_with_private_ip = aws_network_interface.this.private_ip
  tags = {
    Name = "AmazonLinux Terraform"
  }
}
