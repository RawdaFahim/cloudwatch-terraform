# AWS CloudWatch ane Datadog Integration with Terraform

This project automates the infrastructure setup required to enable monitoring and metrics collection from AWS CloudWatch into Datadog, using **Terraform** for Infrastructure as Code (IaC).

It create the following resources:
- An EC2 instance with CloudWatch Agent configured.
- IAM roles and policies for EC2 to publish metrics to CloudWatch.
- IAM roles and policies to allow Datadog to access CloudWatch metrics.
- A Datadog provider setup (Note: the actual integration still needs to be completed manually via the Datadog console).

---

## 📁 File Structure
├── main.tf                 # Main Terraform config - loads both modules  
├── variables.tf            # Input variables definition  
├── terraform.tfvars        # Actual values for variables (needs to be edited)  
├── outputs.tf              # Outputs from the infrastructure  
├── modules/  
│   ├── aws-infra/          # Creates EC2 instance, IAM roles, and networking  
│   │   └── main.tf  
│   └── aws-roles/          # IAM roles/policies for Datadog integration  
│       └── main.tf  

---

## 🔧 Configuration

You need to edit the `terraform.tfvars` file and provide the required values.

Here’s a list of the variables and how to obtain them:

| Variable | Description | How to Get |
|---------|-------------|------------|
| `aws_profile` | The AWS CLI named profile | Defined in your AWS config (`~/.aws/config`) |
| `aws_region` | AWS region for resource creation | Example: `us-east-1` |
| `key_name` | Name for the SSH key pair | You choose this name |
| `public_key` | Your local public key content | Output of `cat ~/.ssh/id_rsa.pub` |
| `datadog_api_key` | Your Datadog API key | Found in Datadog under **Integrations > APIs** |
| `datadog_app_key` | Your Datadog APP key | Created in **Datadog > APIs** section |
| `datadog_external_id` | External ID required by Datadog to assume the IAM role | Shown during the AWS integration setup in Datadog |

---

## ▶️ Running the Project

### 1. Initialize Terraform

```bash
terraform init
```

### 2. Run with aws-vault (recommended for secure access to AWS credentials)
This Terraform configuration uses two modules to set up the infrastructure. Follow these steps to apply the modules in the correct order:

### 2.1. Run the first module (`aws-infra`):
This module sets up the EC2 instance, IAM roles, and networking resources necessary for CloudWatch integration.

**Important:** Complete the Datadog integration in the Datadog console after the first module runs.  
You'll need the **Role NAME** of the role used in the `aws-roles module`  and the **external ID** configured during setup in Datadog.

Run the following:

```bash
aws-vault exec <your-profile-name> -- terraform apply -target=module.aws_infra
```
Replace <your-profile-name> with the profile you’ve configured for AWS.

### 2.2 Run the second module (`aws-roles`):
This module configures the IAM roles and policies required for Datadog to access the CloudWatch metrics.

After completing the Datadog console integration, proceed with running the second module:
```bash
aws-vault exec <your-profile-name> -- terraform apply -target=module.aws_roles
```

🔐 **Why Use `aws-vault`?**

`aws-vault` is a tool that securely stores your AWS credentials in your operating system’s secure keystore  
(e.g., **Keychain on macOS**) and loads them into environment variables only when needed.  
This prevents long-lived credentials from sitting unencrypted on disk.

### 📦 Setup Instructions

```bash
# 1. Install aws-vault (on macOS)
brew install aws-vault

# 2. Add a profile

aws-vault add <aws-profile>

# When prompted, enter your AWS credentials.
# From that point on, you can use:

aws-vault exec <aws-profile> -- terraform apply
```

⚠️ **Note on Datadog Integration**

Due to current limitations of the Datadog Terraform provider, the AWS integration must be completed manually through the **Datadog console** after provisioning the IAM role.  
During that setup, you'll be asked to input:

1. **The Role ARN** (from the output of this Terraform project)
2. **The External ID** you configured

## Cleanup

To remove the infrastructure:

```bash
aws-vault exec <aws-profile> -- terraform destroy
```