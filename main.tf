terraform {
  backend "s3" {
    bucket = "bucks-90-weed"
    key    = "dev/terraform.tfstate"
    region = "us-east-1"
    acl    = "private"
  }
}
provider "aws" {
  region = var.main_region
}

module "vpc" {
  source = "./modules/vpc"
  region = var.main_region
}

module "webserver" {
  source = "./modules/webserver"
  region = var.main_region
}


resource "aws_instance" "my-instance" {
  ami           = module.vpc.ami_id
  subnet_id     = module.vpc.subnet_id
  instance_type = var.instance_type
}

resource "aws_instance" "webserver-instance" {
  ami           = module.webserver.webserver_ami_id
  subnet_id     = module.webserver.webserver_subnet_id
  instance_type = var.instance_type
}





