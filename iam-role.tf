resource "aws_iam_role" "deployment_role" {
  name = "${local.dash_prefix}-deployment-role"

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
	  identifiers = [local.account_id]
	}
  }
}