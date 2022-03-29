terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = var.region
}

resource "aws_vpc" "webserver_vpc" {
  cidr_block = var.vpc_cidr
}

resource "aws_subnet" "webserver_subnet" {
  vpc_id     = aws_vpc.webserver_vpc.id
  cidr_block = aws_vpc.webserver_vpc.cidr_block
}

resource "aws_instance" "webserver_machine" {
  ami = data.aws_ssm_parameter.ami-id.value
  user_data  = file("/scripts/Apache-server.sh")
  subnet_id = aws_subnet.webserver_subnet.id
  instance_type = var.instance_type

  tags = {
    name = "webserver_instance"
  }
}


data "aws_ssm_parameter" "ami-id" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

