# main.tf

# # 1. Tell Terraform to use AWS
provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

# 2. Create a keypair with my public key
resource "aws_key_pair" "my_key" {
  key_name   = var.key_name
  public_key = var.public_key
}

# 3. Create a role for the EC2 instance to talk to CloudWatch
resource "aws_iam_role" "ec2_cloudwatch_role" {
  name = "ec2_cloudwatch_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Effect = "Allow",
      Sid    = ""
    }]
  })
}

resource "aws_iam_policy" "cloudwatch_policy" {
  name        = "CloudWatchPermissions"
  description = "CloudWatch permissions for EC2 instance"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "cloudwatch:PutMetricData",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cloudwatch_policy_attachment" {
  role       = aws_iam_role.ec2_cloudwatch_role.name
  policy_arn = aws_iam_policy.cloudwatch_policy.arn
}


# 4. Attach AWS's built-in policy for CloudWatch to that role
resource "aws_iam_role_policy_attachment" "cloudwatch_attach" {
  role       = aws_iam_role.ec2_cloudwatch_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# 5. Create an instance profile (this is like an "IAM role for EC2")
resource "aws_iam_instance_profile" "cloudwatch_profile" {
  name = "cloudwatch_profile"
  role = aws_iam_role.ec2_cloudwatch_role.name
}

# 6. Create ec2 instance
## 6.1 Fetch amazon image
data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"] # Official Amazon images
}

# 6.2. Get the default VPC
data "aws_vpc" "default" {
  default = true
}

## 6.3. Allow SSH 
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      =  data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
## 6.4 Create Instance
resource "aws_instance" "web" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.my_key.key_name
  user_data                   = file("${path.root}/user_data.sh")
  iam_instance_profile        = aws_iam_instance_profile.cloudwatch_profile.name
  security_groups             = [aws_security_group.allow_ssh.name]  # Add this line


  tags = {
    Name = "Terraform-CloudWatch-Demo"
  }
}
