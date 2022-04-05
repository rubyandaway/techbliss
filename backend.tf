terraform {
  backend "s3" {
    bucket = "bucks-80-weed"
    key    = "dev/terraform.tfstate"
    region = "us-east-1"
  }
}