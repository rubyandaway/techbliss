variable "main_region" {
  type    = string
  default = "us-east-1"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "public_subnet_1_cidr" {
  default = "10.0.0.0/24"
}
variable "public_subnet_2_cidr" {
  default = "10.0.1.0/24"
}

variable "subnet_id" {
  default = ""
}

