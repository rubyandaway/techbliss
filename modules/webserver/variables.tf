variable "region" {
  type = string
  default = "us-east-1"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "ami" {
  type = string
  default = "ami-04505e74c0741db8d"
}

