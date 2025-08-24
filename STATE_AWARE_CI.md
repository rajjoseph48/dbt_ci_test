# State-Aware dbt CI Pipeline

This implementation uses dbt's state comparison features to run only modified models and their downstream dependencies, making it perfect for large dbt projects.

## 🎯 **How State Comparison Works**

### **First PR (No Previous State)**
```
📦 No artifacts from main branch
⚠️  Fallback: Run all models
✅ Upload artifacts for future comparisons
```

### **Subsequent PRs (With State)**
```
📥 Download artifacts from main branch
📊 Compare current code vs main branch state
🎯 Run only: state:modified+ (changed models + downstream)
✅ Much faster builds for large projects
```

## 🔄 **Workflow Steps**

### **For Pull Requests:**
1. **Download State**: Get latest artifacts from main branch
2. **State Comparison**: Identify modified models using `state:modified+`
3. **Smart Build**: Run only changed models + downstream dependencies
4. **Smart Test**: Test only affected models
5. **Upload Artifacts**: Save current state for future comparisons

### **For Main Branch:**
1. **Full Build**: Run all models (no state comparison needed)
2. **Full Test**: Run all tests
3. **Upload Artifacts**: Save canonical state for PRs to compare against

## 🚀 **Performance Benefits**

### **Large Project Example (100+ models):**

**Without State Awareness:**
- Every PR: Build all 100+ models
- Time: 15-30 minutes
- Resources: High

**With State Awareness:**
- Changed 1 staging model: Build 1 + 5 downstream = 6 models
- Changed 1 mart model: Build 1 model = 1 model  
- Time: 2-5 minutes
- Resources: Low

## 📊 **State Selection Examples**

### **Modified Staging Model:**
```bash
# You changed: models/staging/stg_customers.sql
# dbt runs:
- stg_customers (modified)
- int_customer_orders (depends on stg_customers)  
- dim_customers (depends on int_customer_orders)
- fct_orders (depends on int_customer_orders)
```

### **Modified Mart Model:**
```bash  
# You changed: models/marts/dim_customers.sql
# dbt runs:
- dim_customers (modified only)
```

### **New Model Added:**
```bash
# You added: models/marts/new_analysis.sql
# dbt runs:
- new_analysis (new model)
```

## 🛠 **Implementation Details**

### **Artifact Download:**
```yaml
- name: Download main branch artifacts
  uses: dawidd6/action-download-artifact@v3
  with:
    workflow: dbt_ci.yml
    branch: main
    name: dbt-artifacts-dev
    path: ./state/
    if_no_artifact_found: ignore
```

### **State-Aware dbt Commands:**
```bash
# Check for previous state
if [ -d "./state/target" ]; then
  # Use state comparison
  dbt run --select state:modified+ --defer --state ./state/target/
else
  # Fallback to all models
  dbt run
fi
```

### **Key dbt Flags:**
- `--select state:modified+`: Modified models + downstream dependencies
- `--defer`: Use production references for unbuilt upstream models
- `--state ./state/target/`: Path to previous state artifacts

## 🔍 **Debugging State Issues**

### **Check Downloaded Artifacts:**
```bash
# In CI logs, look for:
📥 Downloading artifacts from main branch...
📂 ./state/target/manifest.json exists
📊 State comparison will be used
```

### **No State Found:**
```bash
⚠️ No previous state found, running all models...
# This is normal for:
# - First PR in new repository
# - Main branch hasn't run successfully yet
```

### **State Comparison Working:**
```bash
📊 Running modified models and downstream dependencies...
# Should see fewer models than total project
```

## 📈 **Scaling Benefits**

| Project Size | Without State | With State | Savings |
|-------------|---------------|------------|---------|
| 10 models   | 2 min        | 2 min      | 0%      |
| 50 models   | 8 min        | 3 min      | 60%     |
| 200 models  | 25 min       | 5 min      | 80%     |
| 500 models  | 60 min       | 8 min      | 87%     |

## 🎛 **Configuration Options**

### **More Selective (Faster):**
```bash
# Only modified models (no downstream)
--select state:modified

# Only direct children  
--select state:modified+1
```

### **More Inclusive (Safer):**
```bash
# Modified + all downstream + tests
--select state:modified+ --select test_type:data

# Include upstream dependencies too
--select +state:modified+
```

## 🚦 **Best Practices**

### **For Development:**
1. ✅ Always have a successful main branch build first
2. ✅ Use meaningful commit messages for better debugging
3. ✅ Test state selectors locally: `dbt ls --select state:modified+`

### **For Large Projects:**
1. ✅ Consider more granular selection strategies
2. ✅ Monitor CI performance and adjust selectors
3. ✅ Use `--exclude` for expensive models during development

### **Troubleshooting:**
1. ✅ Check main branch has successful artifact uploads
2. ✅ Verify artifact download logs in PR
3. ✅ Test locally with: `dbt run --select state:modified+ --state ./state/`

This state-aware approach makes the CI pipeline scale efficiently with project size while maintaining safety through comprehensive downstream testing! 🎯