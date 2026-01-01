#!/bin/bash

echo "📊 AWS Config Compliance Dashboard"
echo "===================================="
echo ""

# Check overall compliance
echo "Overall Compliance Status:"
aws configservice describe-compliance-by-config-rule \
  --query 'ComplianceByConfigRules[*].[ConfigRuleName,Compliance.ComplianceType]' \
  --output table

echo ""
echo "Compliance Summary:"
aws configservice get-compliance-summary-by-config-rule \
  --query 'ComplianceSummary' \
  --output json | jq

echo ""
echo "Recent Compliance Changes:"
aws configservice describe-config-rule-evaluation-status \
  --config-rule-names s3-bucket-server-side-encryption-enabled \
  --query 'ConfigRulesEvaluationStatus[*].[ConfigRuleName,LastSuccessfulInvocationTime,LastFailedInvocationTime]' \
  --output table
