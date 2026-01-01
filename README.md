# 🚀 Policy as Code Demo

**Comprehensive demonstration of security automation using OPA and AWS Config**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Terraform](https://img.shields.io/badge/Terraform-1.5%2B-blue)](https://www.terraform.io/)
[![OPA](https://img.shields.io/badge/OPA-0.60%2B-green)](https://www.openpolicyagent.org/)

---

## 📖 Overview

This repository demonstrates a complete **Policy as Code** implementation using:

- **OPA (Open Policy Agent)** for pre-deployment validation
- **AWS Config** for post-deployment drift detection
- **EventBridge** for real-time compliance alerts
- **Terraform** for infrastructure as code

### Two-Phase Security Approach

| Phase | Tool | When | Purpose |
|-------|------|------|---------|
| **Prevention** | OPA | Before deployment | Block insecure infrastructure |
| **Detection** | AWS Config | After deployment | Catch configuration drift |

---

## ✨ Features

- ✅ **4 Security Policies** - S3 encryption, SSH restrictions, RDS encryption, IAM least privilege
- ✅ **Automated Validation** - OPA checks Terraform before deployment
- ✅ **Real-time Monitoring** - AWS Config tracks all resources 24/7
- ✅ **Email Alerts** - Instant notifications for compliance violations
- ✅ **Complete Documentation** - Guides, scripts, and presentation materials
- ✅ **CI/CD Integration** - GitHub Actions workflow included
- ✅ **Production Ready** - Tested and documented

---

## 🎬 Demo Videos

### Demo 1: OPA Pre-Deployment Validation (3 min)
Shows how OPA catches security violations **before** deployment

### Demo 2: AWS Config Drift Detection (3 min)
Shows how AWS Config detects manual changes **after** deployment

---

## 🚀 Quick Start

### Prerequisites

- AWS Account with appropriate permissions
- [Terraform](https://www.terraform.io/downloads) 1.5+
- [AWS CLI](https://aws.amazon.com/cli/) configured
- Git

### Installation

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/policy-as-code-demo.git
cd policy-as-code-demo

# Download OPA
curl -L -o opa https://openpolicyagent.org/downloads/latest/opa_darwin_arm64
chmod +x opa

# Test OPA policies
./opa test policies/ -v

# Configure AWS credentials
aws configure

# Deploy infrastructure
cd terraform
terraform init
terraform plan
terraform apply
```

### Running Demo 1 (OPA Validation)

```bash
# Show violations (non-compliant)
cd terraform && cp templates/main-noncompliant.tf main.tf && cd ..
./scripts/validate.sh

# Show success (compliant)
cd terraform && cp templates/main-compliant.tf main.tf && cd ..
./scripts/validate.sh
```

### Running Demo 2 (AWS Config Drift Detection)

```bash
# Create non-compliant security group
aws ec2 create-security-group \
  --group-name demo-drift \
  --description "Demo" \
  --region us-east-1

# Add open SSH rule (triggers alert)
aws ec2 authorize-security-group-ingress \
  --group-id <GROUP_ID> \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0 \
  --region us-east-1

# Check your email for compliance alert!
```

---

## 📚 Documentation

### Main Guides

- **[Complete Guide](FINAL-COMPLETE-GUIDE.md)** - Comprehensive documentation (100+ pages)
- **[Setup Instructions](SETUP-STATUS.md)** - Step-by-step setup guide
- **[Demo Practice Guide](docs/DEMO-PRACTICE-GUIDE.md)** - How to run the demos

### Quick References

- **[Quick Commands](docs/QUICK-COMMANDS.txt)** - Demo 1 cheat sheet
- **[Demo 2 Quick Steps](docs/DEMO2-QUICK-STEPS.txt)** - Demo 2 cheat sheet

### Architecture & Setup

- **[Architecture Overview](docs/DEMO2-ARCHITECTURE-SETUP.md)** - System design explanation
- **[Console Navigation](docs/SHOW-SETUP-IN-CONSOLE.md)** - AWS Console guide
- **[Email Alerts](docs/EMAIL-TYPES-EXPLAINED.md)** - Understanding notifications

### Presentation Materials

- **[Complete Demo Script](docs/COMPLETE-DEMO-SCRIPT.md)** - Full presentation flow
- **[Demo 2 Manual Trigger](docs/DEMO2-LIVE-MANUAL-TRIGGER.md)** - How to trigger drift

---

## 🏗️ Repository Structure

```
policy-as-code-demo/
├── README.md                     # This file
├── FINAL-COMPLETE-GUIDE.md      # Comprehensive guide
├── LICENSE                       # MIT License
│
├── policies/                     # OPA Policies (Rego)
│   ├── s3_encryption.rego       # S3 bucket encryption
│   ├── security_groups.rego     # SSH restriction
│   ├── rds_encryption.rego      # RDS encryption
│   └── iam_policies.rego        # IAM least privilege
│
├── terraform/                    # Terraform Infrastructure
│   ├── main.tf                   # Main infrastructure
│   ├── aws-config.tf             # AWS Config setup
│   └── templates/
│       ├── main-compliant.tf     # Compliant config
│       └── main-noncompliant.tf  # Non-compliant (for demo)
│
├── scripts/                      # Automation Scripts
│   └── validate.sh               # OPA validation
│
├── .github/workflows/            # CI/CD
│   └── policy-validation.yml     # GitHub Actions
│
└── docs/                         # Additional Documentation
    ├── DEMO-PRACTICE-GUIDE.md
    ├── DEMO2-ARCHITECTURE-SETUP.md
    ├── SHOW-SETUP-IN-CONSOLE.md
    └── ... (10+ guides)
```

---

## 🔒 Security Policies

### 1. S3 Bucket Encryption
**Policy:** `policies/s3_encryption.rego`
**Rule:** All S3 buckets must have server-side encryption enabled
**Compliance:** PCI-DSS, HIPAA, SOC2

### 2. Restricted SSH Access
**Policy:** `policies/security_groups.rego`
**Rule:** Security groups must NOT allow SSH (port 22) from 0.0.0.0/0
**Compliance:** CIS AWS Foundations Benchmark

### 3. RDS Encryption
**Policy:** `policies/rds_encryption.rego`
**Rule:** All RDS instances must have storage encryption enabled
**Compliance:** GDPR, HIPAA

### 4. IAM Least Privilege
**Policy:** `policies/iam_policies.rego`
**Rule:** IAM policies must NOT grant wildcard permissions (*:*)
**Compliance:** AWS Best Practices

---

## 🧪 Testing

### Test OPA Policies

```bash
./opa test policies/ -v
```

Expected output:
```
PASS: 4/4
```

### Test Terraform

```bash
cd terraform
terraform fmt -check -recursive
terraform validate
```

### Run CI/CD Pipeline

The GitHub Actions workflow automatically:
- Tests all OPA policies
- Validates Terraform configuration
- Checks code formatting

---

## 💰 Cost Estimate

**Monthly AWS Costs:**
- AWS Config: ~$2 per rule ($6 total)
- RDS db.t3.micro: ~$15-25
- S3 Storage: <$1
- EventBridge: Free tier
- SNS: Free tier

**Total: ~$30-50/month**

---

## 🛠️ Customization

### Add New Policy

1. Create `policies/your_policy.rego`
2. Create `policies/your_policy_test.rego`
3. Run: `./opa test policies/ -v`
4. Update `scripts/validate.sh`

### Change Email Address

Edit `terraform/aws-config.tf` line 9:
```hcl
endpoint  = "your-email@example.com"
```

### Add More AWS Resources

Edit `terraform/main.tf` and add your resources following the compliant patterns.

---

## 📊 Use Cases

- **DevOps Teams** - Automate security checks in CI/CD
- **Security Teams** - Monitor infrastructure compliance
- **Compliance Teams** - Generate audit reports
- **Cloud Architects** - Enforce governance policies
- **Presentations** - Demonstrate Policy as Code

---

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-policy`)
3. Commit your changes (`git commit -m 'Add amazing policy'`)
4. Push to the branch (`git push origin feature/amazing-policy`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- [Open Policy Agent](https://www.openpolicyagent.org/) - Policy engine
- [HashiCorp Terraform](https://www.terraform.io/) - Infrastructure as Code
- [AWS Config](https://aws.amazon.com/config/) - Compliance monitoring
- [AWS EventBridge](https://aws.amazon.com/eventbridge/) - Event-driven automation

---

## 📞 Support

- **Documentation:** See [FINAL-COMPLETE-GUIDE.md](FINAL-COMPLETE-GUIDE.md)
- **Issues:** [GitHub Issues](https://github.com/YOUR_USERNAME/policy-as-code-demo/issues)
- **Discussions:** [GitHub Discussions](https://github.com/YOUR_USERNAME/policy-as-code-demo/discussions)

---

## 🎯 What's Included

- ✅ Complete working demos (tested)
- ✅ Production-ready Terraform code
- ✅ 4 security policies with tests
- ✅ AWS Config drift detection
- ✅ Email alert integration
- ✅ GitHub Actions CI/CD
- ✅ Comprehensive documentation (100+ pages)
- ✅ Presentation materials
- ✅ Quick reference guides
- ✅ Troubleshooting guides

---

## 🚀 Next Steps

1. **Run the demos** - Try both Demo 1 and Demo 2
2. **Customize policies** - Add your own security rules
3. **Integrate with CI/CD** - Add to your pipeline
4. **Present to team** - Use provided materials
5. **Deploy to production** - Follow setup guide

---

**Made with ❤️ for the DevSecOps community**

**Star ⭐ this repo if you find it useful!**
