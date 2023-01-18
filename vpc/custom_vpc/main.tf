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

resource "aws_route_table" "private_route" {
  vpc_id = aws_vpc.main.id

  route = []

  tags = {
    Name = "Private-RT"
  }
}
