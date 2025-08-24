# Branch Protection Rules Setup

## Required GitHub Repository Settings

### 1. Branch Protection Rules for `main`

Navigate to: **Settings → Branches → Add rule**

#### Rule Configuration:
- **Branch name pattern**: `main`
- **Protect matching branches**: ✅ Enabled

#### Required Status Checks:
- ✅ Require status checks to pass before merging
- ✅ Require branches to be up to date before merging
- **Required status checks**:
  - `lint`
  - `dbt_test (dev)`
  - `comment_pr`

#### Pull Request Requirements:
- ✅ Require a pull request before merging
- ✅ Require approvals: **1** (adjust based on team size)
- ✅ Dismiss stale PR approvals when new commits are pushed
- ✅ Require review from code owners (if CODEOWNERS file exists)

#### Additional Restrictions:
- ✅ Restrict pushes that create files larger than 100 MB
- ✅ Include administrators (recommended for consistency)

### 2. Required Repository Secrets

Navigate to: **Settings → Secrets and variables → Actions**

#### For CI Pipeline (using local PostgreSQL in CI):
```
# These are used for production deployments only
PROD_DBT_HOST=your-prod-db-host
PROD_DBT_USER=your-prod-db-user  
PROD_DBT_PASSWORD=your-prod-db-password
PROD_DBT_DATABASE=your-prod-database
PROD_DBT_SCHEMA=analytics
```

### 3. Environment Setup

Navigate to: **Settings → Environments → New environment**

#### Production Environment:
- **Environment name**: `production`
- **Deployment protection rules**:
  - ✅ Required reviewers: Add production deployment approvers
  - ✅ Wait timer: 0 minutes (or as needed)
- **Environment secrets**: Add production database credentials

### 4. Repository Permissions

#### Collaborator Settings:
- **Settings → Collaborators and teams**
- Set appropriate permissions for team members
- Consider using teams for better permission management

#### Actions Permissions:
- **Settings → Actions → General**
- ✅ Allow all actions and reusable workflows
- ✅ Allow actions created by GitHub
- ✅ Allow actions by Marketplace verified creators

### 5. Auto-merge Configuration (Optional)

#### Enable auto-merge for the repository:
- **Settings → General → Pull Requests**
- ✅ Allow auto-merge
- ✅ Automatically delete head branches

## Implementation Script

You can use GitHub CLI to set up these rules programmatically:

```bash
# Install GitHub CLI first: https://cli.github.com/

# Set branch protection rule
gh api repos/{owner}/{repo}/branches/main/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"contexts":["lint","dbt_test (dev)","comment_pr"]}' \
  --field enforce_admins=true \
  --field required_pull_request_reviews='{"required_approving_review_count":1,"dismiss_stale_reviews":true}' \
  --field restrictions=null

# Add repository secrets (run these commands and enter values when prompted)
gh secret set PROD_DBT_HOST
gh secret set PROD_DBT_USER  
gh secret set PROD_DBT_PASSWORD
gh secret set PROD_DBT_DATABASE
gh secret set PROD_DBT_SCHEMA
```