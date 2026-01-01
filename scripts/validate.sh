#!/bin/bash

set -e

echo "🔍 Running Policy as Code validation..."

# Initialize Terraform
cd terraform
terraform init

# Generate plan
terraform plan -out=tfplan.binary
terraform show -json tfplan.binary > tfplan.json

# Run OPA evaluation
echo "📋 Evaluating against OPA policies..."
../opa eval --data ../policies --input tfplan.json --format pretty "data.terraform"

# Check for policy violations across all packages
echo ""
echo "🔎 Checking for violations..."

# Collect all violations into a temp file
TEMP_FILE=$(mktemp)
VIOLATION_COUNT=0

# Check each policy package
for package in s3 security_groups rds iam; do
    ../opa eval --data ../policies --input tfplan.json --format json "data.terraform.${package}.deny" 2>/dev/null | \
        jq -r '.result[0].expressions[0].value[]? // empty' >> "$TEMP_FILE"
done

# Count violations
VIOLATION_COUNT=$(cat "$TEMP_FILE" | grep -v '^$' | wc -l | tr -d ' ')

if [ "$VIOLATION_COUNT" -gt 0 ]; then
    echo "❌ POLICY VIOLATIONS FOUND ($VIOLATION_COUNT):"
    echo ""
    cat "$TEMP_FILE" | grep -v '^$' | while IFS= read -r line; do
        echo "  • $line"
    done
    echo ""
    rm -f "$TEMP_FILE"
    exit 1
else
    echo "✅ All policies passed!"
    rm -f "$TEMP_FILE"
    exit 0
fi
