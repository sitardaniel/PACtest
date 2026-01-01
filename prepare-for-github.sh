#!/bin/bash

echo "🚀 Preparing Policy as Code Demo for GitHub Upload..."

# Create clean docs directory
mkdir -p docs

# Move documentation files to docs/
echo "📁 Organizing documentation..."
mv DEMO-PRACTICE-GUIDE.md docs/ 2>/dev/null || true
mv DEMO2-ARCHITECTURE-SETUP.md docs/ 2>/dev/null || true
mv SHOW-SETUP-IN-CONSOLE.md docs/ 2>/dev/null || true
mv EMAIL-TYPES-EXPLAINED.md docs/ 2>/dev/null || true
mv DEMO2-CONCEPTUAL-GUIDE.md docs/ 2>/dev/null || true
mv DEMO2-LIVE-MANUAL-TRIGGER.md docs/ 2>/dev/null || true
mv QUICK-COMMANDS.txt docs/ 2>/dev/null || true
mv DEMO2-QUICK-STEPS.txt docs/ 2>/dev/null || true
mv COMPLETE-DEMO-SCRIPT.md docs/ 2>/dev/null || true
mv DEMO-READY.md docs/ 2>/dev/null || true
mv README-DEMO-FILES.md docs/ 2>/dev/null || true

# Keep these in root
# - FINAL-COMPLETE-GUIDE.md
# - README.md
# - SETUP-STATUS.md

# Remove temporary files
echo "🧹 Cleaning up temporary files..."
rm -f DISABLE-ENCRYPTION-STEPS.md
rm -f EMAIL-ALERT-EXPLANATION.md
rm -f TRIGGER-ALERT-MANUALLY.md

# Create .gitignore for root
echo "📝 Creating .gitignore..."
cat > .gitignore << 'GITIGNORE'
# OPA binary
opa

# macOS
.DS_Store

# Temporary files
*.tmp
*.bak

# Sensitive data
*.pem
*.key
credentials.json
.env

# Editor
.vscode/
.idea/
*.swp
*.swo
*~
GITIGNORE

# Create LICENSE
echo "📄 Creating LICENSE..."
cat > LICENSE << 'LICENSE'
MIT License

Copyright (c) 2025 Policy as Code Demo

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
LICENSE

# Create GitHub Actions workflow directory
echo "⚙️ Creating GitHub Actions workflow..."
mkdir -p .github/workflows

cat > .github/workflows/policy-validation.yml << 'WORKFLOW'
name: Policy Validation

on:
  pull_request:
    branches: [ main ]
  push:
    branches: [ main ]

jobs:
  opa-test:
    name: Test OPA Policies
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Download OPA
      run: |
        curl -L -o opa https://openpolicyagent.org/downloads/latest/opa_linux_amd64
        chmod +x opa
    
    - name: Run OPA Tests
      run: ./opa test policies/ -v
  
  terraform-validate:
    name: Validate Terraform
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v2
    
    - name: Terraform Format Check
      run: terraform fmt -check -recursive terraform/
    
    - name: Terraform Init
      run: |
        cd terraform
        terraform init -backend=false
    
    - name: Terraform Validate
      run: |
        cd terraform
        terraform validate
WORKFLOW

echo ""
echo "✅ Repository prepared for GitHub!"
echo ""
echo "📁 Directory structure:"
tree -L 2 -I 'node_modules|.terraform'

echo ""
echo "📋 Next steps:"
echo "1. Initialize git repository: git init"
echo "2. Add files: git add ."
echo "3. Commit: git commit -m 'Initial commit: Policy as Code Demo'"
echo "4. Create GitHub repo and push"
echo ""
echo "🎉 Ready for GitHub upload!"
