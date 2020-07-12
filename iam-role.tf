resource "aws_iam_role" "SQUAD_my_software_deployment_role" {
  count = length(local.suffixes)
  name = "${local.prefixes["my_software"]}-deployment-role-${local.suffixes[count.index]}"
  description = "Role for ${local.prefixes["my_software"]} ${local.suffixes[count.index]}"

  assume_role_policy = data.aws_iam_policy_document.SQUAD_my_software_deployment_role_policy.json
}

data "aws_iam_policy_document" "SQUAD_my_software_deployment_role_policy" {
  statement {
	effect = "Allow"
	actions = [
	  "sts:AssumeRole"
	]

	principals {
	  type = "Service"
	  identifiers = [
		"iam.amazonaws.com"
	  ]
	}
  }

  statement {
	effect = "Allow"
	actions = [
	  "sts:AssumeRole"
	]

	principals {
	  type = "AWS"
	  identifiers = [
		local.aws_account_id
	  ]
	}
  }
}