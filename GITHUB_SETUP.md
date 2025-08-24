# GitHub Repository Configuration Guide

This guide provides step-by-step instructions to configure your GitHub repository for the automated dbt CI/CD workflow.

## 🔧 **GitHub Repository Configuration**

### **Step 1: Create Repository**
```bash
# Initialize git repo (in your project directory)
git init
git add .
git commit -m "Initial dbt project setup"

# Create GitHub repo and push
gh repo create your-org/dbt_ci_test --public
git remote add origin https://github.com/your-org/dbt_ci_test.git
git push -u origin main
```

### **Step 2: Configure Repository Secrets**

**Navigate to**: `Settings → Secrets and variables → Actions`

**Required Secrets for Production:**
```bash
# NOTE: CI uses PostgreSQL service container, not localhost
# These secrets are only needed for production deployments to external databases
PROD_DBT_HOST=your-production-db-host
PROD_DBT_USER=your-production-db-user  
PROD_DBT_PASSWORD=your-production-db-password
PROD_DBT_DATABASE=your-production-database
PROD_DBT_SCHEMA=analytics

# For localhost production testing, see LOCAL_PROD_TESTING.md
```

**Using GitHub CLI:**
```bash
gh secret set PROD_DBT_HOST --body "your-prod-host"
gh secret set PROD_DBT_USER --body "your-prod-user"
gh secret set PROD_DBT_PASSWORD --body "your-prod-password"
gh secret set PROD_DBT_DATABASE --body "your-prod-database"
gh secret set PROD_DBT_SCHEMA --body "analytics"
```

### **Step 3: Branch Protection Rules**

**Navigate to**: `Settings → Branches → Add rule`

**Rule Configuration:**
- **Branch name pattern**: `main`
- ✅ **Protect matching branches**

**Required Status Checks:**
- ✅ **Require status checks to pass before merging**
- ✅ **Require branches to be up to date before merging**
- **Status checks to require:**
  - `lint`
  - `dbt_test (dev)`
  - `comment_pr`

**Pull Request Requirements:**
- ✅ **Require a pull request before merging**  
- ✅ **Require approvals**: `1` (adjust for team size)
- ✅ **Dismiss stale PR approvals when new commits are pushed**
- ✅ **Require review from code owners** (if using CODEOWNERS)

**Additional Settings:**
- ✅ **Restrict pushes that create files larger than 100 MB**
- ✅ **Include administrators** (recommended)

### **Step 4: Environment Setup**

**Navigate to**: `Settings → Environments → New environment`

**Create Production Environment:**
- **Environment name**: `production`
- **Deployment protection rules**:
  - ✅ **Required reviewers**: Add senior team members
  - ✅ **Wait timer**: `0` minutes (or as needed)
- **Environment secrets**: Add production database credentials

### **Step 5: Actions Permissions**

**Navigate to**: `Settings → Actions → General`

- ✅ **Allow all actions and reusable workflows**
- ✅ **Allow actions created by GitHub**
- ✅ **Allow actions by Marketplace verified creators**

### **Step 6: Auto-merge (Optional)**

**Navigate to**: `Settings → General → Pull Requests`

- ✅ **Allow auto-merge**
- ✅ **Automatically delete head branches**

### **Step 7: GitHub CLI Automation**

```bash
# Set branch protection rule
gh api repos/{OWNER}/{REPO}/branches/main/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"contexts":["lint","dbt_test (dev)","comment_pr"]}' \
  --field enforce_admins=true \
  --field required_pull_request_reviews='{"required_approving_review_count":1,"dismiss_stale_reviews":true}' \
  --field restrictions=null

# Enable vulnerability alerts
gh api repos/{OWNER}/{REPO} --method PATCH \
  --field has_vulnerability_alerts=true
```

## 🧪 **Step 8: Test the Workflow**

### **Create a Test Feature Branch:**
```bash
# Create and switch to feature branch
git checkout -b feature/test-ci-pipeline

# Make a small change (e.g., add comment to model)
# Edit any model file and add -- Test comment

# Commit and push
git add .
git commit -m "Test CI pipeline setup"
git push origin feature/test-ci-pipeline

# Create PR via GitHub CLI
gh pr create --title "Test CI Pipeline" --body "Testing the automated dbt CI workflow"
```

### **What Should Happen:**
1. ✅ **GitHub Actions triggers** automatically
2. ✅ **SQL linting** runs with sqlfluff
3. ✅ **PostgreSQL container** starts in CI
4. ✅ **dbt models** build in isolated schema `pr_X_analytics`
5. ✅ **dbt tests** execute
6. ✅ **PR comment** appears with results
7. ✅ **Status checks** show green/red in PR

### **Monitor the Workflow:**
- **Actions Tab**: View running workflows
- **PR Checks**: See status at bottom of PR
- **PR Comments**: Automated success/failure notifications

## ✅ **Verification Checklist**

- [ ] Repository created and code pushed
- [ ] Production secrets configured
- [ ] Branch protection rules enabled
- [ ] Production environment created
- [ ] Actions permissions configured
- [ ] Test PR created and CI pipeline runs
- [ ] PR comments appear automatically
- [ ] Status checks prevent merge until passing

## 🔍 **Troubleshooting Common Issues**

### **Workflow Not Triggering**
- Check that workflow files are in `.github/workflows/`
- Verify branch protection rules include correct status check names
- Ensure Actions are enabled in repository settings

### **Database Connection Failures**
- Verify secrets are correctly set
- Check that PostgreSQL service starts successfully in Actions logs
- Confirm environment variables match between local and CI

### **Status Checks Not Required**
- Branch protection rules must be configured after first workflow run
- Status check names must match exactly (case-sensitive)
- Re-run failed workflows to refresh status checks

### **Permission Denied Errors**
- Check that GitHub Actions have appropriate permissions
- Verify GITHUB_TOKEN has necessary scopes
- Ensure environment protection rules allow the workflow

## 📈 **Next Steps After Setup**

1. **Train Team**: Share this guide with team members
2. **Document Processes**: Update team wiki with new workflow
3. **Monitor Performance**: Track CI execution times and optimize
4. **Iterate**: Gather feedback and improve based on usage

Once configured, your team can use the new **feature→main** workflow with full automated testing!