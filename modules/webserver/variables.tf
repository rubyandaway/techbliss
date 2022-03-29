variable "region" {
  type = string
  default = "us-east-1"
}

variable "env" {
  default     = ""
}

variable "prod-subnet" {
  default = ""
}

variable "dev-subnet" {
  default = ""
}

variable "instance_type" {
  default = ""
}

variable "vpc_cidr" {
  default = ""
}

variable "webserver_cidr" {
  default = ""
}