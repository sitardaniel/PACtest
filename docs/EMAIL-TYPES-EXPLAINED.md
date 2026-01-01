# 📧 Understanding Your Email Alerts

You're receiving TWO types of emails from AWS Config. Here's what each one means:

---

## ✅ Type 1: Compliance Change Alerts (THE GOOD ONES!)

**From:** EventBridge → SNS
**Subject:** AWS Notification Message
**Format:** Nice formatted message

```
"AWS Config Compliance Change Detected!"
"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
"Rule: restricted-ssh"
"Status: NON_COMPLIANT"
"Resource Type: AWS::EC2::SecurityGroup"
"Resource ID: sg-0d525394e02b25944"
"Time: 2025-12-27T15:06:37Z"
```

**When you get it:**
- When a resource goes from COMPLIANT → NON_COMPLIANT
- When a resource goes from NON_COMPLIANT → COMPLIANT

**This is what you want for the demo!** ⭐

---

## 📊 Type 2: Configuration Notifications (Noisy)

**From:** AWS Config Delivery Channel → SNS
**Subject:** AWS Notification Message
**Format:** JSON data

```json
{
  "s3ObjectKey": "AWSLogs/123456789012/Config/.../ConfigHistory/...",
  "s3Bucket": "aws-config-logs-123456789012",
  "notificationCreationTime": "2025-12-27T15:57:00.155Z",
  "messageType": "ConfigurationHistoryDeliveryCompleted"
}
```

**When you get it:**
- Configuration snapshots delivered to S3
- Configuration history files created
- Config recorder status changes
- Rule evaluation starts

**These are informational - not needed for the demo**

---

## 🔍 How to Tell Them Apart

### **Compliance Change Alert (Good!):**
- ✅ Has formatted text with "AWS Config Compliance Change Detected!"
- ✅ Shows "Status: COMPLIANT" or "Status: NON_COMPLIANT"
- ✅ Lists the specific rule and resource
- ✅ Easy to read

### **Configuration Notification (Noisy):**
- Has `s3ObjectKey`, `s3Bucket` fields
- Has `messageType` like:
  - `ConfigurationHistoryDeliveryCompleted`
  - `ConfigurationSnapshotDeliveryCompleted`
  - `ConfigRulesEvaluationStarted`
- Raw JSON format
- Harder to read

---

## 🎯 For Your Demo

**Use ONLY the compliance change alerts:**
- These are the formatted ones from EventBridge
- They show "Status: NON_COMPLIANT" clearly
- They're what security teams care about

**Ignore the configuration notifications:**
- These are just background Config activity
- They don't indicate security violations
- They're for audit/compliance logging

---

## 🛠️ Options to Reduce Noise

### **Option 1: Filter Your Email** (Recommended for Demo)

**Gmail Filter:**
1. Create filter: Subject contains "AWS Notification Message"
2. AND body contains "Compliance Change Detected"
3. Label as: "Config Alerts - Important"
4. Star these emails

This way you can quickly spot the important alerts!

---

### **Option 2: Separate SNS Topics** (Production Best Practice)

Create two separate SNS topics:
1. **config-compliance-alerts** - Only for EventBridge compliance changes
2. **config-history-notifications** - For Config delivery channel

**Current setup:**
```
Config Delivery Channel ──┐
                          ├──> SNS Topic ──> Your Email
EventBridge Rule ─────────┘
```

**Better setup:**
```
Config Delivery Channel ──> SNS Topic 1 ──> S3/CloudWatch (not email)
EventBridge Rule ────────> SNS Topic 2 ──> Your Email ✅
```

---

### **Option 3: Remove Email from Delivery Channel** (Quick Fix)

If you only want compliance change alerts, we can:

1. Keep EventBridge → SNS → Email (compliance changes)
2. Remove SNS from Config delivery channel (history notifications)

**This means:**
- ✅ You still get compliance change alerts
- ✅ Config still logs to S3 (for audits)
- ❌ You won't get configuration history notifications (which you don't need anyway)

---

## 💡 What I Recommend for Your Demo

**Keep it as is!**

**Why?**
1. The compliance change alerts are clearly formatted - easy to spot
2. The extra notifications show Config is actively working
3. You can explain: "Config sends various notifications, but the important
   ones are the compliance changes with the formatted alert"

**During demo:**
- Show your email inbox
- Point out the compliance change alert (formatted one)
- Say: "Here's the alert - Status: NON_COMPLIANT - exactly what we wanted to catch"
- Ignore the other notifications

---

## 🎬 Demo Script Addition

**When showing email:**
> "As you can see, AWS Config sends various notifications - configuration
> snapshots, history files, etc. But the important one is right here -
> the compliance change alert showing our security violation was detected."

**[Point to the formatted alert]**

> "Status: NON_COMPLIANT - our security group allowing SSH from the
> internet was caught within 60 seconds!"

---

## 🚀 Want to Clean It Up? (Optional)

If you want ONLY compliance alerts, run this:

```bash
cd /Users/sitargold/Projects/OPAtest/policy-as-code-demo/terraform

# Edit aws-config.tf - remove SNS from delivery channel
# Change line 155 from:
#   sns_topic_arn  = aws_sns_topic.config_alerts.arn
# To:
#   # sns_topic_arn  = aws_sns_topic.config_alerts.arn

# Then apply:
terraform apply
```

**Result:**
- ✅ Still get EventBridge compliance alerts
- ✅ Config still logs to S3
- ❌ No more configuration history emails

**But honestly, not necessary for the demo!**

---

## ✅ Bottom Line

You're getting **both types** of notifications, which is fine!

**For your demo:**
- Focus on the formatted compliance change alerts
- These clearly show "NON_COMPLIANT" status
- Easy to spot and dramatic for the demo

**The other notifications just show Config is working** - you can mention
this as a positive: "As you can see, Config is actively monitoring and
logging all configuration changes for compliance audits."

---

**Your demo is working perfectly!** 🎉
