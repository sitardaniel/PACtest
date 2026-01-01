# 🎬 Complete Policy as Code Demo Script

**Total Time:** 6-8 minutes  
**Difficulty:** Easy  
**Impact:** High  

---

## 🎯 What You're Demonstrating

A **two-phase security automation approach**:

1. **Demo 1 (Prevention):** OPA blocks bad deployments before they reach AWS
2. **Demo 2 (Detection):** AWS Config catches manual changes after deployment

Together = **Comprehensive security coverage**

---

## 📋 Pre-Demo Setup (5 minutes before)

### Terminal Setup:
```bash
cd /Users/sitargold/Projects/OPAtest/policy-as-code-demo
# Increase font size: Cmd + + (multiple times)
# Have QUICK-COMMANDS.txt open for reference
```

### Browser Setup:
- Tab 1: AWS Config Console (https://console.aws.amazon.com/config/home?region=us-east-1#/rules)
- Tab 2: EC2 Security Groups (https://console.aws.amazon.com/ec2/home?region=us-east-1#SecurityGroups:)
- Tab 3: Gmail (YOUR_EMAIL@example.com) - set to auto-refresh

### Final Check:
```bash
# Verify OPA works
./scripts/validate.sh
```

---

## 🎬 DEMO 1: Prevention with OPA (3-4 minutes)

### Opening (30 seconds)

**Say:**
> "Today I'm showing you Policy as Code - automated security enforcement for cloud infrastructure. Let me start by showing what happens when a developer tries to deploy insecure infrastructure..."

### Part A: Show Violations (90 seconds)

**Commands:**
```bash
cd terraform
cp templates/main-noncompliant.tf main.tf
cd ..
./scripts/validate.sh
```

**While it runs:**
> "This is a Terraform configuration that creates AWS infrastructure. OPA is now analyzing it against our security policies..."

**When violations appear:**
> "OPA caught TWO security violations:
> 1. An S3 bucket without encryption
> 2. A security group allowing SSH from the entire internet
> 
> The deployment FAILS here - nothing gets to AWS. The developer gets immediate feedback in their CI/CD pipeline."

**Point to screen:**
- Show the specific violations
- Highlight the resource names

### Part B: Show Success (90 seconds)

**Commands:**
```bash
cd terraform
cp templates/main-compliant.tf main.tf
cd ..
./scripts/validate.sh
```

**While it runs:**
> "Now let's fix those security issues and run validation again..."

**When it passes:**
> "All policies passed! The compliant infrastructure has:
> - S3 buckets WITH encryption
> - Security groups restricting SSH to internal networks only
> - RDS with encryption enabled
> 
> This code is now approved for deployment - completely automated, no manual reviews needed!"

### Transition (15 seconds)

**Say:**
> "But what happens AFTER we deploy? What if someone makes a manual change in the AWS console? That's where Demo 2 comes in..."

---

## 🎬 DEMO 2: Detection with AWS Config (3-4 minutes)

### Part A: Show Compliant State (30 seconds)

**Switch to browser - AWS Config Console**

**Say:**
> "After deployment, AWS Config monitors our infrastructure 24/7. Here you can see all our security policies showing compliant - everything is secure."

**Point to screen:**
- Show the 3 rules (all green/compliant)
- Explain each rule briefly

### Part B: Simulate Drift (60 seconds)

**Switch to EC2 Console**

**Say:**
> "Now I'm going to simulate what happens when a developer makes a manual change - maybe they think they're in dev, or they're 'just testing something'..."

**Actions:**
1. Click "Create security group"
2. Name: `demo-open-ssh`
3. Description: `Demo insecure SSH`
4. Add Inbound Rule:
   - Type: SSH
   - Source: 0.0.0.0/0
5. Click "Create security group"

**While creating:**
> "I'm creating a security group that allows SSH access from the entire internet - 0.0.0.0/0. This is a common misconfiguration that leads to security breaches."

### Part C: Show Detection (90 seconds)

**After creation:**
> "AWS Config is now scanning all resources. Within 30-60 seconds it will detect this violation and send an alert..."

**While waiting (talk for 30-60 seconds):**
- Explain how Config works continuously
- Talk about the importance of drift detection
- Mention compliance requirements

**Switch to Gmail tab - wait for email**

**When email arrives (should show "Status: NON_COMPLIANT"):**
> "There it is! The security team just received an alert showing:
> - WHAT: Security group with open SSH
> - WHEN: Exact timestamp
> - WHERE: Specific resource ID
> - WHICH POLICY: restricted-ssh rule violated"

**Switch back to Config Console:**
> "And here in the Config console, you can see the rule now shows 'Noncompliant' with details about the violation."

### Closing (30 seconds)

**Say:**
> "This is the two-phase approach:
> - Demo 1: OPA PREVENTS issues before deployment
> - Demo 2: Config DETECTS issues after deployment
> 
> Together, they provide comprehensive security automation - no manual reviews, instant feedback, complete audit trail. Questions?"

---

## 🎤 Key Talking Points

### Why This Matters:
- **Shift-Left Security:** Catch issues in development, not production
- **Zero Trust for Infrastructure:** Verify continuously, never assume
- **Compliance Automation:** Meets SOC2, PCI-DSS, HIPAA requirements
- **Developer Velocity:** No bottlenecks from manual security reviews

### Business Impact:
- **Reduce Incidents:** 23% of cloud breaches are from misconfigurations
- **Faster Deployments:** Automated gates vs. days of manual reviews
- **Cost Savings:** Prevent security incidents (avg cost: $4.35M per breach)
- **Audit Trail:** Complete history in version control + Config

---

## 🧹 Cleanup After Demo

```bash
# Delete the demo security group
aws ec2 delete-security-group --group-id <GROUP_ID> --region us-east-1

# Or via Console: EC2 → Security Groups → Select → Actions → Delete
```

**Note:** Deleting the security group will trigger another email showing compliance is restored!

---

## 🚨 Troubleshooting During Live Demo

### Terminal hangs during OPA validation:
- Press Ctrl + C
- Run again: `./scripts/validate.sh`

### Email doesn't arrive:
- Keep talking - explain Config architecture
- Check after 2 minutes
- Worst case: Show the Config console (still shows noncompliant)

### Wrong Terraform file:
- Check current: `head terraform/main.tf`
- Copy correct version from templates/

### Forgot which command:
- Have QUICK-COMMANDS.txt open
- Or DEMO2-QUICK-STEPS.txt for Demo 2

---

## 📊 Success Metrics

After this demo, your audience should understand:

✅ How OPA validates infrastructure code  
✅ How Config detects drift in real-time  
✅ The value of automated security enforcement  
✅ How to implement this in their own environment  

---

## 🎯 Optional: Show the Code

If you have extra time (1-2 minutes):

```bash
# Show an OPA policy
cat policies/s3_encryption.rego
```

**Say:**
> "This is what the policy looks like - written in Rego, a declarative language. It's readable, testable, and version-controlled just like application code."

---

## ✅ You're Ready!

**Remember:**
- 🎤 Speak slowly and clearly
- 👀 Maintain eye contact with audience
- ⏸️ Pause after key points
- 😊 Show enthusiasm - this is cool stuff!
- 💪 You've practiced and tested everything - you've got this!

**Good luck with your presentation!** 🚀
