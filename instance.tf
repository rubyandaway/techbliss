# VPC MODULE IMPORT #

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.77.0"

  name = "main-vpc"
  cidr = var.vpc_cidr_block

  azs                  = data.aws_availability_zones.available.names
  public_subnets       = [var.public_subnet_2_cidr, var.public_subnet_1_cidr]
  enable_dns_hostnames = true
  enable_dns_support   = true
}


## WEBSERVER MODULE IMPORT ##

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "amazon-linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-hvm-*-x86_64-ebs"]
  }
}

##LAUNCH CONFIGURATION##
resource "aws_launch_configuration" "webserver-launch-config" {
  name_prefix     = "webserver-launch-config"
  image_id        = data.aws_ami.amazon-linux.id
  instance_type   = var.instance_type
  #  user_data       = file("user-data.sh")
  user_data       = "${file("modules/webserver/scripts/Apache-server.sh")}"
  security_groups = [aws_security_group.lb-sg.id]

  lifecycle {
    create_before_destroy = true
  }
}

#AUTOSCALING GROUP #
resource "aws_autoscaling_group" "webautoscalers" {
  name = "webautoscalers"
  desired_capacity   = 2
  max_size           = 4
  min_size           = 2
  launch_configuration = aws_launch_configuration.webserver-launch-config.name
  vpc_zone_identifier = module.vpc.public_subnets

  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "WebAutoscalers"
  }

}

## LOAD BALANCER ##
resource "aws_lb" "webserver-lb" {
  name = "webserver-lb"
  internal = false
  load_balancer_type = "application"
  subnets =  module.vpc.public_subnets
  security_groups = [aws_security_group.lb-sg.id]

}

resource "aws_lb_listener" "webserver-listener" {
  load_balancer_arn = aws_lb.webserver-lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webserver-tg.arn
  }
}

resource "aws_lb_target_group" "webserver-tg" {
  name     = "webserver-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
}


#ATTACH ASG to LB ##
resource "aws_autoscaling_attachment" "asg_attachment_web" {
  autoscaling_group_name = aws_autoscaling_group.webautoscalers.id
  alb_target_group_arn = aws_lb_target_group.webserver-tg.arn
}


resource "aws_security_group" "webserver_machine" {
  name = "webserver_machine"
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.lb-sg.id]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.lb-sg.id]
  }

  vpc_id = module.vpc.vpc_id
}

## LB SECURITY GROUP ##
resource "aws_security_group" "lb-sg" {
  name   = "lb_sg"
  vpc_id = module.vpc.vpc_id

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

output "aws_lb_public_dns" {
  value = "https://${aws_lb.webserver-lb.dns_name}"
}











