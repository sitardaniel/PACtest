# 🎬 Demo 2: AWS Config Drift Detection (Conceptual Guide)

## Overview

Since the OPATEST user has limited AWS permissions, this guide shows you how to **explain and demonstrate** Demo 2 conceptually without actually deploying to AWS. This is actually perfect for presentations!

---

## 🎯 Why This Approach is Better for Presentations

✅ **No AWS costs** - Free to demonstrate
✅ **Faster** - No waiting for resources to deploy
✅ **Repeatable** - Can show it multiple times
✅ **No cleanup** - Nothing to tear down
✅ **Focus on concepts** - Not technical issues

---

## 🎬 Demo 2 Presentation Flow (3-4 minutes)

### **Setup: Show the Code**

Start by showing what would be deployed:

```bash
# From your terminal
cd /Users/sitargold/Projects/OPAtest/policy-as-code-demo
cat terraform/aws-config.tf
```

**What to say:**
> "After OPA validates our infrastructure, we deploy it to AWS. But what happens
> if someone makes a manual change later? That's where AWS Config comes in."

---

### **Part 1: Explain the Architecture** (45 seconds)

Show the terraform files and explain:

```bash
# Show what gets deployed
ls terraform/
```

**Point out these files:**
- `main.tf` - The infrastructure (S3, Security Groups, RDS, etc.)
- `aws-config.tf` - AWS Config monitoring setup

**What to say:**
> "Once deployed, we have:
> - Our infrastructure: S3 buckets, security groups, databases
> - AWS Config: Continuously monitors all resources 24/7
> - Config Rules: Same policies as OPA, but checking LIVE infrastructure
> - SNS Alerts: Sends emails when drift is detected"

---

### **Part 2: Show Compliant State** (30 seconds)

Open a browser and show the AWS Config dashboard concept.

**If you have access to AWS Console (read-only):**
1. Go to https://console.aws.amazon.com/config/
2. Log in
3. Show the Config Dashboard (even if empty)

**If no access, use screenshots or explain:**

**What to say:**
> "In the AWS Config dashboard, you'd see all resources marked as COMPLIANT.
> Everything is secure and follows our policies."

**Show this visual:**
```
AWS Config Dashboard
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Resource Type          Compliance
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
S3 Buckets             ✅ COMPLIANT
Security Groups        ✅ COMPLIANT
RDS Instances          ✅ COMPLIANT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

### **Part 3: Simulate Manual Change** (60 seconds)

This is the key part - simulate what would happen.

**Show the AWS S3 Console (or describe it):**

**What to say:**
> "Now imagine a developer has production access and makes a 'quick fix'.
> Let me show you what happens..."

**Walk through the steps (don't actually do it, just describe):**

1. "They go to AWS Console → S3"
2. "Select the demo bucket"
3. "Click Properties → Default Encryption"
4. "Click Edit"
5. "Select **Disable** encryption"  ⚠️
6. "Click Save"

**What to say:**
> "Maybe they thought they were in dev, or just testing something.
> Within 30-60 seconds, AWS Config detects this change."

---

### **Part 4: Show Detection** (90 seconds)

**Show what happens next:**

#### **1. Config Dashboard Updates**

```
AWS Config Dashboard
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Resource Type          Compliance
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
S3 Buckets             ❌ NON_COMPLIANT
Security Groups        ✅ COMPLIANT
RDS Instances          ✅ COMPLIANT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠️ Rule Violation Detected:
   - Resource: demo-bucket-policy-as-code
   - Rule: s3-bucket-server-side-encryption-enabled
   - Status: NON_COMPLIANT
   - Time: 2025-12-27 13:45:32 UTC
```

**What to say:**
> "Config immediately detects the violation and marks it as NON_COMPLIANT."

#### **2. SNS Email Alert Sent**

Show or describe the email that would arrive:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
From: AWS Config <no-reply@sns.amazonaws.com>
To: security-team@company.com
Subject: AWS Config Compliance Change Detected
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

AWS Config detected a compliance change:

Account: 123456789012
Region: us-east-1
Rule: s3-bucket-server-side-encryption-enabled

Resource Details:
- Type: S3 Bucket
- Name: demo-bucket-policy-as-code
- Status: NON_COMPLIANT

Time: 2025-12-27 13:45:32 UTC

View in Console:
https://console.aws.amazon.com/config/...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**What to say:**
> "The security team gets an immediate email alert. They can:
> - Investigate who made the change
> - See the complete timeline
> - Remediate automatically or manually
> - Track it for compliance audits"

#### **3. Config Timeline**

Show the timeline view:

```
Configuration Timeline for demo-bucket
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

13:45:32 UTC  ❌ Encryption Disabled
              └─ User: john.doe@company.com
              └─ Source: AWS Console

13:30:15 UTC  ✅ Bucket Created (Compliant)
              └─ User: Terraform (CI/CD)
              └─ Encryption: AES256 Enabled

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**What to say:**
> "Config maintains a complete audit trail. We can see:
> - WHAT changed (encryption disabled)
> - WHO changed it (john.doe)
> - WHEN it happened (exact timestamp)
> - HOW it was changed (AWS Console, not Terraform)"

---

## 🎤 Key Talking Points for Demo 2

### **The Problem:**
- OPA prevents bad deployments, but what about manual changes?
- Configuration drift is a major security risk
- Traditional monitoring is reactive, not proactive

### **The Solution:**
- AWS Config monitors 24/7
- Detects changes within 30-60 seconds
- Automatic alerts to security team
- Complete audit trail for compliance

### **The Impact:**
- Detect unauthorized changes immediately
- Reduce mean time to detection (MTTD) from days to seconds
- Automatic compliance reporting
- Integration with remediation workflows

---

## 📊 Visual Aids You Can Use

### **Architecture Diagram** (Draw or Show)

```
┌─────────────────────────────────────────────────┐
│                                                 │
│  Developer    Terraform     OPA                 │
│  Makes Code → Plan      →  Validates            │
│  Change                     (Demo 1)            │
│                                ↓                │
│                             ✅ Pass              │
│                                ↓                │
└────────────────────────┬────────────────────────┘
                         │
                         ↓ Deploy

┌─────────────────────────────────────────────────┐
│                  AWS Cloud                      │
│                                                 │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐     │
│  │ S3       │  │ Security │  │ RDS      │     │
│  │ Buckets  │  │ Groups   │  │ Database │     │
│  └──────────┘  └──────────┘  └──────────┘     │
│         ↑            ↑            ↑            │
│         └────────────┴────────────┘            │
│                      │                         │
│              ┌───────▼────────┐                │
│              │  AWS Config    │                │
│              │  (Monitoring)  │                │
│              └───────┬────────┘                │
│                      │                         │
│                      ↓ Detects Change          │
│              ┌───────────────┐                 │
│              │  SNS Alert    │                 │
│              └───────┬───────┘                 │
└──────────────────────┼─────────────────────────┘
                       │
                       ↓
              📧 security-team@company.com
```

---

## 🎯 Complete Demo 2 Script

### **Opening:**
> "We've seen how OPA prevents bad infrastructure from being deployed.
> But what happens AFTER deployment? Let me show you..."

### **Show the monitoring setup:**
```bash
cat terraform/aws-config.tf | grep -A 3 "resource"
```

> "This Terraform code sets up AWS Config to monitor our infrastructure 24/7."

### **Explain compliant state:**
> "After deployment, everything shows as compliant in the Config dashboard.
> All our resources meet the security requirements."

### **Simulate the drift:**
> "Now imagine someone goes into the AWS Console and disables S3 encryption.
> Maybe they thought they were in dev, or just testing something.
> Watch what happens..."

### **Show detection:**
> "Within 30-60 seconds:
> 1. Config detects the change
> 2. Dashboard shows NON_COMPLIANT
> 3. Email alert sent to security team
> 4. Complete timeline captured for audit"

### **Closing:**
> "This is the two-phase approach:
> - Demo 1: OPA PREVENTS issues before deployment
> - Demo 2: Config DETECTS issues after deployment
>
> Together, they make AWS secure by default!"

---

## 🎨 Alternative: Show Real Screenshots

If you want to make it more visual, you can:

1. **Take screenshots from AWS docs:**
   - AWS Config Dashboard: https://docs.aws.amazon.com/config/
   - Example compliance reports
   - SNS notification examples

2. **Create mockups:**
   - Use any screenshot tool to show "what it would look like"
   - Draw simple diagrams

3. **Use AWS documentation:**
   - https://aws.amazon.com/config/
   - Show official AWS screenshots

---

## 💡 Pro Tips for Presenting Without Live Demo

### **Build Credibility:**
> "In a live environment, this would take about 60 seconds to detect.
> For this presentation, let me walk you through what happens..."

### **Use Your Demo 1 Success:**
> "You just saw OPA working live in Demo 1. Demo 2 is the same concept,
> but monitoring production instead of pre-deployment."

### **Focus on the Value:**
- Don't apologize for not having a live demo
- Emphasize the CONCEPT, not the technical execution
- Use the time saved to dive deeper into the policies

---

## ✅ What You've Already Demonstrated

Remember, you've ALREADY shown:
- ✅ Live OPA validation (Demo 1)
- ✅ Real policy violations caught
- ✅ Actual Terraform plans evaluated
- ✅ Working security automation

Demo 2 is just **extending the same concept** to production monitoring!

---

## 🎯 Recommended Presentation Flow

**Total Time: ~10 minutes**

1. **Demo 1 (Live)**: 4 minutes
   - Show OPA catching violations
   - Show compliant code passing

2. **Explain Demo 2 (Conceptual)**: 3 minutes
   - Show aws-config.tf file
   - Walk through drift detection flow
   - Show email alert example

3. **Wrap-up**: 2 minutes
   - Two-phase approach
   - Prevention + Detection
   - Q&A

4. **Bonus (if time)**: 1 minute
   - Show actual policy code
   - Explain how to customize

---

## 📞 If Asked "Can You Show This Live?"

**Honest answer:**
> "The demo environment has limited AWS permissions for security.
> However, I can show you the code and walk through exactly how it works.
> In a production environment, this takes about 15 minutes to set up
> and runs automatically from there."

**Then pivot to strengths:**
> "What I CAN show you live is Demo 1 - OPA validation - which is actually
> the more critical piece since it prevents issues before they reach AWS."

---

## 🚀 You're Still Ready!

Demo 2 doesn't need to be live to be effective. Focus on:
- ✅ Clear explanation of the concept
- ✅ Visual aids (code, diagrams, screenshots)
- ✅ Strong Demo 1 (which IS live)
- ✅ Confidence in the approach

Your audience will understand the value even without live AWS deployment!

---

## 📝 Quick Reference Commands

```bash
# Show AWS Config setup
cat terraform/aws-config.tf

# Show what would be deployed
terraform plan

# Show the policies
ls policies/

# Show email configuration
grep -n "endpoint" terraform/aws-config.tf
```

---

**You've got this!** The conceptual approach is often BETTER than live demos
because it focuses on value, not technical issues. 🎉
