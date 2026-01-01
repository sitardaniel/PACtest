# 🏗️ Demo 2: How the AWS Config Rules Were Set Up

This guide shows you exactly how the drift detection system was configured.

---

## 📋 Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [AWS Config Rules Setup](#aws-config-rules-setup)
3. [EventBridge Setup](#eventbridge-setup)
4. [SNS Email Alerts Setup](#sns-email-alerts-setup)
5. [How to Show This in Your Demo](#how-to-show-this-in-your-demo)

---

## 🏛️ Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                    AWS Account                           │
│                                                          │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐             │
│  │ S3       │  │ Security │  │ RDS      │             │
│  │ Buckets  │  │ Groups   │  │ Database │             │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘             │
│       │             │              │                    │
│       └─────────────┴──────────────┘                    │
│                     │                                   │
│              ┌──────▼──────┐                            │
│              │ AWS Config  │                            │
│              │  Recorder   │  (Monitors all resources)  │
│              └──────┬──────┘                            │
│                     │                                   │
│         ┌───────────┴──────────────┐                    │
│         │                          │                    │
│    ┌────▼────┐              ┌──────▼──────┐            │
│    │ Config  │              │ Config      │            │
│    │ Rules   │              │ Delivery    │            │
│    │ (3)     │              │ Channel     │            │
│    └────┬────┘              └──────┬──────┘            │
│         │                          │                    │
│         │ Compliance Change        │ Config Data        │
│         │                          │                    │
│    ┌────▼────────┐           ┌─────▼──────┐            │
│    │ EventBridge │           │ S3 Bucket  │            │
│    │    Rule     │           │ (Logs)     │            │
│    └────┬────────┘           └────────────┘            │
│         │                                               │
│         │ Publish Alert                                │
│         │                                               │
│    ┌────▼────────┐                                      │
│    │ SNS Topic   │                                      │
│    └────┬────────┘                                      │
│         │                                               │
└─────────┼───────────────────────────────────────────────┘
          │
          ▼
     📧 Email: YOUR_EMAIL@example.com
```

---

## ⚙️ AWS Config Rules Setup

### File: `terraform/aws-config.tf`

### **Rule 1: S3 Bucket Encryption**

**What it checks:**
- All S3 buckets must have server-side encryption enabled

**Terraform Code:**
```hcl
resource "aws_config_config_rule" "s3_encryption" {
  name = "s3-bucket-server-side-encryption-enabled"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED"
  }

  depends_on = [aws_config_configuration_recorder.main]
}
```

**AWS Managed Rule:** `S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED`

**Why it matters:**
- Prevents data breaches from unencrypted storage
- Required for compliance (PCI-DSS, HIPAA, SOC2)

---

### **Rule 2: Restricted SSH Access**

**What it checks:**
- Security groups must NOT allow SSH (port 22) from 0.0.0.0/0 (internet)

**Terraform Code:**
```hcl
resource "aws_config_config_rule" "restricted_ssh" {
  name = "restricted-ssh"

  source {
    owner             = "AWS"
    source_identifier = "INCOMING_SSH_DISABLED"
  }

  depends_on = [aws_config_configuration_recorder.main]
}
```

**AWS Managed Rule:** `INCOMING_SSH_DISABLED`

**Why it matters:**
- Prevents unauthorized remote access
- Blocks common attack vector (brute force SSH)
- CIS AWS Foundations Benchmark requirement

---

### **Rule 3: RDS Encryption**

**What it checks:**
- All RDS database instances must have encryption at rest enabled

**Terraform Code:**
```hcl
resource "aws_config_config_rule" "rds_encryption" {
  name = "rds-storage-encrypted"

  source {
    owner             = "AWS"
    source_identifier = "RDS_STORAGE_ENCRYPTED"
  }

  depends_on = [aws_config_configuration_recorder.main]
}
```

**AWS Managed Rule:** `RDS_STORAGE_ENCRYPTED`

**Why it matters:**
- Protects sensitive data at rest
- Required for compliance (GDPR, HIPAA)

---

## 🔄 AWS Config Recorder Setup

**What it does:**
- Continuously monitors ALL AWS resources in the account
- Records configuration changes
- Evaluates resources against Config rules

**Terraform Code:**
```hcl
resource "aws_config_configuration_recorder" "main" {
  name     = "main-recorder"
  role_arn = aws_iam_role.config_role.arn

  recording_group {
    all_supported = true  # Monitor ALL resource types
  }
}

resource "aws_config_configuration_recorder_status" "main" {
  name       = aws_config_configuration_recorder.main.name
  is_enabled = true  # Start monitoring immediately

  depends_on = [aws_config_delivery_channel.main]
}
```

**Recording frequency:** Continuous (real-time detection)

---

## 📡 EventBridge Setup (The Key to Email Alerts!)

This is what makes the email alerts work!

### **EventBridge Rule:**

**What it does:**
- Listens for AWS Config compliance change events
- Triggers SNS notification when compliance status changes

**Terraform Code:**
```hcl
resource "aws_cloudwatch_event_rule" "config_compliance_change" {
  name        = "config-compliance-change-alert"
  description = "Capture AWS Config compliance changes"

  event_pattern = jsonencode({
    source      = ["aws.config"]
    detail-type = ["Config Rules Compliance Change"]
  })
}
```

**Event Pattern Explained:**
- `source`: `aws.config` - Only Config events
- `detail-type`: `Config Rules Compliance Change` - Only compliance changes

### **EventBridge Target:**

**What it does:**
- Routes compliance change events to SNS topic
- Formats the message for email alerts

**Terraform Code - Input Transformer:**
This transforms the raw Config event into a nice email message!

```hcl
input_transformer {
  input_paths = {
    rule        = "$.detail.configRuleName"
    compliance  = "$.detail.newEvaluationResult.complianceType"
    resource    = "$.detail.resourceType"
    resourceId  = "$.detail.resourceId"
    time        = "$.time"
  }
  input_template = <<EOF
"AWS Config Compliance Change Detected!"
"Rule: <rule>"
"Status: <compliance>"
"Resource Type: <resource>"
"Resource ID: <resourceId>"
"Time: <time>"
EOF
}
```

**Input Transformer Explained:**
- Extracts key fields from the Config event
- Formats them into a readable email message
- This creates the nice formatted alert you receive!

---

## 📧 SNS Email Alerts Setup

### **SNS Topic:**

**What it does:**
- Central notification hub
- Receives alerts from EventBridge
- Sends emails to subscribers

**Terraform Code:**
```hcl
resource "aws_sns_topic" "config_alerts" {
  name = "config-compliance-alerts"
}
```

### **Email Subscription:**

**Terraform Code:**
```hcl
resource "aws_sns_topic_subscription" "config_email" {
  topic_arn = aws_sns_topic.config_alerts.arn
  protocol  = "email"
  endpoint  = "YOUR_EMAIL@example.com"
}
```

### **SNS Topic Policy:**

**What it does:**
- Allows EventBridge to publish to SNS
- Allows Config to publish to SNS

**Terraform Code:**
```hcl
resource "aws_sns_topic_policy" "config_alerts_policy" {
  arn = aws_sns_topic.config_alerts.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowConfigToPublish"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.config_alerts.arn
      },
      {
        Sid    = "AllowEventBridgeToPublish"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.config_alerts.arn
      }
    ]
  })
}
```

---

## 🎬 How to Show This in Your Demo

### **Option 1: Show the Terraform Code**

```bash
# Show the Config rules setup
cat terraform/aws-config.tf | grep -A 10 "resource \"aws_config_config_rule\""

# Show the EventBridge setup
cat terraform/aws-config.tf | grep -A 20 "resource \"aws_cloudwatch_event_rule\""
```

### **Option 2: Show in AWS Console**

**Show AWS Config Rules:**
1. Go to: https://console.aws.amazon.com/config/home?region=us-east-1#/rules
2. Click on each rule to show:
   - Rule name
   - What it checks
   - Compliance status
   - Resources being evaluated

**Show EventBridge Rule:**
1. Go to: https://console.aws.amazon.com/events/home?region=us-east-1#/rules
2. Click on: `config-compliance-change-alert`
3. Show:
   - Event pattern (what it listens for)
   - Target (SNS topic)
   - Input transformer (message formatting)

**Show SNS Topic:**
1. Go to: https://console.aws.amazon.com/sns/v3/home?region=us-east-1#/topics
2. Click on: `config-compliance-alerts`
3. Show:
   - Subscriptions (your email)
   - Access policy (who can publish)

### **Option 3: Show via CLI**

```bash
# List Config rules
aws configservice describe-config-rules --region us-east-1

# Show EventBridge rule
aws events describe-rule \
  --name config-compliance-change-alert \
  --region us-east-1

# Show SNS subscriptions
aws sns list-subscriptions-by-topic \
  --topic-arn arn:aws:sns:us-east-1:123456789012:config-compliance-alerts \
  --region us-east-1
```

---

## 📊 What to Emphasize in Your Demo

### **Key Points:**

1. **AWS Managed Rules** - No custom code needed
   > "We're using AWS's pre-built rules that are maintained by AWS security experts"

2. **EventBridge Integration** - The secret sauce
   > "EventBridge catches compliance changes in real-time and triggers alerts"

3. **Automated Detection** - No manual checking
   > "This runs 24/7, checking every resource against our policies"

4. **Immediate Alerts** - Fast response
   > "Security team gets notified within 60 seconds of any violation"

5. **Infrastructure as Code** - Repeatable
   > "This entire setup is defined in Terraform - we can deploy it to any AWS account"

---

## 🎯 Demo Talking Points

**When showing the architecture:**
> "Here's how it all fits together:
> 1. AWS Config continuously monitors our resources
> 2. It evaluates them against our security rules
> 3. When compliance changes, EventBridge catches it
> 4. SNS sends an email alert to the security team
> 5. All of this happens automatically in under 60 seconds"

**When showing the Terraform code:**
> "All of this is defined as code - we can version control it,
> review it in pull requests, and deploy it consistently across
> multiple AWS accounts"

---

## 📁 Files to Reference

**Main Config File:**
```
terraform/aws-config.tf
```

**To view the complete setup:**
```bash
cat /Users/sitargold/Projects/OPAtest/policy-as-code-demo/terraform/aws-config.tf
```

---

## ✅ What Was Deployed

- ✅ 3 AWS Config Rules (S3, SSH, RDS)
- ✅ 1 Config Recorder (monitoring all resources)
- ✅ 1 EventBridge Rule (catching compliance changes)
- ✅ 1 SNS Topic (sending alerts)
- ✅ 1 Email Subscription (YOUR_EMAIL@example.com)
- ✅ IAM Roles & Policies (permissions)
- ✅ S3 Bucket (Config logs)

**Total Resources:** 24 AWS resources deployed via Terraform

---

## 🎉 You're Ready to Explain the Architecture!

You now understand exactly how the drift detection system works and can confidently explain it in your demo!
