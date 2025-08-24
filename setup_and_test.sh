#!/bin/bash
echo "Starting dbt PostgreSQL setup and test..."
echo

echo "1. Starting PostgreSQL container..."
docker-compose up -d postgres
if [ $? -ne 0 ]; then
    echo "Error: Failed to start PostgreSQL container"
    exit 1
fi

echo
echo "2. Waiting for PostgreSQL to be ready..."
sleep 10

echo
echo "3. Testing database connection..."
docker exec dbt_postgres pg_isready -U postgres -d ecommerce
if [ $? -ne 0 ]; then
    echo "Error: PostgreSQL is not ready"
    exit 1
fi

echo
echo "4. Setting environment variables..."
if [ ! -f .env ]; then
    cp .env.example .env
    echo "Created .env file from template"
fi

echo
echo "5. Installing Python dependencies..."
pip install -r requirements.txt
if [ $? -ne 0 ]; then
    echo "Error: Failed to install dependencies"
    exit 1
fi

echo
echo "6. Installing dbt packages..."
dbt deps
if [ $? -ne 0 ]; then
    echo "Error: Failed to install dbt packages"
    exit 1
fi

echo
echo "7. Testing dbt connection..."
dbt debug
if [ $? -ne 0 ]; then
    echo "Error: dbt debug failed"
    exit 1
fi

echo
echo "8. Loading seed data..."
dbt seed
if [ $? -ne 0 ]; then
    echo "Error: Failed to load seed data"
    exit 1
fi

echo
echo "9. Running dbt models..."
dbt run
if [ $? -ne 0 ]; then
    echo "Error: Failed to run dbt models"
    exit 1
fi

echo
echo "10. Running dbt tests..."
dbt test
if [ $? -ne 0 ]; then
    echo "Warning: Some tests failed, but continuing..."
fi

echo
echo "========================================"
echo "Setup completed successfully!"
echo "========================================"
echo
echo "You can now:"
echo "- Access pgAdmin at: http://localhost:8080"
echo "- Connect to PostgreSQL at: localhost:5432"
echo "- Database: ecommerce, User: postgres, Password: postgres"
echo
echo "To view documentation: dbt docs generate && dbt docs serve"
echo "To stop database: docker-compose down"
echo