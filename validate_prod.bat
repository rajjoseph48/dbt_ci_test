@echo off
echo 🧪 Testing against local production database...
echo.

echo Setting production target...
set DBT_TARGET=local_prod

echo.
echo Building models...
dbt run --select state:modified+ --defer --state target/
if errorlevel 1 (
    echo ❌ Model build failed
    exit /b 1
)

echo.
echo Running tests...
dbt test --select state:modified+ --defer --state target/
if errorlevel 1 (
    echo ❌ Tests failed
    exit /b 1
)

echo.
echo ✅ Production validation complete!
echo You can now safely merge your PR.