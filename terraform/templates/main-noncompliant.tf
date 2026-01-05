# Provider configuration
provider "aws" {
  region = "us-east-1"
}

# Non-compliant S3 bucket - NO ENCRYPTION
resource "aws_s3_bucket" "demo_bucket" {
  bucket = "demo-bucket-policy-as-code-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name        = "Demo Bucket"
    Environment = "Development"
  }
}

# Non-compliant Security Group - OPEN SSH
resource "aws_security_group" "demo_sg" {
  name        = "demo-security-group"
  description = "Demo security group"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # VIOLATION!
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Demo SG"
  }
}

# Non-compliant RDS - NO ENCRYPTION
resource "aws_db_instance" "demo_db" {
  identifier          = "demo-database"
  allocated_storage   = 20
  engine              = "mysql"
  engine_version      = "8.0"
  instance_class      = "db.t3.micro"
  username            = "admin"
  password            = "ChangeMe123!" # Just for demo
  skip_final_snapshot = true

  # storage_encrypted = false  # VIOLATION!

  tags = {
    Name = "Demo Database"
  }
}

# Non-compliant IAM Policy - TOO PERMISSIVE
resource "aws_iam_policy" "demo_policy" {
  name        = "demo-overly-permissive"
  description = "Demo policy with excessive permissions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "*" # VIOLATION!
        Resource = "*" # VIOLATION!
      }
    ]
  })
}

# Data source for account ID
data "aws_caller_identity" "current" {}
