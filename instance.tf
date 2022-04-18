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

resource "aws_elb" "webserver-elb" {
  name = "webserver-elb"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 60
  }

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

}

resource "aws_security_group" "elb-sg" {
  name   = "elb_sg"
  vpc_id = module.vpc.module_vpc_id

  #Allow HTTP from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

output "aws_elb_public_dns" {
  value = aws_elb.webserver-elb.dns_name
}

# ASG LAUNCH TEMPLATE
resource "aws_launch_template" "web-asg" {
  name_prefix   = "autoscaler"
  image_id      = module.webserver.ami_id
  instance_type = var.instance_type

  tags = {
    Name = "From-web-server-asg"
  }
}

#ASG #
resource "aws_autoscaling_group" "webautoscalers" {
  availability_zones = ["us-east-1a" , "us-east-1b" , "us-east-1c"]
  desired_capacity   = 2
  max_size           = 4
  min_size           = 2

  launch_template {
    id      = aws_launch_template.web-asg.id
    version = "$Latest"
  }
}

#ATTACH ASG to ELB ##
resource "aws_autoscaling_attachment" "asg_attachment_web" {
  autoscaling_group_name = aws_autoscaling_group.webautoscalers.id
  elb                    = aws_elb.webserver-elb.id
}




