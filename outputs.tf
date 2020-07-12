output "role" {
  value = {
	for key,value in local.suffixes:
	value => aws_iam_role.SQUAD_my_software_deployment_role[key].arn
  }
}
