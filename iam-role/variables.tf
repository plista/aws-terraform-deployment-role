data "aws_caller_identity" "current" {}

variable "aws_account_id" {
  description = "The AWS Account ID"
}

variable "aws_region" {
  description = "The AWS Region being deployed on"
}

variable "prefix" {
  description = "The service prefix"
}

variable "squad" {
  description = "The squad name"
}

variable "environment" {
  description = "The runtime environment name"
}

locals {
  // NOTE: on 'dev' account, prefixes/suffixes are a bit over the top since we don't have a need for them
  // However on the production account, they'll be very important, so they're used by default
  // In order that things run the same on all environments and we use locals to hide those differences

  prefixes = {
	// UPDATE: Change the key to a non-conflicting name which can overlap with many projects
	// e.g. platforms_something_service
	my_project_name = var.prefix
  }

  suffixes = {
	"0" = "dev"
  }
}
