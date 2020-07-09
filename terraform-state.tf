// NOTE: We have a separate policy for terraform s3 state file and dynamodb lock table because
// On the production account, this policy is not needed because it's handled by the gitlab runner
// However because we want to deploy this on the dev account. We need to add this extra policy
// This is why the 'iam-role' directory exists, to create a new module which is isolated
resource "aws_iam_policy" "terraform_state_policy" {
  name = "${local.prefix}-terraform-state-policy-${var.environment}"

  policy = data.aws_iam_policy_document.terraform_state_permissions.json
}

data "aws_iam_policy_document" "terraform_state_permissions" {
  // Allow to read the s3 state bucket
  statement {
    effect = "Allow"
    resources = ["arn:aws:s3:::terraform-state"]
    actions = ["s3:ListBucket"]
  }

  // allow access to the following state files
  statement {
    effect = "Allow"
    resources = ["arn:aws:s3:::terraform-state/${local.prefix}.tfstate"]
    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]
  }

  // allow access to the dynamodb lock table to prevent clashes whilst deploying with other developers
  statement {
    effect = "Allow"
    resources = ["arn:aws:dynamodb:${var.aws_region}:${local.aws_account_id}:table/terraform-lock"]
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
    ]
  }
}

resource "aws_iam_role_policy_attachment" "deployment-role-to-terraform-state-policy" {
  role = module.iam-role.deployment_role.0.name
  policy_arn = aws_iam_policy.terraform_state_policy.arn
}