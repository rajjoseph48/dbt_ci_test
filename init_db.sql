-- Initialize the database with required schemas and permissions
-- This file is automatically executed when the container starts

-- Create schemas for different environments
CREATE SCHEMA IF NOT EXISTS analytics;
CREATE SCHEMA IF NOT EXISTS analytics_staging;

-- Grant permissions to postgres user
GRANT ALL PRIVILEGES ON SCHEMA analytics TO postgres;
GRANT ALL PRIVILEGES ON SCHEMA analytics_staging TO postgres;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA analytics TO postgres;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA analytics_staging TO postgres;

-- Create a sample raw data schema (optional - for demonstration)
CREATE SCHEMA IF NOT EXISTS raw_data;
GRANT ALL PRIVILEGES ON SCHEMA raw_data TO postgres;

-- Set default privileges for future tables
ALTER DEFAULT PRIVILEGES IN SCHEMA analytics GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES IN SCHEMA analytics_staging GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES IN SCHEMA raw_data GRANT ALL ON TABLES TO postgres;

-- Log successful initialization
\echo 'Database initialization completed successfully!'