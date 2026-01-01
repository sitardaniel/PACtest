# Provider configuration
provider "aws" {
  region = "us-east-1"
}

# Compliant S3 bucket - WITH ENCRYPTION
resource "aws_s3_bucket" "demo_bucket" {
  bucket = "demo-bucket-policy-as-code-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name        = "Demo Bucket"
    Environment = "Development"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "demo_bucket_encryption" {
  bucket = aws_s3_bucket.demo_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Compliant Security Group - RESTRICTED ACCESS
resource "aws_security_group" "demo_sg" {
  name        = "demo-security-group"
  description = "Demo security group with restricted access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"] # Restricted to internal network
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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

# Compliant RDS - WITH ENCRYPTION
resource "aws_db_instance" "demo_db" {
  identifier          = "demo-database"
  allocated_storage   = 20
  engine              = "mysql"
  engine_version      = "8.0"
  instance_class      = "db.t3.micro"
  username            = "admin"
  password            = "ChangeMe123!"
  skip_final_snapshot = true
  storage_encrypted   = true # COMPLIANT!

  tags = {
    Name = "Demo Database"
  }
}

# Compliant IAM Policy - LEAST PRIVILEGE
resource "aws_iam_policy" "demo_policy" {
  name        = "demo-least-privilege"
  description = "Demo policy with least privilege"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "arn:aws:s3:::specific-bucket/*"
      }
    ]
  })
}

# Data source for account ID
data "aws_caller_identity" "current" {}
