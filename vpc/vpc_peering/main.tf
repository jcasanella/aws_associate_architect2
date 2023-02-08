data "aws_region" "current" {}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "MyVPC"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "public" {
  count = length(var.cidr_public)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.cidr_public[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "Public ${count.index}"
  }
}

resource "aws_subnet" "private" {
  count = length(var.cidr_private)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.cidr_private[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "Private ${count.index}"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route = []

  tags = {
    Name = "Private-RT"
  }
}

resource "aws_route_table_association" "private" {
  count = length(var.cidr_private)

  subnet_id      = aws_subnet.private.*.id[count.index]
  route_table_id = aws_route_table.private.id
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "MyIG"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public-RT"
  }
}

resource "aws_route_table_association" "public" {
  count = length(var.cidr_public)

  subnet_id      = aws_subnet.public.*.id[count.index]
  route_table_id = aws_route_table.public.id
}

data "aws_vpc" "selected" {
  default = true
}

# data "aws_subnets" "selected" {
#   filter {
#     name   = "vpc-id"
#     values = [data.aws_vpc.selected.id]
#   }
# }

# data "aws_subnet" "example" {
#   for_each = toset(data.aws_subnets.example.ids)
#   id       = each.value
# }

resource "aws_vpc_peering_connection" "foo" {
  peer_owner_id = data.aws_vpc.selected.owner_id
  peer_vpc_id   = aws_vpc.main.id
  vpc_id        = data.aws_vpc.selected.id
  auto_accept   = true
}

resource "aws_security_group" "default_vpc" {
  name        = "Default VPC"
  description = "Default VPC"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    from_port        = -1
    to_port          = -1
    protocol         = "icmp"
    cidr_blocks      = [aws_vpc.main.cidr_block]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
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
    Name = "default_vpc"
  }
}

# data "aws_route_table" "selected" {
#   subnet_id = "subnet-00e426ef3ee60783e"
# }

resource "aws_route" "primary2secondary" {
  # ID of VPC 1 main route table.
  route_table_id = var.route_table_id

  # CIDR block / IP range for VPC 2.
  destination_cidr_block = aws_vpc.main.cidr_block

  # ID of VPC peering connection.
  vpc_peering_connection_id = aws_vpc_peering_connection.foo.id
}

resource "aws_route" "secondary2primary" {
  # ID of VPC 1 main route table.
  route_table_id = aws_route_table.public.id

  # CIDR block / IP range for VPC 2.
  destination_cidr_block = data.aws_vpc.selected.cidr_block

  # ID of VPC peering connection.
  vpc_peering_connection_id = aws_vpc_peering_connection.foo.id
}

resource "aws_security_group" "my_vpc" {
  name        = "My VPC"
  description = "My VPC"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port        = -1
    to_port          = -1
    protocol         = "icmp"
    cidr_blocks      = [data.aws_vpc.selected.cidr_block]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
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
    Name = "my_vpc"
  }
}

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


locals {
  subnet_security = {
    "default_vpc" = { subnet_id = var.subnet_id, security_group = aws_security_group.default_vpc.id },
    "my_vpc"      = { subnet_id = aws_subnet.public.*.id[0], security_group = aws_security_group.my_vpc.id }
  }
}

resource "aws_instance" "default" {
  ami           = data.aws_ami.this.id
  instance_type = "t2.micro"

  for_each = local.subnet_security

  subnet_id       = each.value.subnet_id
  security_groups = [each.value.security_group]
  key_name        = aws_key_pair.key_pair.key_name

  tags = {
    Name = "Linux ${each.key} public"
  }
}
