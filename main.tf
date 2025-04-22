##########################################################
# main.tf
#
# This is the root configuration file that calls the
# modules for setting up AWS infrastructure and roles.
#
# It initializes two modules:
# - aws-infra: Sets up EC2, IAM roles, CloudWatch, etc.
# - aws-roles: Creates IAM roles and policies for Datadog integration
##########################################################

# Call the aws_infra module to deploy EC2, IAM, and networking resources
module "aws_infra" {
  source            = "./modules/aws-infra"
  aws_profile       = var.aws_profile
  aws_region        = var.aws_region
  key_name          = var.key_name
  public_key        = var.public_key
}
# main.tf in the root module
# output "ec2_cloudwatch_role_arn" {
#   value = module.aws_infra.ec2_cloudwatch_role_arn
#   description = "The ARN of the IAM role for CloudWatch integration"
# }

# Call the aws-roles module to create IAM roles for Datadog integration
module "aws-roles" {
  source             = "./modules/aws-roles"
  aws_region        = var.aws_region
  aws_profile       = var.aws_profile
  datadog_api_key    = var.datadog_api_key
  datadog_app_key    = var.datadog_app_key
  datadog_external_id = var.datadog_external_id
}


