output "role" {
  value = aws_iam_role.SQUAD_my_software_deployment_role.*.arn
}
