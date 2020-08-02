resource "aws_iam_policy" "SQUAD_my_software_deployment_policy" {
  count = length(local.suffixes)
  name = "${local.prefixes["squad_my_software"]}-deployment-policy-${local.suffixes[count.index]}"

  policy = data.aws_iam_policy_document.SQUAD_my_software_deployment_permissions[ count.index ].json
}

data "aws_iam_policy_document" "SQUAD_my_software_deployment_permissions" {
  count = length(local.suffixes)

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
	  "arn:aws:iam::${local.aws_account_id}:role/${local.prefixes["squad_my_software"]}-lambda-role-${local.suffixes[count.index]}",
	  "arn:aws:iam::${local.aws_account_id}:policy/${local.prefixes["squad_my_software"]}-lambda-policy-${local.suffixes[count.index]}",

	  "arn:aws:iam::${local.aws_account_id}:policy/${local.prefixes["squad_my_software"]}-dynamodb-policy-${local.suffixes[count.index]}",
	  "arn:aws:iam::${local.aws_account_id}:policy/${local.prefixes["squad_my_software"]}-cloudwatch-policy-${local.suffixes[count.index]}",
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

	  "iam:CreatePolicyVersion",
	  "iam:GetPolicyVersion",
	  "iam:ListPolicyVersions",
	  "iam:DeletePolicyVersion",

	  "iam:AttachRolePolicy",
	  "iam:DetachRolePolicy",

	  "iam:ListAttachedRolePolicies",
	  "iam:ListInstanceProfilesForRole",
	]
  }

  ////////////////////////////////////////////////////////////
  //	EC2 MANAGEMENT
  ////////////////////////////////////////////////////////////
  statement {
	effect = "Allow"
	resources = [
	  aws_iam_role.SQUAD_my_software_deployment_role[ count.index ].arn
	]
	actions = [
	  "ec2:DescribeAccountAttributes"
	]
  }

  ////////////////////////////////////////////////////////////
  //	MANAGE ECS RESOURCES
  ////////////////////////////////////////////////////////////
  statement {
	effect = "Allow"
	resources = [
	  "*"
	]
	actions = [
	  "ecs:CreateCluster",
	  "ecs:DescribeTaskDefinition",
	  "ecs:DeregisterTaskDefinition",
	  "ecs:RegisterTaskDefinition",
	  "ec2:CreateSecurityGroup",
	  "ec2:DescribeSecurityGroups",
	  "ec2:CreateTags",
	  "ec2:DescribeNetworkInterfaces",
	  "elasticloadbalancing:DescribeLoadBalancers",
	  "elasticloadbalancing:DescribeTags",
	  "elasticloadbalancing:DescribeLoadBalancerAttributes",
	  "elasticloadbalancing:DescribeTargetGroups",
	  "elasticloadbalancing:DescribeTargetGroupAttributes",
	  "elasticloadbalancing:DescribeListeners",
	]
  }

  statement {
	effect = "Allow"
	resources = [
	  "arn:aws:ec2:${var.aws_region}:${local.aws_account_id}:security-group/*"
	]
	actions = [
	  "ec2:DescribeSecurityGroups",
	  "ec2:DeleteSecurityGroup",
	  "ec2:RevokeSecurityGroupEgress",
	  "ec2:RevokeSecurityGroupIngress",
	  "ec2:AuthorizeSecurityGroupIngress",
	  "ec2:AuthorizeSecurityGroupEgress",
	]
  }

  statement {
	effect = "Allow"
	resources = [
	  "arn:aws:elasticloadbalancing:${var.aws_region}:${local.aws_account_id}:loadbalancer/net/${local.prefixes["squad_my_software"]}-${local.suffixes[count.index]}/*"
	]
	actions = [
	  "elasticloadbalancing:CreateLoadBalancer",
	  "elasticloadbalancing:DeleteLoadBalancer",
	  "elasticloadbalancing:ModifyLoadBalancerAttributes",
	  "elasticloadbalancing:CreateListener",
	  "elasticloadbalancing:AddTags",
	]
  }

  statement {
	effect = "Allow"
	resources = [
	  "arn:aws:elasticloadbalancing:${var.aws_region}:${local.aws_account_id}:listener/net/${local.prefixes["squad_my_software"]}-${local.suffixes[count.index]}/*"
	]
	actions = [
	  "elasticloadbalancing:DeleteListener",
	]
  }

  statement {
	effect = "Allow"
	resources = [
	  "arn:aws:elasticloadbalancing:${var.aws_region}:${local.aws_account_id}:targetgroup/${local.prefixes["squad_my_software"]}-${local.suffixes[count.index]}/*"
	]
	actions = [
	  "elasticloadbalancing:CreateTargetGroup",
	  "elasticloadbalancing:DeleteTargetGroup",
	  "elasticloadbalancing:ModifyTargetGroup",
	  "elasticloadbalancing:ModifyTargetGroupAttributes",
	  "elasticloadbalancing:AddTags"
	]
  }

  statement {
	effect = "Allow"
	resources = [
	  "arn:aws:ecs:${var.aws_region}:${local.aws_account_id}:cluster/${local.prefixes["squad_my_software"]}-${local.suffixes[count.index]}"
	]
	actions = [
	  "ecs:DescribeClusters",
	  "ecs:DeleteCluster",
	]
  }

  statement {
	effect = "Allow"
	resources = [
	  "arn:aws:ecs:${var.aws_region}:${local.aws_account_id}:service/${local.prefixes["squad_my_software"]}-${local.suffixes[count.index]}/container_name"
	]
	actions = [
	  "ecs:DescribeServices",
	  "ecs:CreateService",
	  "ecs:UpdateService",
	  "ecs:DeleteService",
	]
  }

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
	  "apigateway:UpdateAuthorizer",
	  "apigateway:CreateDeployment",
	  "apigateway:GetRestApi",
	  "apigateway:GetRestApis",
	  "apigateway:GetResources",
	  "apigateway:TagResource",
	  "apigateway:GET",
	  "apigateway:DELETE",
	  "apigateway:POST",
	  "apigateway:PUT",
	  "apigateway:PATCH",

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
	resources = [
	  "*"
	]
	actions = [
	  "acm:RequestCertificate",
	  "acm:AddTagsToCertificate",
	]
  }

  // Manage existing certificates
  statement {
	effect = "Allow"
	resources = [
	  "arn:aws:acm:*:${local.aws_account_id}:certificate/*"
	]
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
	resources = [
	  "*"
	]
	actions = [
	  "route53:ListHostedZones"
	]
  }

  // Allow to view the status of changes to records
  statement {
	effect = "Allow"
	resources = [
	  "arn:aws:route53:::change/*"
	]
	actions = [
	  "route53:GetChange"
	]
  }

  // List zones, tags for records sets and resources, etc
  statement {
	effect = "Allow"
	resources = [
	  "arn:aws:route53:::hostedzone/*"
	]
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
	  "arn:aws:lambda:${var.aws_region}:${local.aws_account_id}:function:${local.prefixes["squad_my_software"]}-function-name-${local.suffixes[count.index]}*",
	]
	actions = [
	  "lambda:CreateFunction",
	  "lambda:DeleteFunction",
	  "lambda:UpdateFunctionCode",
	  "lambda:UpdateFunctionConfiguration",
	  "lambda:GetFunction",
	  "lambda:ListVersionsByFunction",
	]
  }

  statement {
	effect = "Allow"
	resources = [
	  "arn:aws:lambda:${var.aws_region}:${local.aws_account_id}:layer:${local.prefixes["squad_my_software"]}-layer-name-${local.suffixes[count.index]}*",
	]
	actions = [
	  "lambda:CreateLayer",
	  "lambda:DeleteLayer",
	  "lambda:CreateLayerVersion",
	  "lambda:PublishLayerVersion",
	  "lambda:GetLayerVersion",
	  "lambda:DeleteLayerVersion",
	]
  }


  ////////////////////////////////////////////////////////////
  //	CREATE LOG GROUPS, STREAMS, RETENTION POLICIES
  ////////////////////////////////////////////////////////////

  statement {
	effect = "Allow"
	resources = [
	  "arn:aws:logs:${var.aws_region}:${local.aws_account_id}:log-group::log-stream:"
	]
	actions = [
	  "logs:DescribeLogGroups"
	]
  }

  statement {
	effect = "Allow"
	resources = [
	  "arn:aws:logs:${var.aws_region}:${local.aws_account_id}:log-group:/aws/lambda/${local.prefixes["squad_my_software"]}-my-log-group-${local.suffixes[count.index]}:log-stream:",
	]
	actions = [
	  "logs:CreateLogGroup",
	  "logs:ListTagsLogGroup",
	  "logs:DeleteLogGroup",
	  "logs:PutRetentionPolicy",
	]
  }

  ////////////////////////////////////////////////////////////
  //	MANAGE PARAMETERS FROM SSM PARAMETER STORE
  ////////////////////////////////////////////////////////////
  statement {
	effect = "Allow"
	resources = [
	  "arn:aws:ssm:${var.aws_region}:${local.aws_account_id}:parameter/SQUAD/api-gateway/${local.suffixes[count.index]}/domain",
	]
	actions = [
	  "ssm:GetParameter",
	  "ssm:GetParameters",
	  "ssm:PutParameter",
	  "ssm:DeleteParameter",
	  "ssm:ListTagsForResource",
	]
  }

  statement {
	effect = "Allow"
	resources = [
	  "arn:aws:ssm:${var.aws_region}:${local.aws_account_id}:*",
	]
	actions = [
	  "ssm:DescribeParameters",
	]
  }

  ////////////////////////////////////////////////////////////
  //	CREATE AND MANAGE COGNITO USER POOLS
  ////////////////////////////////////////////////////////////
  statement {
	effect = "Allow"
	resources = [
	  "arn:aws:cognito-idp:${var.aws_region}:${local.aws_account_id}:userpool/${var.aws_region}*"
	]
	actions = [
	  "cognito-idp:DescribeUserPoolClient",
	  "cognito-idp:CreateUserPoolClient",
	  "cognito-idp:DeleteUserPoolClient",
	]
  }

  statement {
	effect = "Allow"
	resources = [
	  "*"
	]
	actions = [
	  "cognito-idp:CreateUserPool"
	]
  }

  ////////////////////////////////////////////////////////////
  //	CREATE AND MANAGE DYNAMODB TABLES
  ////////////////////////////////////////////////////////////

  statement {
	effect = "Allow"
	resources = [
	  // UPDATE: Set the appropriate dynamodb table you wish to manage
	  "arn:aws:dynamodb:${var.aws_region}:${local.aws_account_id}:table/${local.prefixes["squad_my_software"]}-my-table-name-${local.suffixes[count.index]}",
	]
	actions = [
	  "dynamodb:DescribeTable",
	  "dynamodb:DescribeTimeToLive",
	  "dynamodb:ListTagsOfResource",
	  "dynamodb:DescribeContinuousBackups",
	]
  }
}

resource "aws_iam_role_policy_attachment" "SQUAD_my_software_deployment-role-to-deployment-policy" {
  count = length(local.suffixes)
  role = aws_iam_role.SQUAD_my_software_deployment_role[ count.index ].name
  policy_arn = aws_iam_policy.SQUAD_my_software_deployment_policy[ count.index ].arn
}
