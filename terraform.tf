provider "aws" {
  version = "> 1.23"
  region = var.aws_region
}

provider "aws" {
  version = "> 1.23"
  alias = "cloudfront-acm-certs"
  region = "us-east-1"
}

terraform {
  required_version = "> 0.12.21"

  backend "s3" {
    encrypt = true
    bucket = "plista-platforms-terraform-state"
    dynamodb_table = "plista-platforms-terraform-lock"
    region = "eu-west-1"
    key = "mysoftware-deployment-role.tfstate"
  }
}
