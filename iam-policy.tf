resource "aws_iam_policy" "deployment_policy" {
  name = "${local.dash_prefix}-deployment-policy"

  policy = data.aws_iam_policy_document.deployment_permissions.json
}

data "aws_iam_policy_document" "deployment_permissions" {
  ////////////////////////////////////////////////////////////
  //	IAM ROLES AND POLICIES
  ////////////////////////////////////////////////////////////

  // NOTES
  // The iam:PushRole is very important, I lost hours before I realised this
  // If you can't figure out what permissions you need, remember, cloudtrail keeps
  // track of most of your API accesses, the errors might be logged in there.
  statement {
    effect = "Allow"
    resources = [
      "arn:aws:iam::${local.account_id}:policy/${local.dash_prefix}-dynamodb-policy",
      "arn:aws:iam::${local.account_id}:policy/${local.dash_prefix}-lambda-policy",
      "arn:aws:iam::${local.account_id}:policy/${local.dash_prefix}-cloudwatch-policy",
      "arn:aws:iam::${local.account_id}:role/${local.dash_prefix}-lambda-role",
      "arn:aws:iam::${local.account_id}:role/SELFSV-api_gateway-api-gateway-role",
    ]
    actions = [
      "iam:CreateRole",
      "iam:GetRole",
      "iam:DeleteRole",
      // IMPORTANT: Creating lambdas need to 'pass a role' to the lambda. Without this, creating lambdas will fail
      "iam:PassRole",

      "iam:GetPolicy",
      "iam:CreatePolicy",
      "iam:DeletePolicy",

      "iam:GetPolicyVersion",
      "iam:ListPolicyVersions",

      "iam:AttachRolePolicy",
      "iam:DetachRolePolicy",

      "iam:ListAttachedRolePolicies",
      "iam:ListInstanceProfilesForRole",
    ]
  }

  ////////////////////////////////////////////////////////////
  //	EC2 MANAGEMENT
  ////////////////////////////////////////////////////////////
  //  statement {
  //    effect = "Allow"
  //    resources = [aws_iam_role.deployment_role.arn]
  //    actions = ["ec2:DescribeAccountAttributes"]
  //  }

  ////////////////////////////////////////////////////////////
  //	MANAGE API GATEWAY RESOURCES
  ////////////////////////////////////////////////////////////

  // NOTE:
  // I tried to limit these resources to a project level, but they don't appear to be using anything I can target
  // It just uses a bunch of random identifiers that I can't predict before I deploy the software
  statement {
    effect = "Allow"
    resources = [
      "arn:aws:apigateway:${var.aws_region}::/apis",
      "arn:aws:apigateway:${var.aws_region}::/apis/*",

      "arn:aws:apigateway:${var.aws_region}::/domainnames",
      "arn:aws:apigateway:${var.aws_region}::/domainnames/*",

      "arn:aws:apigateway:${var.aws_region}::/restapis",
      "arn:aws:apigateway:${var.aws_region}::/restapis/*",

      "arn:aws:apigateway:${var.aws_region}::/tags",
      "arn:aws:apigateway:${var.aws_region}::/tags/*",
    ]
    actions = [
	  "apigateway:GetRestApi",
	  "apigateway:GetRestApis",
	  "apigateway:GetResources",
	  "apigateway:TagResource",
	  "apigateway:GET",
	  "apigateway:DELETE",
	  "apigateway:POST",
	  "apigateway:PUT",
      "apigateway:CreateDeployment",

	  // These are all the permissions I found, if you need an extra one, pluck it out from here and use it
//      "apigateway:CreateModel",
//      "apigateway:CreateResource",
//      "apigateway:CreateRestApi",
//      "apigateway:DeleteIntegration",
//      "apigateway:DeleteIntegrationResponse",
//      "apigateway:DeleteMethod",
//      "apigateway:DeleteMethodResponse",
//      "apigateway:DeleteModel",
//      "apigateway:DeleteResource",
//      "apigateway:DeleteRestApi",
//      "apigateway:DeleteStage",
//      "apigateway:GetDeployment",
//      "apigateway:GetIntegration",
//      "apigateway:GetIntegrationResponse",
//      "apigateway:GetMethod",
//      "apigateway:GetMethodResponse",
//      "apigateway:GetModel",
//      "apigateway:GetResource",
//      "apigateway:GetStage",
//      "apigateway:PutIntegration",
//      "apigateway:PutIntegrationResponse",
//      "apigateway:PutMethod",
//      "apigateway:PutMethodResponse",
//      "apigateway:UpdateStage",
    ]
  }

  ////////////////////////////////////////////////////////////
  //	ACM SSL CERTIFICATES
  ////////////////////////////////////////////////////////////

  // Request certificates and tags them for creation purposes
  // When certificates are created, there is no ARN by which to restrict the policy statement
  // Equally, when adding tags to a certificate during creation, it has no ARN, so "*" is used here also
  statement {
    effect = "Allow"
    resources = ["*"]
    actions = [
      "acm:RequestCertificate",
      "acm:AddTagsToCertificate",
    ]
  }

  // Manage existing certificates
  statement {
    effect = "Allow"
    resources = ["arn:aws:acm:*:${local.account_id}:certificate/*"]
    actions = [
      "acm:DescribeCertificate",
      "acm:ListTagsForCertificate",
      "acm:DeleteCertificate",
      "acm:AddTagsToCertificate",
    ]
  }

  ////////////////////////////////////////////////////////////
  //	MANAGE CUSTOM DOMAIN NAMES
  ////////////////////////////////////////////////////////////

  // List what route53 domains exist
  statement {
    effect = "Allow"
    resources = ["*"]
    actions = ["route53:ListHostedZones"]
  }

  // Allow to view the status of changes to records
  statement {
    effect = "Allow"
    resources = ["arn:aws:route53:::change/*"]
    actions = ["route53:GetChange"]
  }

  // List zones, tags for records sets and resources, etc
  statement {
    effect = "Allow"
    resources = ["arn:aws:route53:::hostedzone/*"]
    actions = [
      "route53:ListHostedZones",
      "route53:GetHostedZone",
      "route53:ListTagsForResource",
      "route53:ListResourceRecordSets",
      "route53:ChangeResourceRecordSets",
    ]
  }

  ////////////////////////////////////////////////////////////
  //	MANAGE LAMBDAS, SHARED LAYERS
  ////////////////////////////////////////////////////////////

  statement {
    effect = "Allow"
    resources = [
      "arn:aws:lambda:*:${local.account_id}:function:${local.underscore_prefix}*",
      "arn:aws:lambda:*:${local.account_id}:layer:${local.underscore_prefix}*",
    ]
    actions = [
      "lambda:CreateFunction",
      "lambda:UpdateFunctionCode",
      "lambda:UpdateFunctionConfiguration",
      "lambda:GetFunction",
      "lambda:DeleteFunction",
      "lambda:CreateLayer",
      "lambda:CreateLayerVersion",
      "lambda:PublishLayerVersion",
      "lambda:GetLayerVersion",
      "lambda:DeleteLayerVersion",
      "lambda:ListVersionsByFunction",
    ]
  }

  ////////////////////////////////////////////////////////////
  //	CREATE LOG GROUPS, STREAMS, RETENTION POLICIES
  ////////////////////////////////////////////////////////////

  statement {
    effect = "Allow"
    resources = ["arn:aws:logs:${var.aws_region}:${local.account_id}:log-group::log-stream:"]
    actions = ["logs:DescribeLogGroups"]
  }

  statement {
    effect = "Allow"
    resources = ["arn:aws:logs:${var.aws_region}:${local.account_id}:log-group:*${local.underscore_prefix}*:log-stream:"]
    actions = [
      "logs:CreateLogGroup",
      "logs:ListTagsLogGroup",
      "logs:DeleteLogGroup",
      "logs:PutRetentionPolicy",
    ]
  }

  ////////////////////////////////////////////////////////////
  //	READ FROM SSM PARAMETER STORE
  ////////////////////////////////////////////////////////////

  statement {
    effect = "Allow"
    resources = [
      "arn:aws:ssm:${var.aws_region}:${local.account_id}:parameter/${var.squad}/platforms_api/${var.env}/root_domain",
      "arn:aws:ssm:${var.aws_region}:${local.account_id}:parameter/${var.squad}/api_server/${var.env}/api_server_url",
      "arn:aws:ssm:${var.aws_region}:${local.account_id}:parameter/${var.squad}/api_server/${var.env}/api_email",
      "arn:aws:ssm:${var.aws_region}:${local.account_id}:parameter/${var.squad}/api_server/${var.env}/api_password",
    ]
    actions = ["ssm:GetParameter"]
  }

  ////////////////////////////////////////////////////////////
  //	TERRAFORM S3 STATE (s3 and dynamodb)
  ////////////////////////////////////////////////////////////

  // Allow to read the s3 state bucket
  statement {
    effect = "Allow"
    resources = ["arn:aws:s3:::plista-platforms-terraform-state"]
    actions = ["s3:ListBucket"]
  }

  // allow access to the following state files
  statement {
    effect = "Allow"
    resources = [
      "arn:aws:s3:::plista-platforms-terraform-state/notifications.tfstate",
      "arn:aws:s3:::plista-platforms-terraform-state/platforms-aws-api-gateway.tfstate",
      "arn:aws:s3:::plista-platforms-terraform-state/platforms-aws-api-gateway-authorizer.tfstate",
      "arn:aws:s3:::plista-platforms-terraform-state/platforms-aws-persistent-resources.tfstate",
    ]
    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]
  }

  // allow access to the dynamodb lock table to prevent clashes whilst deploying with other developers
  statement {
    effect = "Allow"
    resources = ["arn:aws:dynamodb:${var.aws_region}:${local.account_id}:table/plista-platforms-terraform-lock"]
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
    ]
  }
}

resource "aws_iam_role_policy_attachment" "deployment-role-to-deployment-policy" {
  role = aws_iam_role.deployment_role.name
  policy_arn = aws_iam_policy.deployment_policy.arn
}
