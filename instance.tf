# VPC MODULE IMPORT #
module "vpc" {
  source = "./modules/vpc"
  region = var.main_region
  vpc_cidr_block = var.vpc_cidr_block
  public_subnet_1_cidr = var.public_subnet_1_cidr
  public_subnet_2_cidr = var.public_subnet_2_cidr
}

# WEBSERVER MODULE IMPORT #
module "webserver" {
  source = "./modules/webserver"
  region = var.main_region

}

# WEBSERVER A #
resource "aws_instance" "webserver-instance-a"  {
  ami           = module.webserver.ami_id
  subnet_id =  module.vpc.module_public_subnet_1
  instance_type = var.instance_type

  tags = {
    Name = "Webserver A"
  }

}

# WEBSERVER B #
resource "aws_instance" "webserver-instance-b" {
  ami           = module.webserver.ami_id
  subnet_id     = module.vpc.module_public_subnet_2
  instance_type = var.instance_type

  tags = {
    Name = "Webserver B"
  }
}

# LOAD BALANCER #
resource "aws_elb" "web" {
  name = "webserver-elb"

  #  subnets         = aws_subnet.subnet[*].id
  #  security_groups = [aws_security_group.elb-sg.id]
  #  instances       = aws_instance.nginx[*].id

  subnets = ["aws_subnet.module_public_subnet_[*].id"]
  security_groups = ""
  instances = ["$aws_instance.webserver-instance.*.id"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

}

# ASG LAUNCH TEMPLATE
resource "aws_launch_template" "web-asg" {
  name_prefix   = "autoscaler"
  image_id      = module.webserver.ami_id
  instance_type = var.instance_type
}

#ASG #
resource "aws_autoscaling_group" "webautoscalers" {
  availability_zones = ["us-east-1a"]
  desired_capacity   = 2
  max_size           = 6
  min_size           = 2

  launch_template {
    id      = aws_launch_template.web-asg
    version = "$Latest"
  }
}

#ATTACH ASG to ELB ##
resource "aws_autoscaling_attachment" "asg_attachment_web" {
  autoscaling_group_name = aws_autoscaling_group.webautoscalers.id
  elb                    = aws_elb.web.id
}




