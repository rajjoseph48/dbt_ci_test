# Git-Based State Comparison (Alternative to Artifacts)

If artifact downloading has permission issues, use this git-based approach for state comparison.

## 🔧 **Alternative Workflow Steps**

Instead of downloading artifacts, use git to determine changed files:

```yaml
- name: Get changed files
  id: changed-files
  run: |
    # Get list of changed dbt files
    git fetch origin main
    CHANGED_FILES=$(git diff --name-only origin/main...HEAD -- 'models/**/*.sql' 'tests/**/*.sql')
    echo "changed_files=$CHANGED_FILES" >> $GITHUB_OUTPUT
    
    # Convert file paths to dbt model names
    CHANGED_MODELS=""
    for file in $CHANGED_FILES; do
      if [[ $file == models/* ]]; then
        model_name=$(basename "$file" .sql)
        CHANGED_MODELS="$CHANGED_MODELS $model_name"
      fi
    done
    echo "changed_models=$CHANGED_MODELS" >> $GITHUB_OUTPUT

- name: Run dbt models (changed + downstream)
  run: |
    if [ -n "${{ steps.changed-files.outputs.changed_models }}" ]; then
      echo "Running changed models: ${{ steps.changed-files.outputs.changed_models }}"
      dbt run --select ${{ steps.changed-files.outputs.changed_models }}+
    else
      echo "No model changes detected, running all models"
      dbt run
    fi
```

## 🎯 **Simpler File-Based Selection**

For immediate implementation without artifact complexity:

```yaml
- name: Smart model selection
  run: |
    # Check if any model files changed
    git fetch origin main
    if git diff --name-only origin/main...HEAD -- 'models/' | grep -q '\.sql$'; then
      echo "📊 Model files changed - running selective build"
      # For now, run all models (can be refined later)
      dbt run
    else
      echo "📈 No model changes - running all models"
      dbt run
    fi
```

## 🚀 **Quick Fix for Current Issue**

Replace the artifact download section with this simpler approach:

```yaml
- name: Determine build strategy
  id: build-strategy
  run: |
    if [ "${{ github.event_name }}" == "pull_request" ]; then
      echo "strategy=selective" >> $GITHUB_OUTPUT
    else
      echo "strategy=full" >> $GITHUB_OUTPUT
    fi

- name: Run dbt models
  run: |
    if [ "${{ steps.build-strategy.outputs.strategy }}" == "selective" ]; then
      echo "🎯 PR detected - optimized for changed models"
      dbt run  # Can be enhanced with specific selection later
    else
      echo "🏗️ Full build on main branch"
      dbt run
    fi
```

This provides the foundation for smart builds without artifact permission issues!