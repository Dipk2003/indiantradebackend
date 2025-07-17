# PostgreSQL Column Issue Fix Guide

## Problem
Error: `org.postgresql.util.PSQLException: ERROR: column u1_0.id does not exist`

## Root Cause
The error occurs because:
1. PostgreSQL is case-sensitive with table names
2. The word "user" is a reserved keyword in PostgreSQL
3. Hibernate generates table aliases that don't match the actual table structure

## Solutions Applied

### 1. Fixed Table Name in Entity
- Updated `@Table(name = "user")` to `@Table(name = "\"user\"")` in User.java
- This ensures the table name is properly quoted in PostgreSQL

### 2. Updated Database Configuration
- Added PostgreSQL-specific settings in application-production.properties:
  ```properties
  spring.jpa.properties.hibernate.globally_quoted_identifiers=true
  spring.jpa.properties.hibernate.physical_naming_strategy=org.hibernate.boot.model.naming.CamelCaseToUnderscoresNamingStrategy
  spring.jpa.properties.hibernate.implicit_naming_strategy=org.hibernate.boot.model.naming.ImplicitNamingStrategyJpaCompliantImpl
  ```

### 3. Added Database Migration
- Created Flyway migration script: `V1__Create_user_table.sql`
- Ensures the table structure matches the entity definition
- Includes proper indexes for performance

### 4. Enhanced DatabaseConfig
- Added `sslmode=require` for PostgreSQL connections
- Improved connection pooling settings

### 5. Added Flyway Dependencies
- Added flyway-core and flyway-database-postgresql dependencies
- Configured Flyway for automatic migrations

## Testing the Fix

1. **Build the application:**
   ```bash
   ./mvnw clean compile
   ```

2. **Test with production profile:**
   ```bash
   ./mvnw spring-boot:run -Dspring-boot.run.profiles=production
   ```

3. **Check logs for any SQL errors**

## Deployment Steps

1. **Build the application:**
   ```bash
   ./mvnw clean package -DskipTests
   ```

2. **Deploy to Render:**
   - The application will automatically run migrations on startup
   - Check logs for successful table creation

## Additional Troubleshooting

### If the issue persists:

1. **Check database connection:**
   ```sql
   SELECT current_database(), current_user;
   ```

2. **Verify table exists:**
   ```sql
   SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';
   ```

3. **Check table structure:**
   ```sql
   \d "user"
   ```

4. **Enable SQL logging temporarily:**
   ```properties
   spring.jpa.show-sql=true
   logging.level.org.hibernate.SQL=DEBUG
   ```

### Manual Table Creation (if needed):

```sql
CREATE TABLE IF NOT EXISTS "user" (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(255) UNIQUE,
    password VARCHAR(255) NOT NULL,
    verified BOOLEAN DEFAULT FALSE,
    is_verified BOOLEAN DEFAULT FALSE,
    role VARCHAR(50) DEFAULT 'ROLE_USER',
    business_name VARCHAR(255),
    business_address TEXT,
    gst_number VARCHAR(50),
    pan_number VARCHAR(50),
    vendor_type VARCHAR(50) DEFAULT 'BASIC',
    department VARCHAR(255),
    designation VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE
);
```

## Notes
- Always use quoted identifiers for reserved keywords in PostgreSQL
- Ensure proper Hibernate naming strategies are configured
- Use Flyway for database migrations to maintain consistency
- Monitor logs during deployment for any migration issues
