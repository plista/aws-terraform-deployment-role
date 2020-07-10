# aws-terraform-deployment-role

A Blueprint project for a deployment role for AWS using terraform. It has a lot of examples and snippets that can 
easily be copied into the project to save time creating these roles in the future

## Before starting

This terraform repository assumes that the `s3` and `dynamodb table` for storing terraform state and lock 
information in, already exists. If this is not the case, then these resources must be created first. That
process is outside the scope of this repository.

## Important Advice: `terraform.tf`

It's very important to not forget to edit the `terraform.tf` file and set the correct information _BEFORE_ running
any terraform command. This is because terraform will create resources based on that configuration. 

By default in this repository, that information it set to the same `SQUAD-my-project-deployment-role.tfstate` value and
there will be problems if you do not change this before running terraform for the first time.

- Update the `bucket` value to match the desired s3 bucket to store state into
- Update the `dynamodb_table` value to match the desired dynamodb table to store terraform lock information in.
- Update the `key` value to match the `SQUAD` name and replace `my-project` with your `service name`

# Customising

### General Advice

It's generally a good idea to use dashes everywhere. 

Some AWS resources don't like underscores (load balancers for example). So if the names are mixed then the 
resulting resources may end up with a weird `mix-of-dashes_with_underscores-and-its_hard-to_read`

### Resource names

Find each resource with the prefix `SQUAD_my_software`. It's not possible to use interpolation, 
just edit it to match the `SQUAD` name and service name

### Local value `local.squad`

Try to make this value the same as the team the service is being built for

### Local value `local.suffixes`

On the production account, There are multiple suffixes in the value `local.suffixes`. So to minimise differences between deployments
the `dev` account deployment will also use suffixes, albeit only one. It's possible that multiple suffixes are
needed. However it's unlikely. 

If multiple suffixes are needed, add more with the same pattern as the existing ones.

### Local value `local.prefixes`

Most projects just need one prefix, so edit the one given to match the `squad` and `service name`. However
some projects use multiple prefixes. Remember that these prefixes are to define AWS resource names. 

So they have to match the project that the developer trying to build resource names for as the names have to match. 

### Edit `iam-policy.tf` to match the requirements

A lot of different types of deployment permissions are left in this file as a way to explain to the programmer
how to accomplish certain tasks. It's not an exhaustive list. However this list provides most of what is needed 
to run services on: API Gateway, Lambda, DynamoDB, Route53 domain, ECS.

It's not perfect. But it's a good starting place by which to add more helpful resources in the future. 

### Edit `terraform-state.tf` to match terraform configuration

The information in the following fields must match the information set into `terraform.tf`

- Update `arn:aws:s3:::terraform-state` with the correct s3 bucket
- Update `arn:aws:s3:::terraform-state/squad-my-software-dev.tfstate` to match the correct s3 bucket and state filename
- Update `arn:aws:dynamodb:${var.aws_region}:${local.aws_account_id}:table/terraform-lock` with the correct dynamodb table name

It's tempting to use variables here, but be careful as s3 requires lower case and dash-only filenames. Using the `local.prefixes` values
will have capital letters and the names will have to be passed through the `lower()` function first. 