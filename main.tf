module "iam-role" {
  source = "./iam-role"

  aws_region    	= var.aws_region
  aws_account_id    = local.aws_account_id
  prefix			= local.prefix
}
