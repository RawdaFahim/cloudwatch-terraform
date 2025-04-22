variable "aws_profile" {
  default = "cloudwatch-profile"
}
variable "aws_region" {
  default = "us-east-1"
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


