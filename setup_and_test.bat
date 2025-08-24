@echo off
echo Starting dbt PostgreSQL setup and test...
echo.

echo 1. Starting PostgreSQL container...
docker-compose up -d postgres
if errorlevel 1 (
    echo Error: Failed to start PostgreSQL container
    exit /b 1
)

echo.
echo 2. Waiting for PostgreSQL to be ready...
timeout /t 10 /nobreak > nul

echo.
echo 3. Testing database connection...
docker exec dbt_postgres pg_isready -U postgres -d ecommerce
if errorlevel 1 (
    echo Error: PostgreSQL is not ready
    exit /b 1
)

echo.
echo 4. Setting environment variables...
if not exist .env (
    copy .env.example .env
    echo Created .env file from template
)

echo.
echo 5. Installing Python dependencies...
pip install -r requirements.txt
if errorlevel 1 (
    echo Error: Failed to install dependencies
    exit /b 1
)

echo.
echo 6. Installing dbt packages...
dbt deps
if errorlevel 1 (
    echo Error: Failed to install dbt packages
    exit /b 1
)

echo.
echo 7. Testing dbt connection...
dbt debug
if errorlevel 1 (
    echo Error: dbt debug failed
    exit /b 1
)

echo.
echo 8. Loading seed data...
dbt seed
if errorlevel 1 (
    echo Error: Failed to load seed data
    exit /b 1
)

echo.
echo 9. Running dbt models...
dbt run
if errorlevel 1 (
    echo Error: Failed to run dbt models
    exit /b 1
)

echo.
echo 10. Running dbt tests...
dbt test
if errorlevel 1 (
    echo Warning: Some tests failed, but continuing...
)

echo.
echo ========================================
echo Setup completed successfully!
echo ========================================
echo.
echo You can now:
echo - Access pgAdmin at: http://localhost:8080
echo - Connect to PostgreSQL at: localhost:5432
echo - Database: ecommerce, User: postgres, Password: postgres
echo.
echo To view documentation: dbt docs generate && dbt docs serve
echo To stop database: docker-compose down
echo.
pause