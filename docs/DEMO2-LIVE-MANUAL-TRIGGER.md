# Demo 2: How to Manually Trigger Drift Detection

## 🎯 Best Method for Live Demo: AWS Console (Web UI)

This is the most visual and audience-friendly way to demonstrate drift detection.

---

## 📋 Step-by-Step: Trigger Drift via AWS Console

### **Step 1: Show Current Compliant State**

1. Go to AWS Config Console:
   https://console.aws.amazon.com/config/home?region=us-east-1

2. Click **"Rules"** in left sidebar

3. Point out all rules showing **"Compliant"** (green checkmarks)

**What to say:**
> "Here you can see all our security policies are compliant. Everything is secure."

---

### **Step 2: Simulate Manual Drift (Create Non-Compliant Resource)**

#### Option A: Disable S3 Bucket Encryption (Visual but harder)

1. Go to S3 Console:
   https://console.aws.amazon.com/s3/buckets?region=us-east-1

2. Click on bucket: **demo-bucket-policy-as-code-123456789012**

3. Click **"Properties"** tab

4. Scroll to **"Default encryption"**

5. Click **"Edit"**

6. Select **"Disable"**

7. Click **"Save changes"**

**Issue:** S3 encryption can be tricky - AWS sometimes applies default encryption

---

#### Option B: Create Security Group with Open SSH (RECOMMENDED) ✅

This is **THE BEST METHOD** for live demos - fast, visual, and reliable!

1. Go to EC2 Console:
   https://console.aws.amazon.com/ec2/home?region=us-east-1#SecurityGroups:

2. Click **"Create security group"** (orange button, top right)

3. Fill in:
   - **Security group name:** `demo-open-ssh`
   - **Description:** `Demo - insecure SSH access`
   - **VPC:** Leave default

4. Scroll to **"Inbound rules"** section

5. Click **"Add rule"**

6. Configure the rule:
   - **Type:** SSH
   - **Protocol:** TCP
   - **Port range:** 22 (auto-filled)
   - **Source:** Custom - **0.0.0.0/0** ⚠️
   - **Description:** `Open SSH - BAD!`

7. Click **"Create security group"** at bottom

**What to say:**
> "I'm creating a security group that allows SSH access from the entire internet - 
> a common mistake developers make. Watch what happens..."

---

### **Step 3: Wait and Show Detection**

**Timing:** 30-90 seconds after creating the resource

1. **Open your email** (project on screen if possible):
   - Email: YOUR_EMAIL@example.com
   
2. **Wait for the alert email** to arrive:

```
"AWS Config Compliance Change Detected!"
"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
"Rule: restricted-ssh"
"Status: NON_COMPLIANT"
"Resource Type: AWS::EC2::SecurityGroup"
"Resource ID: sg-xxxxxxxxxx"
"Time: 2025-12-27T..."
```

**What to say while waiting:**
> "AWS Config is now scanning all resources... within 30-60 seconds it will detect
> this security violation and send an alert to the security team."

---

### **Step 4: Show the Alert**

1. **Refresh your email** and show the alert message

2. **Go back to AWS Config Console:**
   https://console.aws.amazon.com/config/home?region=us-east-1#/rules

3. Click on **"restricted-ssh"** rule

4. Show that it now says **"Noncompliant"** with count: 1

5. Click on the resource to see details

**What to say:**
> "Here's the email alert showing exactly what violated the policy, when it happened,
> and which security rule was broken. The security team can now investigate and
> remediate immediately."

---

## ⚡ Alternative: CLI Method (Faster, Less Visual)

If you prefer command-line (good for technical audiences):

### Quick Command to Trigger:

```bash
# Create security group with open SSH
SG_ID=$(aws ec2 create-security-group \
  --group-name demo-drift-$(date +%s) \
  --description "Demo drift detection" \
  --region us-east-1 \
  --query 'GroupId' \
  --output text)

echo "Created Security Group: $SG_ID"

# Add open SSH rule (this triggers the violation)
aws ec2 authorize-security-group-ingress \
  --group-id $SG_ID \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0 \
  --region us-east-1

echo "✅ Open SSH rule added! Check your email in 30-60 seconds..."
```

---

## 🎬 Recommended Demo Flow

### For Maximum Impact:

1. **Start:** Show AWS Config dashboard - all green (compliant)
2. **Action:** Create security group with open SSH in Console (audience can see each step)
3. **Wait:** Talk about how Config monitors resources (30-60 seconds)
4. **Reveal:** Show the email alert on screen
5. **Explain:** Show the Config console now showing non-compliant

**Total time:** 2-3 minutes

---

## 🧹 Clean Up After Demo

### Via Console:
1. Go to EC2 Console → Security Groups
2. Select the demo security group
3. Click **"Actions"** → **"Delete security group"**

### Via CLI:
```bash
aws ec2 delete-security-group \
  --group-id <GROUP_ID> \
  --region us-east-1
```

**Bonus:** This deletion will trigger ANOTHER email showing compliance is restored!

---

## 💡 Pro Tips for Live Demo

### Before You Start:
- ✅ Have email open in another tab/screen
- ✅ Set email to auto-refresh every 10 seconds
- ✅ Have AWS Config console open and ready
- ✅ Practice once beforehand to verify timing

### During the Demo:
- 🎤 Talk while waiting - explain how Config works
- 👀 Keep email visible - the moment alert arrives is dramatic!
- 📊 Show both email AND Config console for full picture
- ⏱️ If it takes >60 seconds, keep talking - it WILL arrive

### What to Emphasize:
- ⚡ **Speed:** Detection in under 60 seconds
- 🎯 **Accuracy:** Exact resource, exact violation, exact time
- 📧 **Automation:** No manual checking required
- 🔗 **Integration:** Links directly to AWS Console for remediation

---

## 🎯 Why Security Groups Work Best for Demo

✅ **Fast:** Creates in seconds
✅ **Visual:** Easy to see in Console
✅ **Reliable:** Always triggers the rule
✅ **Clear:** Obvious security violation (SSH from internet)
✅ **Safe:** Doesn't affect other resources
✅ **Reversible:** Easy to delete afterward

---

## 🚨 Troubleshooting

### Email Doesn't Arrive?
1. Check spam folder
2. Verify rule evaluation: `aws configservice describe-compliance-by-config-rule --region us-east-1`
3. Wait 2 minutes - sometimes takes longer
4. Check EventBridge rule is enabled

### Still Showing Compliant?
- Wait 30 more seconds
- Manually trigger evaluation: `aws configservice start-config-rules-evaluation --config-rule-names restricted-ssh`

---

## ✅ You're Ready!

The **Security Group method via AWS Console** is your best option for a live demo.

**Practice it once, and you'll nail it!** 🎬
