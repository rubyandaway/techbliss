resource "aws_vpc" "main_vpc" {
  cidr_block = var.vpc_cidr_block
#  enable_dns_hostnames = true

  tags = {
    Name = "Production-VPC"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

}

resource "aws_route_table" "rtb" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}


resource "aws_subnet" "module_public_subnet_1" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.public_subnet_1_cidr
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "Public -Subnet-1"
  }
}

resource "aws_subnet" "module_public_subnet_2" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.public_subnet_2_cidr
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "Public -Subnet-2"
  }
}


