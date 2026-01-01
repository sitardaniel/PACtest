# 🎬 Demo 1 Practice Guide - OPA Validation

## Quick Reference for Your Presentation

This is your one-page guide for running Demo 1 live!

---

## 🚀 Demo Flow (3-4 minutes total)

### Setup Before Demo Starts

Open Terminal and navigate to the project:
```bash
cd /Users/sitargold/Projects/OPAtest/policy-as-code-demo
```

**Optional:** Increase terminal font size for audience visibility:
- Press `Cmd + +` to zoom in

---

## Part A: Show Policy Violations (90 seconds)

### Step 1: Switch to Non-Compliant Configuration
```bash
cd terraform
cp templates/main-noncompliant.tf main.tf
cd ..
```

**What to say:**
> "First, let me show you what happens when developers try to deploy insecure infrastructure..."

### Step 2: Run OPA Validation
```bash
./scripts/validate.sh
```

**Wait for output** (takes ~10-20 seconds)

**What you'll see:**
```
🔍 Running Policy as Code validation...
[Terraform initialization...]
📋 Evaluating against OPA policies...
🔎 Checking for violations...
❌ POLICY VIOLATIONS FOUND (2):

  • S3 buckets must have encryption enabled: aws_s3_bucket.demo_bucket
  • Security group aws_security_group.demo_sg allows SSH from 0.0.0.0/0 on port 22
```

**What to say while it runs:**
> "OPA is analyzing the Terraform plan against our security policies..."

**When violations appear:**
> "As you can see, OPA caught TWO security violations:
> 1. An S3 bucket without encryption - a common compliance issue
> 2. A security group allowing SSH from the entire internet
>
> The pipeline FAILS here - nothing gets deployed to AWS.
> The developer gets immediate feedback in their CI/CD pipeline."

---

## Part B: Show Compliant Code (90 seconds)

### Step 3: Switch to Compliant Configuration
```bash
cd terraform
cp templates/main-compliant.tf main.tf
cd ..
```

**What to say:**
> "Now let's see what happens when we fix these security issues..."

### Step 4: Run OPA Validation Again
```bash
./scripts/validate.sh
```

**What you'll see:**
```
🔍 Running Policy as Code validation...
[Terraform initialization...]
📋 Evaluating against OPA policies...
🔎 Checking for violations...
✅ All policies passed!
```

**What to say while it runs:**
> "Same validation process, but this time with properly secured infrastructure..."

**When it passes:**
> "Perfect! All policies passed!
>
> The compliant infrastructure has:
> - S3 buckets WITH encryption enabled
> - Security groups that restrict SSH to internal networks only
> - RDS with encryption enabled
> - IAM policies following least privilege
>
> This code is now approved for deployment to AWS - completely automated!"

---

## 🎤 Key Talking Points

### Why This Matters:
- **Shift-Left Security** - Catch issues in development, not production
- **No Manual Reviews** - Automated, fast, consistent
- **Developer Friendly** - Clear error messages, immediate feedback
- **Prevents Misconfigurations** - 23% of cloud incidents are misconfigurations

### How It Works:
- OPA policies written in Rego (declarative language)
- Integrated into CI/CD pipeline (GitHub Actions)
- Validates Terraform plan BEFORE deployment
- Fails fast with specific error messages

### Business Impact:
- Faster deployments (no bottlenecks)
- Reduced security incidents
- Compliance automation
- Complete audit trail in version control

---

## ⚡ Quick Command Cheat Sheet

```bash
# Navigate to project
cd /Users/sitargold/Projects/OPAtest/policy-as-code-demo

# Show violations (non-compliant)
cd terraform && cp templates/main-noncompliant.tf main.tf && cd ..
./scripts/validate.sh

# Show success (compliant)
cd terraform && cp templates/main-compliant.tf main.tf && cd ..
./scripts/validate.sh
```

---

## 🎯 Demo Tips

### Before You Start:
1. Practice 2-3 times to get comfortable
2. Increase terminal font size (`Cmd + +`)
3. Close unnecessary windows/tabs
4. Have this guide open on another screen

### During the Demo:
1. **Speak slowly** - Let audience read the output
2. **Point with cursor** - Highlight important parts
3. **Pause after violations appear** - Give time to absorb
4. **Maintain eye contact** - Don't just read from screen
5. **Show enthusiasm** - This is cool stuff!

### If Something Goes Wrong:
- **Terminal hangs**: Press `Ctrl + C` and retry
- **Wrong output**: Double-check you're in the right directory
- **Script fails**: Show the policies in VS Code instead and explain

---

## 📊 What the Policies Check

You can mention what each policy does:

1. **S3 Encryption Policy** (`policies/s3_encryption.rego`)
   - Ensures all S3 buckets have server-side encryption enabled
   - Prevents data breaches from unencrypted storage

2. **Security Group Policy** (`policies/security_groups.rego`)
   - Blocks SSH (port 22) access from 0.0.0.0/0
   - Prevents unauthorized remote access

3. **RDS Encryption Policy** (`policies/rds_encryption.rego`)
   - Requires database encryption at rest
   - Protects sensitive data

4. **IAM Policy** (`policies/iam_policies.rego`)
   - Prevents wildcard permissions (*:*)
   - Enforces least privilege principle

---

## 🔄 Practice Workflow

### Run Through 1: Just Watch
Run the commands and observe the output without talking.

### Run Through 2: Add Narration
Run the commands while explaining what's happening.

### Run Through 3: Full Presentation
Pretend you're presenting to an audience - eye contact, pauses, enthusiasm!

---

## 📸 Optional: Show the Code

If you have extra time, you can show the actual policy code:

```bash
# Show a policy file
cat policies/s3_encryption.rego
```

Or open it in VS Code:
```bash
code policies/s3_encryption.rego
```

**What to say:**
> "Here's what the actual policy looks like - it's written in Rego, a declarative language.
> It checks for S3 buckets and ensures they have encryption configuration.
> Very readable, testable, and version-controlled just like application code."

---

## ✅ Pre-Demo Checklist

5 minutes before:
- [ ] Terminal open at project directory
- [ ] Font size increased
- [ ] This guide open for reference
- [ ] Tested once to ensure it works
- [ ] Water nearby 😊

Right before:
- [ ] Take a deep breath
- [ ] Smile
- [ ] You've got this!

---

## 🎬 Opening Line Suggestion

> "Today I'm going to show you how Policy as Code prevents security issues
> from ever reaching production. Watch what happens when a developer tries
> to deploy insecure infrastructure..."

---

## 🏁 Closing Line Suggestion

> "And that's Policy as Code in action! Security guardrails built right into
> the deployment pipeline - automated, fast, and reliable. Questions?"

---

## 📞 Emergency Backup

If the demo completely fails:
1. Stay calm and smile
2. Say: "Let me show you the code instead"
3. Open `policies/` and `terraform/templates/` in VS Code
4. Walk through the logic verbally
5. Show screenshots from practice runs (if you have them)

**Remember:** The audience wants you to succeed! A minor glitch won't matter if you handle it confidently.

---

## 🎉 You're Ready!

Everything is tested and working. Trust the demo, trust yourself, and have fun!

**Good luck!** 🚀

---

*Last tested: 2025-12-27*
*All commands verified working*
