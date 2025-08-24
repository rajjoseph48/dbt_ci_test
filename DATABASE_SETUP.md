# PostgreSQL Database Setup Guide

## 🚀 Quick Start with Docker (Recommended)

### Prerequisites
- Docker and Docker Compose installed
- Git (to clone the repository)

### 1. Start the Database
```bash
# Navigate to project directory
cd dbt_ci_test

# Start PostgreSQL and pgAdmin
docker-compose up -d

# Check if containers are running
docker-compose ps
```

### 2. Verify Database Connection
```bash
# Test connection
docker exec -it dbt_postgres psql -U postgres -d ecommerce -c "SELECT version();"

# Should output PostgreSQL version information
```

### 3. Set Environment Variables
```bash
# Copy environment template
cp .env.example .env

# The defaults work with Docker setup:
# DBT_HOST=localhost
# DBT_USER=postgres  
# DBT_PASSWORD=postgres
# DBT_DATABASE=ecommerce
```

### 4. Test dbt Connection
```bash
# Install Python dependencies
pip install -r requirements.txt

# Install dbt packages
dbt deps

# Test connection
dbt debug

# Should show "All checks passed!"
```

## 🗃 Database Access Options

### Option 1: Command Line
```bash
# Connect via docker exec
docker exec -it dbt_postgres psql -U postgres -d ecommerce

# List schemas
\dn

# Switch to analytics schema
\c ecommerce
SET search_path TO analytics;
```

### Option 2: pgAdmin Web Interface
- **URL**: http://localhost:8080
- **Email**: admin@example.com  
- **Password**: admin

#### Add Server in pgAdmin:
1. Right-click "Servers" → "Create" → "Server"
2. **Name**: "dbt_postgres"
3. **Connection Tab**:
   - Host: `postgres` (container name)
   - Port: `5432`
   - Database: `ecommerce`
   - Username: `postgres` 
   - Password: `postgres`

### Option 3: External Tools
Connect using any PostgreSQL client:
- **Host**: localhost
- **Port**: 5432
- **Database**: ecommerce
- **Username**: postgres
- **Password**: postgres

## 🛠 Alternative Setup Options

### Option A: Local PostgreSQL Installation

#### Windows (using Chocolatey)
```bash
choco install postgresql
# Follow installation prompts
```

#### macOS (using Homebrew)
```bash
brew install postgresql
brew services start postgresql
```

#### Ubuntu/Debian
```bash
sudo apt update
sudo apt install postgresql postgresql-contrib
sudo systemctl start postgresql
```

#### Create Database and User
```sql
-- Connect as superuser
sudo -u postgres psql

-- Create database
CREATE DATABASE ecommerce;

-- Create user (optional)
CREATE USER dbt_user WITH PASSWORD 'your_password';
GRANT ALL PRIVILEGES ON DATABASE ecommerce TO dbt_user;

-- Create schemas
\c ecommerce;
CREATE SCHEMA analytics;
CREATE SCHEMA analytics_staging;
GRANT ALL ON SCHEMA analytics TO dbt_user;
GRANT ALL ON SCHEMA analytics_staging TO dbt_user;
```

### Option B: Cloud PostgreSQL

#### ElephantSQL (Free Tier)
1. Sign up at https://www.elephantsql.com/
2. Create a "Tiny Turtle" free instance
3. Note connection details
4. Update `.env` with provided credentials

#### AWS RDS PostgreSQL
1. Create RDS PostgreSQL instance
2. Configure security groups for access
3. Update `.env` with RDS endpoint

#### Google Cloud SQL
1. Create Cloud SQL PostgreSQL instance
2. Configure authorized networks
3. Update `.env` with instance details

## 🧪 Testing Your Setup

### 1. Run dbt Commands
```bash
# Load seed data
dbt seed

# Run models
dbt run

# Run tests
dbt test

# Generate documentation
dbt docs generate
dbt docs serve
```

### 2. Verify Data
```sql
-- Connect to database
psql -h localhost -U postgres -d ecommerce

-- Check tables were created
\dt analytics.*

-- View customer data
SELECT * FROM analytics.dim_customers LIMIT 5;

-- View order data  
SELECT * FROM analytics.fct_orders LIMIT 5;
```

## 🔧 Troubleshooting

### Common Issues

#### Connection Refused
```bash
# Check if PostgreSQL is running
docker-compose ps

# View logs
docker-compose logs postgres

# Restart if needed
docker-compose restart postgres
```

#### Permission Denied
```sql
-- Grant additional permissions
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA analytics TO postgres;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA analytics TO postgres;
```

#### Port Already in Use
```bash
# Find process using port 5432
netstat -tulpn | grep 5432

# Kill process or change port in docker-compose.yml
```

#### dbt Connection Issues
```bash
# Debug connection
dbt debug

# Check profiles.yml location
echo $DBT_PROFILES_DIR

# Verify environment variables
echo $DBT_HOST $DBT_USER $DBT_DATABASE
```

### Reset Database
```bash
# Stop containers and remove volumes
docker-compose down -v

# Remove all data and restart fresh
docker-compose up -d
```

## 📊 Schema Structure

After successful setup, your database will have:

```
ecommerce (database)
├── analytics (schema)
│   ├── dim_customers
│   ├── fct_orders
│   └── [seed tables]
├── analytics_staging (schema)
│   └── [for staging environment]
└── public (default schema)
    └── [raw seed data]
```

## 🔐 Security Notes

### For Production:
- Change default passwords
- Use environment-specific credentials
- Configure SSL connections
- Restrict network access
- Enable logging and monitoring

### For Development:
- The Docker setup uses default credentials for simplicity
- Don't expose port 5432 publicly
- Use `.env` files for local configuration (not committed to git)

## 📝 Next Steps

Once your database is running:

1. ✅ **Test dbt connection**: `dbt debug`
2. ✅ **Load sample data**: `dbt seed`
3. ✅ **Build models**: `dbt run`
4. ✅ **Run tests**: `dbt test`
5. ✅ **Create feature branch**: `git checkout -b feature/test-setup`
6. ✅ **Push to GitHub**: Test the CI pipeline

You're now ready to use the improved dbt workflow! 🎉