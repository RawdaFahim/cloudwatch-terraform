###########################################################
# File: outputs.tf
#
# This file contains the output variables for this Terraform
# configuration, which help to extract information like 
# resource ARNs, IP addresses, etc. after provisioning.
###########################################################

# Output: The ARN of the IAM role created for EC2 instance
# This output is helpful to complete the integration setup with Datadog
# modules/aws-infra/outputs.tf
output "ec2_cloudwatch_role_arn" {
  value       = aws_iam_role.ec2_cloudwatch_role.arn
  description = "The ARN of the IAM role attached to EC2 instance for CloudWatch integration"
}
