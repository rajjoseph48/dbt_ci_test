#!/usr/bin/env python3
"""
Quick test to verify profiles.yml can be parsed without environment variables
"""

import os
import tempfile
import subprocess

def test_dbt_debug():
    """Test that dbt debug works without required environment variables"""
    
    # Clear potentially problematic env vars
    env_vars_to_clear = ['DBT_HOST', 'DBT_USER', 'DBT_PASSWORD', 'DBT_DATABASE', 'DBT_PORT', 'DBT_SCHEMA']
    test_env = os.environ.copy()
    
    for var in env_vars_to_clear:
        test_env.pop(var, None)  # Remove if exists
    
    # Set minimal required env vars for the test
    test_env['DBT_PROFILES_DIR'] = '.'
    
    try:
        result = subprocess.run(
            ['dbt', 'debug', '--profiles-dir', '.'], 
            env=test_env,
            capture_output=True, 
            text=True,
            timeout=30
        )
        
        print("dbt debug output:")
        print(result.stdout)
        
        if result.stderr:
            print("dbt debug errors:")
            print(result.stderr)
        
        if result.returncode == 0:
            print("✅ dbt debug succeeded - profiles.yml is valid!")
            return True
        else:
            print(f"❌ dbt debug failed with return code {result.returncode}")
            return False
            
    except subprocess.TimeoutExpired:
        print("❌ dbt debug timed out")
        return False
    except FileNotFoundError:
        print("❌ dbt command not found - make sure dbt is installed")
        return False

if __name__ == "__main__":
    success = test_dbt_debug()
    exit(0 if success else 1)