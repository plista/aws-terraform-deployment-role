data "aws_caller_identity" "current" {}

variable "aws_region" {
  default = "eu-west-1"
}

variable "environment" {
  description = "[string] (staging|prod): One of the defined values"
  default = "dev"
}

locals {
  aws_account_id  = data.aws_caller_identity.current.account_id
  // UPDATE: Set to the correct name for your squad
  squad = "SQUAD"
  // UPDATE: Correctly set for the name of this software
  // HINT: use dash instead of underscore, it'll be more uniform across all sorts of resources that can't accept underscore
  // NOTE: You can use underscore if you really want to, but certain services will then be a mix of dash and underscore, which is a bit ugly
  prefix = "${local.squad}-my-software"
}
