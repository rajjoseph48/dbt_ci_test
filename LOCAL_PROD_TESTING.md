# Local Production Testing Guide

Since GitHub Actions cannot directly access your localhost, here's how to test against your local production database:

## 🎯 **Hybrid Testing Strategy**

### **Automated CI (GitHub Actions)**
- Uses PostgreSQL service container
- Tests all PRs automatically
- Isolated schemas per PR: `pr_123_analytics`

### **Production Testing (Local)**
- Manual testing against your localhost prod DB
- Pre-merge validation
- Final integration testing

## 🔧 **Local Production Testing Setup**

### **1. Configure Local Production Profile**
Add to your `profiles.yml`:

```yaml
ecommerce_analytics:
  target: dev
  outputs:
    # ... existing dev/staging configs ...
    
    local_prod:
      type: postgres
      host: localhost
      user: postgres
      password: your_prod_password
      port: 5432
      dbname: your_prod_database_name
      schema: analytics_prod_test
      threads: 4
      keepalives_idle: 0
```

### **2. Create Production Testing Commands**

```bash
# Test against local prod database
dbt run --target local_prod --select +my_changed_model
dbt test --target local_prod --select +my_changed_model

# Full production test
dbt seed --target local_prod
dbt run --target local_prod
dbt test --target local_prod
```

### **3. Pre-merge Production Validation Script**

Create `validate_prod.sh`:
```bash
#!/bin/bash
echo "🧪 Testing against local production database..."

# Set production target
export DBT_TARGET=local_prod

# Run only changed models and their dependencies
echo "Building models..."
dbt run --select state:modified+ --defer --state target/

echo "Running tests..."
dbt test --select state:modified+ --defer --state target/

echo "✅ Production validation complete!"
```

## 🚀 **Production Deployment Workflow**

### **For Feature Branches:**
1. **Develop**: Work on `feature/my-feature`
2. **CI Test**: Push → Automated CI runs (service container)
3. **Local Prod Test**: `dbt run --target local_prod` (manual)
4. **Create PR**: To main branch
5. **Review**: Code review + CI status checks
6. **Merge**: Auto-merge when approved + CI passes

### **For Main Branch:**
1. **Merge**: Feature PR merges to main
2. **CI Deploy**: Automated deployment (or manual to your localhost)
3. **Validation**: Final production checks

## 🏗 **Alternative: Self-Hosted Runner**

If you want GitHub Actions to access your localhost:

### **Setup Self-Hosted Runner**
```bash
# Download runner (GitHub Settings → Actions → Runners → New runner)
mkdir actions-runner && cd actions-runner
curl -o actions-runner-linux-x64-2.311.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-x64-2.311.0.tar.gz
tar xzf ./actions-runner-linux-x64-2.311.0.tar.gz

# Configure runner
./config.sh --url https://github.com/your-org/dbt_ci_test --token YOUR_TOKEN

# Run as service
sudo ./svc.sh install
sudo ./svc.sh start
```

### **Update Workflow for Self-Hosted**
```yaml
jobs:
  dbt_test:
    runs-on: [self-hosted, linux]  # Use your local runner
    # Remove PostgreSQL service (use your localhost instead)
```

## 🎛 **Database Schema Strategy**

### **Local Development**
- **Schema**: `analytics` (your main dev schema)

### **CI Testing** 
- **Schema**: `pr_123_analytics` (isolated per PR)

### **Local Prod Testing**
- **Schema**: `analytics_prod_test` (separate from live prod)

### **Production**
- **Schema**: `analytics_prod` (your actual production data)

## ⚡ **Quick Commands**

```bash
# Test current branch against local prod
dbt run --target local_prod --select state:modified+
dbt test --target local_prod --select state:modified+

# Compare CI vs Local results
dbt run --target dev        # CI-like environment
dbt run --target local_prod # Your prod environment

# Generate docs for prod testing
dbt docs generate --target local_prod
dbt docs serve
```

## 🔒 **Security Considerations**

### **For Self-Hosted Runner:**
- Run in isolated environment/VM
- Limit network access
- Regular security updates
- Monitor runner logs

### **For Local Testing:**
- Use separate test schema
- Backup before major changes
- Limit permissions for test user
- Never commit production credentials

## 📊 **Recommendation**

**Best Approach:**
1. ✅ Keep automated CI with PostgreSQL service (fast, isolated)
2. ✅ Add manual local prod testing step in your process
3. ✅ Use pre-merge validation script before merging
4. ✅ Consider self-hosted runner only if absolutely necessary

This gives you both automated testing AND production validation without security risks!