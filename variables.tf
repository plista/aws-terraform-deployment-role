data "aws_caller_identity" "current" {}

variable "aws_region" {
  default = "eu-west-1"
}

locals {
  aws_account_id = data.aws_caller_identity.current.account_id

  // UPDATE: Set to the correct name for your squad
  // NOTE: We need this parameter separately sometimes to refer to resources by SQUAD name
  squad = "SQUAD"

  // UPDATE: Correctly set for the name of this software
  // HINT: use dash instead of underscore, it'll be more uniform across all sorts of resources that can't accept underscore
  // NOTE: You can use underscore if you really want to, but certain services will then be a mix of dash and underscore, which is a bit ugly
  prefixes = {
	squad_my_software = "${local.squad}-my-software"
  }

  // UPDATE: What environments your code will run it. This will create a set of resources with each of these prefixes
  suffixes = {
	"0" = "dev"
  }
}
