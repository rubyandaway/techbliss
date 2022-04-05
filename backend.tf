terraform {
  backend "s3" {
    bucket = "bucks-90-weed"
    key    = "dev/terraform.tfstate"
    region = "us-east-1"
  }
}