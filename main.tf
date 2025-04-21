module "aws_infra" {
  source            = "./modules/aws-infra"
  aws_profile       = var.aws_profile
  aws_region        = var.aws_region
  key_name          = var.key_name
  public_key        = var.public_key
}

module "aws-roles" {
  source             = "./modules/aws-roles"
  aws_region        = var.aws_region
  aws_profile       = var.aws_profile
  aws_account_id     = var.aws_account_id
  datadog_api_key    = var.datadog_api_key
  datadog_app_key    = var.datadog_app_key
  datadog_external_id = var.datadog_external_id
  # env_tag            = var.env_tag
}


