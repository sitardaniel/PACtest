# 🚀 Policy as Code Demo - Complete Guide

**Author:** Claude Code  
**Date:** December 27, 2025  
**Version:** 1.0 - Final  

---

## 📋 Table of Contents

1. [Introduction](#introduction)
2. [Architecture Overview](#architecture-overview)
3. [Demo 1: Prevention with OPA](#demo-1-prevention-with-opa)
4. [Demo 2: Detection with AWS Config](#demo-2-detection-with-aws-config)
5. [Setup Instructions](#setup-instructions)
6. [Running the Demos](#running-the-demos)
7. [Troubleshooting](#troubleshooting)
8. [GitHub Repository Structure](#github-repository-structure)

---

## 1. Introduction

### What is Policy as Code?

Policy as Code is the practice of defining security policies, compliance requirements, and governance rules as code. This approach enables:

- **Automated enforcement** - No manual reviews required
- **Version control** - Track policy changes over time
- **Testing** - Validate policies before deployment
- **Consistency** - Same rules applied everywhere
- **Audit trail** - Complete history of policy decisions

### The Two-Phase Approach

This demo implements comprehensive security automation through two complementary phases:

#### **Phase 1: Prevention (Demo 1)**
- **Tool:** Open Policy Agent (OPA)
- **When:** Before deployment (CI/CD pipeline)
- **Purpose:** Block insecure infrastructure from being deployed
- **Result:** Violations caught in seconds, nothing reaches AWS

#### **Phase 2: Detection (Demo 2)**
- **Tool:** AWS Config + EventBridge
- **When:** After deployment (continuous monitoring)
- **Purpose:** Detect manual configuration changes (drift)
- **Result:** Email alerts within 60 seconds of violations

---

## 2. Architecture Overview

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Development Phase                         │
│                                                              │
│  Developer → Terraform Code → Git → CI/CD Pipeline          │
│                                        │                     │
│                                        ▼                     │
│                                     ┌──────┐                │
│                                     │ OPA  │                │
│                                     │ Test │                │
│                                     └──┬───┘                │
│                                        │                     │
│                            ┌───────────┴──────────┐         │
│                            │                      │         │
│                         ✅ Pass                ❌ Fail       │
│                            │                      │         │
│                            ▼                      ▼         │
│                       Deploy to AWS          Block & Alert  │
└────────────────────────────┬────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────┐
│                    Production Phase                          │
│                                                              │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐                 │
│  │ S3       │  │ Security │  │ RDS      │                 │
│  │ Buckets  │  │ Groups   │  │ Database │                 │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘                 │
│       │             │              │                        │
│       └─────────────┴──────────────┘                        │
│                     │                                       │
│              ┌──────▼──────┐                                │
│              │ AWS Config  │  (Monitors 24/7)               │
│              └──────┬──────┘                                │
│                     │                                       │
│         ┌───────────┴──────────────┐                        │
│         │                          │                        │
│    ┌────▼────┐              ┌──────▼──────┐                │
│    │ Config  │              │ S3 Bucket   │                │
│    │ Rules   │              │ (Audit Logs)│                │
│    └────┬────┘              └─────────────┘                │
│         │                                                   │
│         │ Compliance Change                                │
│         │                                                   │
│    ┌────▼────────┐                                          │
│    │ EventBridge │                                          │
│    │    Rule     │                                          │
│    └────┬────────┘                                          │
│         │                                                   │
│         ▼                                                   │
│    ┌────────────┐                                           │
│    │ SNS Topic  │                                           │
│    └────┬───────┘                                           │
│         │                                                   │
└─────────┼───────────────────────────────────────────────────┘
          │
          ▼
     📧 Security Team Email
```

### Components

#### **OPA (Open Policy Agent)**
- Policy engine for pre-deployment validation
- Uses Rego language to define policies
- Evaluates Terraform plans before execution
- Version: 1.12.1

#### **AWS Config**
- Continuous compliance monitoring service
- Records resource configurations
- Evaluates against compliance rules
- Stores audit logs in S3

#### **EventBridge**
- Event-driven automation service
- Catches compliance state changes
- Routes events to SNS for alerting

#### **SNS (Simple Notification Service)**
- Messaging service for alerts
- Sends emails when compliance changes
- Configurable for multiple notification channels

---

## 3. Demo 1: Prevention with OPA

### Overview

Demo 1 shows how OPA validates Terraform infrastructure code **before** it's deployed to AWS, catching security violations in the CI/CD pipeline.

### Policies Enforced

#### **1. S3 Bucket Encryption**
**Policy File:** `policies/s3_encryption.rego`

**Rule:** All S3 buckets must have server-side encryption enabled

**Why it matters:**
- Protects data at rest
- Required for PCI-DSS, HIPAA, SOC2 compliance
- Prevents data breaches from stolen storage

**Example Violation:**
```hcl
resource "aws_s3_bucket" "demo" {
  bucket = "my-bucket"
  # ❌ Missing encryption configuration
}
```

**Compliant Code:**
```hcl
resource "aws_s3_bucket" "demo" {
  bucket = "my-bucket"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "demo" {
  bucket = aws_s3_bucket.demo.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
```

#### **2. Restricted SSH Access**
**Policy File:** `policies/security_groups.rego`

**Rule:** Security groups must NOT allow SSH (port 22) from 0.0.0.0/0

**Why it matters:**
- Prevents brute force attacks
- Blocks unauthorized remote access
- CIS AWS Foundations Benchmark requirement

**Example Violation:**
```hcl
resource "aws_security_group" "demo" {
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # ❌ Open to internet
  }
}
```

**Compliant Code:**
```hcl
resource "aws_security_group" "demo" {
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]  # ✅ Restricted to internal
  }
}
```

#### **3. RDS Encryption**
**Policy File:** `policies/rds_encryption.rego`

**Rule:** All RDS instances must have storage encryption enabled

**Why it matters:**
- Protects sensitive data at rest
- Required for GDPR, HIPAA compliance
- No performance impact

**Example Violation:**
```hcl
resource "aws_db_instance" "demo" {
  identifier        = "demo-db"
  engine            = "mysql"
  instance_class    = "db.t3.micro"
  storage_encrypted = false  # ❌ Not encrypted
}
```

**Compliant Code:**
```hcl
resource "aws_db_instance" "demo" {
  identifier        = "demo-db"
  engine            = "mysql"
  instance_class    = "db.t3.micro"
  storage_encrypted = true  # ✅ Encrypted
}
```

#### **4. IAM Least Privilege**
**Policy File:** `policies/iam_policies.rego`

**Rule:** IAM policies must NOT grant wildcard permissions (*:*)

**Why it matters:**
- Enforces principle of least privilege
- Prevents privilege escalation
- Reduces blast radius of compromised credentials

**Example Violation:**
```hcl
resource "aws_iam_policy" "demo" {
  policy = jsonencode({
    Statement = [{
      Effect   = "Allow"
      Action   = "*"           # ❌ All actions
      Resource = "*"           # ❌ All resources
    }]
  })
}
```

**Compliant Code:**
```hcl
resource "aws_iam_policy" "demo" {
  policy = jsonencode({
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:GetObject", "s3:PutObject"]  # ✅ Specific
      Resource = "arn:aws:s3:::specific-bucket/*"  # ✅ Specific
    }]
  })
}
```

### Demo Flow

#### **Part A: Show Violations (Non-Compliant)**

1. Switch to non-compliant Terraform configuration:
   ```bash
   cd /Users/sitargold/Projects/OPAtest/policy-as-code-demo
   cd terraform
   cp templates/main-noncompliant.tf main.tf
   cd ..
   ```

2. Run OPA validation:
   ```bash
   ./scripts/validate.sh
   ```

3. **Expected Output:**
   ```
   🔍 Running Policy as Code validation...
   
   Terraform used the selected providers to generate the following execution
   plan. Resource actions are indicated with the following symbols:
     + create
   
   📋 Evaluating against OPA policies...
   
   🔎 Checking for violations...
   ❌ POLICY VIOLATIONS FOUND (2):
   
     • S3 buckets must have encryption enabled: aws_s3_bucket.demo_bucket
     • Security group aws_security_group.demo_sg allows SSH from 0.0.0.0/0 on port 22
   ```

4. **What to say:**
   > "OPA caught TWO security violations:
   > 1. An S3 bucket without encryption - a common compliance issue
   > 2. A security group allowing SSH from the entire internet
   > 
   > The deployment FAILS here - nothing gets to AWS. The developer gets
   > immediate feedback in their CI/CD pipeline."

#### **Part B: Show Success (Compliant)**

1. Switch to compliant configuration:
   ```bash
   cd terraform
   cp templates/main-compliant.tf main.tf
   cd ..
   ```

2. Run validation again:
   ```bash
   ./scripts/validate.sh
   ```

3. **Expected Output:**
   ```
   🔍 Running Policy as Code validation...
   
   Terraform used the selected providers to generate the following execution
   plan. Resource actions are indicated with the following symbols:
     + create
   
   📋 Evaluating against OPA policies...
   
   🔎 Checking for violations...
   ✅ All policies passed!
   ```

4. **What to say:**
   > "All policies passed! The compliant infrastructure has:
   > - S3 buckets WITH encryption enabled
   > - Security groups restricting SSH to internal networks only
   > - RDS with encryption enabled
   > - IAM policies following least privilege
   > 
   > This code is now approved for deployment - completely automated!"

---

## 4. Demo 2: Detection with AWS Config

### Overview

Demo 2 demonstrates how AWS Config monitors deployed infrastructure and detects manual configuration changes (drift) in real-time.

### AWS Config Rules

#### **1. S3 Bucket Encryption Rule**
**Config Rule:** `s3-bucket-server-side-encryption-enabled`  
**AWS Managed Rule ID:** `S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED`  
**Resources Monitored:** AWS::S3::Bucket

**Checks:** Every S3 bucket has server-side encryption enabled

#### **2. Restricted SSH Rule**
**Config Rule:** `restricted-ssh`  
**AWS Managed Rule ID:** `INCOMING_SSH_DISABLED`  
**Resources Monitored:** AWS::EC2::SecurityGroup

**Checks:** No security group allows SSH (port 22) from 0.0.0.0/0

#### **3. RDS Encryption Rule**
**Config Rule:** `rds-storage-encrypted`  
**AWS Managed Rule ID:** `RDS_STORAGE_ENCRYPTED`  
**Resources Monitored:** AWS::RDS::DBInstance

**Checks:** All RDS instances have storage encryption enabled

### EventBridge Integration

**EventBridge Rule:** `config-compliance-change-alert`

**Event Pattern:**
```json
{
  "source": ["aws.config"],
  "detail-type": ["Config Rules Compliance Change"]
}
```

**What it does:**
- Listens for compliance state changes
- Triggers when a rule goes COMPLIANT → NON_COMPLIANT
- Triggers when a rule goes NON_COMPLIANT → COMPLIANT

**Input Transformer:**
Transforms raw Config events into readable email alerts:

```
"AWS Config Compliance Change Detected!"
"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
"Rule: <rule_name>"
"Status: <COMPLIANT|NON_COMPLIANT>"
"Resource Type: <resource_type>"
"Resource ID: <resource_id>"
"Time: <timestamp>"
```

### Demo Flow

#### **Part A: Show Compliant State**

1. Open AWS Config Console:
   ```
   https://console.aws.amazon.com/config/home?region=us-east-1#/rules
   ```

2. **What to show:**
   - All 3 rules showing "Compliant" (green checkmarks)
   - Number of resources evaluated

3. **What to say:**
   > "After deployment, AWS Config monitors our infrastructure 24/7.
   > Here you can see all our security policies showing compliant -
   > everything is secure."

#### **Part B: Simulate Drift (Create Violation)**

**Recommended Method: Create Security Group with Open SSH**

1. Go to EC2 Console:
   ```
   https://console.aws.amazon.com/ec2/home?region=us-east-1#SecurityGroups:
   ```

2. Click "Create security group"

3. Fill in:
   - **Name:** `demo-open-ssh`
   - **Description:** `Demo - insecure SSH access`
   - **VPC:** (leave default)

4. Add Inbound Rule:
   - **Type:** SSH
   - **Port:** 22 (auto-filled)
   - **Source:** Custom → **0.0.0.0/0**
   - **Description:** `Open SSH - BAD!`

5. Click "Create security group"

6. **What to say while creating:**
   > "I'm creating a security group that allows SSH access from the
   > entire internet - 0.0.0.0/0. This is a common mistake developers
   > make. Watch what happens..."

#### **Part C: Show Detection**

1. **Wait 30-90 seconds**

2. **While waiting, say:**
   > "AWS Config is now scanning all resources. Within 30-60 seconds
   > it will detect this violation and send an alert to the security team..."

3. **Open email** (YOUR_EMAIL@example.com)

4. **Wait for alert email:**
   ```
   "AWS Config Compliance Change Detected!"
   "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
   "Rule: restricted-ssh"
   "Status: NON_COMPLIANT"
   "Resource Type: AWS::EC2::SecurityGroup"
   "Resource ID: sg-xxxxxxxxxx"
   "Time: 2025-12-27T..."
   ```

5. **When email arrives, say:**
   > "There it is! The security team just received an alert showing:
   > - WHAT: Security group with open SSH
   > - WHEN: Exact timestamp
   > - WHERE: Specific resource ID
   > - WHICH POLICY: restricted-ssh rule violated"

6. **Go back to Config Console:**
   ```
   https://console.aws.amazon.com/config/home?region=us-east-1#/rules
   ```

7. **Show:**
   - Click on "restricted-ssh" rule
   - Shows "Noncompliant" with count
   - Click on the resource to see details

8. **What to say:**
   > "And here in the Config console, you can see the rule now shows
   > 'Noncompliant' with details about the violation."

#### **Part D: Cleanup**

Delete the test security group:
```bash
aws ec2 delete-security-group --group-id <GROUP_ID> --region us-east-1
```

**Bonus:** This will trigger another email showing compliance is restored!

---

## 5. Setup Instructions

### Prerequisites

- AWS Account with appropriate permissions
- AWS CLI configured
- Terraform installed (v1.5+)
- Git
- Terminal/Command Line access

### Step 1: Clone Repository

```bash
git clone <your-repo-url>
cd policy-as-code-demo
```

### Step 2: Download OPA

```bash
# For macOS (ARM64)
curl -L -o opa https://openpolicyagent.org/downloads/latest/opa_darwin_arm64
chmod +x opa

# For macOS (Intel)
curl -L -o opa https://openpolicyagent.org/downloads/latest/opa_darwin_amd64
chmod +x opa

# For Linux
curl -L -o opa https://openpolicyagent.org/downloads/latest/opa_linux_amd64
chmod +x opa
```

### Step 3: Test OPA Policies

```bash
./opa test policies/ -v
```

Expected output:
```
policies/iam_policies_test.rego:
  data.terraform.iam.test_deny_wildcard_permissions: PASS (0.5ms)
policies/rds_encryption_test.rego:
  data.terraform.rds.test_deny_unencrypted_rds: PASS (0.4ms)
policies/s3_encryption_test.rego:
  data.terraform.s3.test_deny_unencrypted_buckets: PASS (0.6ms)
policies/security_groups_test.rego:
  data.terraform.security_groups.test_deny_ssh_from_internet: PASS (0.5ms)
--------------------------------------------------------------------------------
PASS: 4/4
```

### Step 4: Configure AWS Credentials

```bash
aws configure

# Enter when prompted:
# AWS Access Key ID: YOUR_ACCESS_KEY
# AWS Secret Access Key: YOUR_SECRET_KEY
# Default region: us-east-1
# Default output format: json
```

### Step 5: Update Email Address

Edit `terraform/aws-config.tf` line 9:
```hcl
resource "aws_sns_topic_subscription" "config_email" {
  topic_arn = aws_sns_topic.config_alerts.arn
  protocol  = "email"
  endpoint  = "YOUR_EMAIL@example.com"  # CHANGE THIS
}
```

### Step 6: Deploy Infrastructure

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

**Note:** You'll need AWS permissions for:
- S3 (buckets and encryption)
- EC2 (security groups)
- RDS (database instances)
- IAM (roles and policies)
- Config (rules and recorder)
- EventBridge (rules)
- SNS (topics and subscriptions)

### Step 7: Confirm SNS Email Subscription

1. Check your email for "AWS Notification - Subscription Confirmation"
2. Click the "Confirm subscription" link
3. You'll see "Subscription confirmed!"

### Step 8: Wait for Initial Config Evaluation

AWS Config takes 5-10 minutes for initial resource evaluation.

Check status:
```bash
aws configservice describe-compliance-by-config-rule --region us-east-1
```

When ready, all rules should show `"ComplianceType": "COMPLIANT"`

---

## 6. Running the Demos

### Demo 1: OPA Validation

**Time:** 3-4 minutes

```bash
cd /Users/sitargold/Projects/OPAtest/policy-as-code-demo

# Show violations
cd terraform && cp templates/main-noncompliant.tf main.tf && cd ..
./scripts/validate.sh

# Show success
cd terraform && cp templates/main-compliant.tf main.tf && cd ..
./scripts/validate.sh
```

### Demo 2: AWS Config Drift Detection

**Time:** 3-4 minutes

**Via AWS Console (Recommended):**
1. Open: https://console.aws.amazon.com/config/home?region=us-east-1#/rules
2. Show compliant state
3. Create security group with open SSH
4. Wait for email alert
5. Show non-compliant in Config console

**Via CLI (Faster):**
```bash
# Create security group with open SSH
SG_ID=$(aws ec2 create-security-group \
  --group-name demo-drift-$(date +%s) \
  --description "Demo drift detection" \
  --region us-east-1 \
  --query 'GroupId' \
  --output text)

aws ec2 authorize-security-group-ingress \
  --group-id $SG_ID \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0 \
  --region us-east-1

echo "✅ Check email in 30-60s! Group ID: $SG_ID"

# Cleanup after demo
aws ec2 delete-security-group --group-id $SG_ID --region us-east-1
```

---

## 7. Troubleshooting

### Demo 1 Issues

#### OPA validation fails with "exec format error"
**Cause:** Wrong OPA binary for your architecture

**Fix:**
```bash
# Check your architecture
uname -m

# Download correct version:
# arm64 (M1/M2/M3 Mac):
curl -L -o opa https://openpolicyagent.org/downloads/latest/opa_darwin_arm64

# amd64 (Intel Mac/Linux):
curl -L -o opa https://openpolicyagent.org/downloads/latest/opa_darwin_amd64

chmod +x opa
```

#### Validation shows "All policies passed" when violations exist
**Cause:** Wrong Terraform file or validation script issue

**Fix:**
```bash
# Verify which file is active
head terraform/main.tf

# Should show non-compliant config for Part A
# If not, re-copy:
cd terraform
cp templates/main-noncompliant.tf main.tf
cd ..
```

### Demo 2 Issues

#### Email alerts not arriving
**Cause:** SNS subscription not confirmed or EventBridge not configured

**Fix:**
```bash
# Check SNS subscription status
aws sns list-subscriptions-by-topic \
  --topic-arn arn:aws:sns:us-east-1:YOUR_ACCOUNT:config-compliance-alerts \
  --region us-east-1

# Should show:
# "SubscriptionArn": "arn:aws:sns:..." (not "PendingConfirmation")

# Check EventBridge rule exists
aws events describe-rule \
  --name config-compliance-change-alert \
  --region us-east-1
```

#### Config showing COMPLIANT even after creating violation
**Cause:** Config hasn't re-evaluated yet

**Fix:**
```bash
# Manually trigger evaluation
aws configservice start-config-rules-evaluation \
  --config-rule-names restricted-ssh \
  --region us-east-1

# Wait 30 seconds, then check
aws configservice describe-compliance-by-config-rule \
  --config-rule-names restricted-ssh \
  --region us-east-1
```

#### Getting too many notification emails
**Cause:** Receiving both Config delivery channel and EventBridge notifications

**Fix:** Already fixed in final version - SNS removed from delivery channel. You should only get compliance change alerts.

---

## 8. GitHub Repository Structure

```
policy-as-code-demo/
├── README.md                          # Main repository documentation
├── FINAL-COMPLETE-GUIDE.md           # This comprehensive guide
├── LICENSE                           # License file
│
├── policies/                         # OPA Policies
│   ├── s3_encryption.rego           # S3 encryption policy
│   ├── s3_encryption_test.rego      # S3 policy tests
│   ├── security_groups.rego         # Security group policy
│   ├── security_groups_test.rego    # Security group tests
│   ├── rds_encryption.rego          # RDS encryption policy
│   ├── rds_encryption_test.rego     # RDS policy tests
│   ├── iam_policies.rego            # IAM policy checks
│   └── iam_policies_test.rego       # IAM policy tests
│
├── terraform/                        # Terraform Infrastructure
│   ├── main.tf                       # Main infrastructure
│   ├── aws-config.tf                 # AWS Config setup
│   ├── providers.tf                  # Terraform providers
│   ├── templates/
│   │   ├── main-compliant.tf        # Compliant configuration
│   │   └── main-noncompliant.tf     # Non-compliant for testing
│   └── .gitignore                   # Terraform gitignore
│
├── scripts/                          # Automation Scripts
│   └── validate.sh                   # OPA validation script
│
├── .github/
│   └── workflows/
│       └── policy-validation.yml     # GitHub Actions CI/CD
│
└── docs/                             # Additional Documentation
    ├── DEMO-PRACTICE-GUIDE.md       # Practice guide for Demo 1
    ├── DEMO2-ARCHITECTURE-SETUP.md  # Architecture explanation
    ├── SHOW-SETUP-IN-CONSOLE.md     # AWS Console navigation
    ├── EMAIL-TYPES-EXPLAINED.md     # Email notifications guide
    ├── QUICK-COMMANDS.txt            # Quick reference for Demo 1
    └── DEMO2-QUICK-STEPS.txt         # Quick reference for Demo 2
```

---

## Appendix A: Key Talking Points

### Why Policy as Code Matters

**Shift-Left Security:**
- Catch issues in development, not production
- Fail fast, fix fast
- Security integrated into developer workflow

**Zero Trust for Infrastructure:**
- Verify continuously, never assume
- Every change validated
- No manual approvals needed

**Compliance Automation:**
- Meets SOC2, PCI-DSS, HIPAA requirements
- Audit trail in version control
- Automated evidence collection

**Developer Velocity:**
- No bottlenecks from manual security reviews
- Instant feedback on violations
- Self-service infrastructure deployment

### Business Impact

**Reduce Security Incidents:**
- 23% of cloud breaches are from misconfigurations
- Policy as Code prevents most common vulnerabilities
- Automated detection within 60 seconds

**Faster Deployments:**
- Automated gates vs. days of manual reviews
- Deploy with confidence
- Rollback quickly if needed

**Cost Savings:**
- Prevent security incidents (avg cost: $4.35M per breach)
- Reduce manual review overhead
- Optimize compliance processes

**Audit Trail:**
- Complete history in version control
- AWS Config timeline for investigations
- Regulatory compliance evidence

---

## Appendix B: AWS Resources Created

### S3 Buckets (2)
- `demo-bucket-policy-as-code-<ACCOUNT_ID>` - Demo bucket with encryption
- `aws-config-logs-<ACCOUNT_ID>` - Config audit logs

### Security Groups (1)
- `demo-security-group` - Restricted SSH access

### RDS Instance (1)
- `demo-database` - MySQL 8.0 with encryption

### IAM Resources (3)
- `aws-config-role` - IAM role for Config service
- `demo-least-privilege` - Example IAM policy
- Policy attachments and inline policies

### AWS Config Resources (7)
- Configuration recorder (`main-recorder`)
- Delivery channel (`main-channel`)
- Config rule: `s3-bucket-server-side-encryption-enabled`
- Config rule: `restricted-ssh`
- Config rule: `rds-storage-encrypted`
- Recorder status
- S3 bucket policy for Config

### EventBridge Resources (2)
- Event rule: `config-compliance-change-alert`
- Event target (SNS)

### SNS Resources (3)
- Topic: `config-compliance-alerts`
- Email subscription
- Topic policy

**Total Resources:** ~24 AWS resources

**Estimated Monthly Cost:** $30-50 (primarily RDS and Config)

---

## Appendix C: Additional Resources

### Documentation Links

**OPA:**
- Official Docs: https://www.openpolicyagent.org/docs/
- Rego Playground: https://play.openpolicyagent.org/
- Policy Language: https://www.openpolicyagent.org/docs/latest/policy-language/

**AWS Config:**
- Official Docs: https://docs.aws.amazon.com/config/
- Managed Rules: https://docs.aws.amazon.com/config/latest/developerguide/managed-rules-by-aws-config.html
- Best Practices: https://docs.aws.amazon.com/config/latest/developerguide/best-practices.html

**Terraform:**
- AWS Provider: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
- Best Practices: https://www.terraform.io/docs/cloud/guides/recommended-practices/

**EventBridge:**
- Event Patterns: https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-event-patterns.html
- Input Transformation: https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-transform-target-input.html

### Further Learning

**Books:**
- "Infrastructure as Code" by Kief Morris
- "Cloud Native Infrastructure" by Justin Garrison
- "Site Reliability Engineering" by Google

**Courses:**
- AWS Security Specialty Certification
- HashiCorp Terraform Associate
- Cloud Security Alliance CCSK

**Blogs & Articles:**
- AWS Security Blog: https://aws.amazon.com/blogs/security/
- HashiCorp Blog: https://www.hashicorp.com/blog
- OPA Blog: https://blog.openpolicyagent.org/

---

## Appendix D: FAQ

### Q: Can I use this in production?

**A:** Yes, but consider:
- Review and customize policies for your requirements
- Add more comprehensive test coverage
- Implement proper secret management
- Set up monitoring and alerting
- Follow AWS security best practices

### Q: How much does this cost?

**A:** Estimated monthly costs:
- AWS Config: ~$2 per rule + storage
- RDS: ~$15-25 (db.t3.micro)
- S3: Minimal (<$1)
- EventBridge: Free tier
- SNS: Free tier
- **Total: ~$30-50/month**

### Q: Can I add more policies?

**A:** Absolutely! To add a new policy:
1. Create `.rego` file in `policies/`
2. Create corresponding `_test.rego` file
3. Run: `./opa test policies/ -v`
4. Update `scripts/validate.sh` to check new policy

### Q: What if I don't have AWS permissions?

**A:** You can still:
- Run Demo 1 (OPA validation) - no AWS needed
- Practice with Terraform `plan` (doesn't deploy)
- Use LocalStack for local AWS simulation
- Present Demo 2 conceptually with screenshots

### Q: How do I customize email alerts?

**A:** Edit the EventBridge input transformer in `terraform/aws-config.tf`:
```hcl
input_transformer {
  input_paths = {
    # Add more fields here
  }
  input_template = <<EOF
    # Customize message format here
  EOF
}
```

### Q: Can this work with other cloud providers?

**A:** Yes:
- **Azure:** Use Azure Policy instead of Config
- **GCP:** Use Organization Policy Service
- **Multi-cloud:** Use Sentinel or Checkov

OPA works with any infrastructure tool (Terraform, CloudFormation, etc.)

---

## Conclusion

You now have a complete Policy as Code demonstration showing:

✅ **Prevention** with OPA - Block bad deployments  
✅ **Detection** with AWS Config - Catch drift in real-time  
✅ **Automation** end-to-end - No manual reviews  
✅ **Compliance** built-in - Meet regulatory requirements  

This approach provides comprehensive security coverage through automated policy enforcement before and after deployment.

**Key Takeaways:**
1. Security policies defined as code
2. Automated validation in CI/CD pipeline
3. Continuous compliance monitoring in production
4. Real-time alerts for violations
5. Complete audit trail for compliance

**Next Steps:**
1. Customize policies for your requirements
2. Integrate with your CI/CD pipeline
3. Expand to additional security checks
4. Train team on policy maintenance
5. Monitor and refine based on feedback

---

**Questions? Issues? Contributions?**

Please open an issue on GitHub or submit a pull request!

**License:** MIT

**Author:** Claude Code  
**Version:** 1.0 - Final  
**Last Updated:** December 27, 2025
