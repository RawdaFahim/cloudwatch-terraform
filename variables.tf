variable "aws_profile" {
  default = "cloudwatch-profile"
}
variable "aws_region" {
  default = "us-east-1"
}

variable "aws_account_id" {
  description = "AWS account id"
  type        = string
}

variable "key_name" {
  default = "rawdayousef-key"
}

variable "public_key" {
  description = "SSH public key"
  type        = string
}

variable "datadog_api_key" {}
variable "datadog_app_key" {}
variable "datadog_external_id" {}


variable "env_tag" {
  default = "prod"
}
