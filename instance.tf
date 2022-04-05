module "vpc" {
  source = "./modules/vpc"
  region = var.main_region
  vpc_cidr_block = var.vpc_cidr_block
  public_subnet_1_cidr = var.public_subnet_1_cidr
  public_subnet_2_cidr = var.public_subnet_2_cidr
}

module "webserver" {
  source = "./modules/webserver"
  region = var.main_region

}


resource "aws_instance" "webserver-instance"  {
  ami           = module.webserver.ami_id
  subnet_id =  module.vpc.module_public_subnet_1
  instance_type = var.instance_type

  tags = {
    Name = "Webserver machine"
  }

}





