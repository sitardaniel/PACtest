# 🖥️ How to Show the Setup in AWS Console

Use this guide to show your audience how the AWS Config rules are configured.

---

## 🎯 Quick Console Links

All links are for **us-east-1** region:

### **AWS Config Dashboard:**
https://console.aws.amazon.com/config/home?region=us-east-1

### **Config Rules:**
https://console.aws.amazon.com/config/home?region=us-east-1#/rules

### **EventBridge Rules:**
https://console.aws.amazon.com/events/home?region=us-east-1#/rules

### **SNS Topics:**
https://console.aws.amazon.com/sns/v3/home?region=us-east-1#/topics

### **EC2 Security Groups:**
https://console.aws.amazon.com/ec2/home?region=us-east-1#SecurityGroups:

---

## 📋 Step-by-Step: Show Config Rules

### **1. Go to AWS Config Rules**

URL: https://console.aws.amazon.com/config/home?region=us-east-1#/rules

**What to say:**
> "Here are the three security policies we're enforcing..."

**What you'll see:**
```
Rules (3)

┌──────────────────────────────────────────┬─────────────┐
│ Rule name                                │ Compliance  │
├──────────────────────────────────────────┼─────────────┤
│ s3-bucket-server-side-encryption-enabled │ Compliant   │
│ restricted-ssh                           │ Compliant   │
│ rds-storage-encrypted                    │ Compliant   │
└──────────────────────────────────────────┴─────────────┘
```

---

### **2. Click on "restricted-ssh" Rule**

**What to show:**
- **Rule name:** restricted-ssh
- **Rule type:** AWS managed rule
- **Source identifier:** INCOMING_SSH_DISABLED
- **Trigger:** Configuration changes
- **Resources in scope:** AWS::EC2::SecurityGroup

**What to say:**
> "This rule checks all security groups in our account and ensures
> they don't allow SSH access from the internet - 0.0.0.0/0"

**Point out:**
- Compliance tab showing which resources are compliant/non-compliant
- Timeline showing when compliance changed

---

### **3. Click on "s3-bucket-server-side-encryption-enabled"**

**What to show:**
- **Rule name:** s3-bucket-server-side-encryption-enabled
- **Source identifier:** S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED
- **Resources in scope:** AWS::S3::Bucket

**What to say:**
> "This ensures all S3 buckets have encryption enabled to protect
> data at rest - required for compliance"

---

### **4. Click on "rds-storage-encrypted"**

**What to show:**
- **Rule name:** rds-storage-encrypted
- **Source identifier:** RDS_STORAGE_ENCRYPTED
- **Resources in scope:** AWS::RDS::DBInstance

**What to say:**
> "This verifies all RDS databases are encrypted at rest"

---

## 🔔 Show EventBridge Rule

### **Go to EventBridge Rules:**

URL: https://console.aws.amazon.com/events/home?region=us-east-1#/rules

**Find:** `config-compliance-change-alert`

**Click on it to show:**

1. **Event pattern:**
```json
{
  "source": ["aws.config"],
  "detail-type": ["Config Rules Compliance Change"]
}
```

**What to say:**
> "This EventBridge rule listens specifically for Config compliance
> changes - when a rule goes from compliant to non-compliant or
> vice versa"

2. **Targets:**
   - Target type: SNS topic
   - Topic: config-compliance-alerts

**What to say:**
> "When it detects a compliance change, it sends the alert to our
> SNS topic which emails the security team"

3. **Input transformer:**

**What to say:**
> "The input transformer formats the raw Config event into a readable
> email message showing exactly what changed, when, and which rule
> was violated"

---

## 📧 Show SNS Topic

### **Go to SNS Topics:**

URL: https://console.aws.amazon.com/sns/v3/home?region=us-east-1#/topics

**Find:** `config-compliance-alerts`

**Click on it to show:**

1. **Subscriptions:**
   - Protocol: Email
   - Endpoint: YOUR_EMAIL@example.com
   - Status: Confirmed

**What to say:**
> "This SNS topic has one subscription - an email to the security
> team. When compliance changes, they get an immediate alert"

2. **Access policy:**

**Point out:**
- Allows `config.amazonaws.com` to publish
- Allows `events.amazonaws.com` to publish

**What to say:**
> "The access policy allows both AWS Config and EventBridge to
> publish notifications to this topic"

---

## 🔄 Show Config Recorder

### **Go to Config Settings:**

URL: https://console.aws.amazon.com/config/home?region=us-east-1#/settings

**What to show:**
- **Recorder:** main-recorder
- **Status:** Recording
- **Recording strategy:** All resource types
- **Delivery channel:** main-channel
- **S3 bucket:** aws-config-logs-123456789012
- **SNS topic:** config-compliance-alerts

**What to say:**
> "The Config recorder is actively monitoring ALL resource types in
> this account. It records every configuration change and stores
> the history in S3 for compliance audits"

---

## 📊 Show Resource Timeline

### **Example: Show Security Group Timeline**

1. Go to Config → Resources
2. Filter by: AWS::EC2::SecurityGroup
3. Click on any security group
4. Click "Timeline" tab

**What you'll see:**
- Configuration changes over time
- When compliance status changed
- Who made the changes
- Complete audit trail

**What to say:**
> "Here's the complete timeline for this resource. We can see every
> change - who made it, when, and what the configuration looked like
> before and after. Perfect for compliance audits and investigations"

---

## 🎬 Demo Flow Suggestion

### **Show the Setup Flow:**

1. **Start at Config Dashboard**
   > "This is AWS Config - our continuous compliance monitoring system"

2. **Show the 3 Rules**
   > "We've configured three security policies..."

3. **Click into one rule**
   > "Each rule checks specific security requirements..."

4. **Show EventBridge**
   > "When compliance changes, EventBridge catches it..."

5. **Show SNS Topic**
   > "And sends an alert to the security team via SNS"

6. **Back to Config**
   > "Now let's see what happens when someone violates a policy..."

7. **[Create non-compliant resource]**

8. **Wait 30-60 seconds**

9. **Show email alert**

10. **Refresh Config Rules page**
    > "And here we can see the rule is now showing non-compliant"

**Total time:** 3-4 minutes

---

## 💡 Pro Tips

### **Before Your Demo:**
- Have all console tabs pre-opened
- Make sure you're logged into the right AWS account
- Check region is set to us-east-1 (top right)
- Have email open on another screen

### **During Your Demo:**
- Zoom in on browser if presenting (Cmd + +)
- Point with cursor to important sections
- Read key values out loud (rule names, etc.)
- Don't rush through the console screens

### **What to Emphasize:**
- **Automation:** "No manual work required"
- **Speed:** "Detection within 60 seconds"
- **Completeness:** "Monitors ALL resources"
- **Audit Trail:** "Complete history for compliance"
- **Infrastructure as Code:** "All defined in Terraform"

---

## 🎯 Key Screens to Screenshot (Optional)

If you want to prepare backup slides:

1. Config Rules dashboard (all 3 rules showing compliant)
2. EventBridge rule detail showing event pattern
3. SNS topic showing email subscription
4. Resource timeline showing compliance change
5. Email alert showing "NON_COMPLIANT"

---

## ✅ You're Ready!

You now know exactly how to navigate the AWS Console to show your
Config setup during the demo!
