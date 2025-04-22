##########################################################
# aws-roles/main.tf
#
# This module creates the IAM role and permissions
# required to integrate AWS CloudWatch with Datadog.
#
# It assumes:
# - An external ID provided by Datadog
# - You already have Datadog API and APP keys
#
# Resources created:
# - IAM role for Datadog
# - IAM policy for accessing CloudWatch & logs
# - Policy attachments for additional AWS permissions
##########################################################


# 1. Terraform configuration to use the Datadog provider
terraform {
  required_providers {
    datadog = {
      source  = "datadog/datadog"
      version = "~> 3.0"  # or whatever version you want
    }
  }
}

# 2. AWS provider block to authenticate with AWS
provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

# 3. Datadog provider block to authenticate with the Datadog API
provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
}


# 4. IAM role to allow Datadog's AWS account to assume this role for integration
resource "aws_iam_role" "datadog_integration" {
  name = "datadog-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::464622532012:root" # Datadog's AWS account
        },
        Action = "sts:AssumeRole",
        Condition = {
          StringEquals = {
            "sts:ExternalId" = var.datadog_external_id 
          }
        }
      }
    ]
  })
}

# 5. Custom IAM policy to allow Datadog to read CloudWatch metrics and logs
data "aws_iam_policy_document" "datadog_policy" {
  statement {
    effect = "Allow"
    actions = [
      "cloudwatch:GetMetricData",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:ListMetrics",
      "logs:DescribeLogGroups",
      "logs:GetLogEvents",
      "logs:DescribeLogStreams",
      "logs:FilterLogEvents"
    ]
    resources = ["*"] # Grants access to all resources for these actions
  }
}
# 6. Attach the custom CloudWatch/logs policy to the Datadog role
resource "aws_iam_role_policy" "datadog_policy_attach" {
  name   = "datadog-cloudwatch-policy"
  role   = aws_iam_role.datadog_integration.name
  policy = data.aws_iam_policy_document.datadog_policy.json
}


# 7. Attach AWS-managed ReadOnlyAccess policy for general read access across services
resource "aws_iam_role_policy_attachment" "datadog_readonly_access" {
  role       = aws_iam_role.datadog_integration.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# 8. Attach AWS-managed CloudWatchReadOnlyAccess for additional CloudWatch permissions
resource "aws_iam_role_policy_attachment" "datadog_cloudwatch_readonly" {
  role       = aws_iam_role.datadog_integration.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
}
