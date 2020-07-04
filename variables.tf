data "aws_caller_identity" "current" {}

variable "aws_region" {
  default = "eu-west-1"
}

variable "squad" {
  description = "The squad name that these resources belong to"
  default = "SQUAD"
}
variable "name" {
  description = "The name of the software to use in creating aws resources"
  default = "mysoftware_service"
}

variable "env" {
  description = "[string] (staging|prod): One of the defined values"
  default = "dev"
}

locals {
  account_id  = data.aws_caller_identity.current.account_id
  underscore_prefix = join("_",[var.squad, var.env, var.name])
  dash_prefix = join("-",[var.squad, var.env, var.name])
}
