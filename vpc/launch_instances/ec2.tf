resource "aws_security_group" "public_web" {
  name        = "Public_Web"
  description = "Public Web Access"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "Public_Web"
  }
}

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

resource "aws_instance" "public" {
  count           = 2
  ami             = data.aws_ami.this.id
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.public.*.id[count.index]
  security_groups = [aws_security_group.public_web.id]
  key_name        = aws_key_pair.key_pair.key_name
  user_data       = file("scripts/user_metadata.sh")

  tags = {
    Name = "Linux ${count.index} public"
  }

  depends_on = [
    aws_subnet.public
  ]
}

resource "aws_instance" "private" {
  count           = 2
  ami             = data.aws_ami.this.id
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.private.*.id[count.index]
  security_groups = [aws_security_group.public_web.id]
  key_name        = aws_key_pair.key_pair.key_name
  user_data       = file("./scripts/user_metadata.sh")

  tags = {
    Name = "Linux ${count.index} private"
  }

  depends_on = [
    aws_subnet.private
  ]
}
