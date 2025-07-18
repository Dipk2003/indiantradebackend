#!/bin/bash

echo "Testing minimal database connection..."
echo "Environment Variables:"
echo "JDBC_DATABASE_URL: $JDBC_DATABASE_URL"
echo "JDBC_DATABASE_USERNAME: $JDBC_DATABASE_USERNAME"
echo "JDBC_DATABASE_PASSWORD: [HIDDEN]"
echo "SPRING_PROFILES_ACTIVE: $SPRING_PROFILES_ACTIVE"
echo ""

# Test basic connection using psql if available
if command -v psql &> /dev/null; then
    echo "Testing PostgreSQL connection with psql..."
    # Extract connection details from JDBC URL
    # Format: postgresql://username:password@host:port/database
    if [[ $JDBC_DATABASE_URL =~ postgresql://([^:]+):([^@]+)@([^:]+):([^/]+)/(.+) ]]; then
        HOST="${BASH_REMATCH[3]}"
        PORT="${BASH_REMATCH[4]}"
        DB="${BASH_REMATCH[5]}"
        
        echo "Host: $HOST"
        echo "Port: $PORT"
        echo "Database: $DB"
        
        # Test connection
        PGPASSWORD="$JDBC_DATABASE_PASSWORD" psql -h "$HOST" -p "$PORT" -d "$DB" -U "$JDBC_DATABASE_USERNAME" -c "SELECT 1 as test_connection;" --set=sslmode=require
        
        if [ $? -eq 0 ]; then
            echo "✅ Database connection successful!"
        else
            echo "❌ Database connection failed!"
        fi
    else
        echo "❌ Could not parse DATABASE_URL format"
    fi
else
    echo "psql not available, skipping direct connection test"
fi

echo ""
echo "Next steps:"
echo "1. Ensure SPRING_PROFILES_ACTIVE=render is set in Render"
echo "2. Verify all environment variables are properly set"
echo "3. Check Render logs for any remaining issues"
