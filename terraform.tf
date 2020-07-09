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
	// UPDATE: set the bucket name for all your project state
    bucket = "terraform-state"
	// UPDATE: set the dynamodb table for all your lock entries to go into
    dynamodb_table = "terraform-lock"
    region = "eu-west-1"
	// UPDATE: Set the name of the state file, try to make it similar to your local.prefix value
    key = "SQUAD-my-project-deployment-role.tfstate"
  }
}
