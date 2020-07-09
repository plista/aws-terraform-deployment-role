resource "aws_iam_role" "deployment_role" {
  count = length(local.suffixes)
  name = "${local.prefixes["my_project_name"]}-deployment-role-${local.suffixes[count.index]}"
  description = "Role for ${local.prefixes["my_project_name"]} ${local.suffixes[count.index]}"

  assume_role_policy = data.aws_iam_policy_document.deployment_role_policy.json
}

data "aws_iam_policy_document" "deployment_role_policy" {
  statement {
	effect = "Allow"
	actions = ["sts:AssumeRole"]

	principals {
	  type = "Service"
	  identifiers = ["iam.amazonaws.com"]
	}
  }

  statement {
	effect = "Allow"
	actions = ["sts:AssumeRole"]

	principals {
	  type = "AWS"
	  identifiers = [var.aws_account_id]
	}
  }
}