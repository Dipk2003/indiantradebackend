#!/bin/sh
# =============================================================================
# iTech Backend - Docker Entry Point Script
# =============================================================================

set -e

echo "🚀 Starting iTech Backend Application..."

# Wait for database if DATABASE_URL is provided
if [ -n "$DATABASE_URL" ]; then
    echo "📍 Waiting for database connection..."
    
    # Extract host and port from DATABASE_URL
    DB_HOST=$(echo $DATABASE_URL | sed -n 's/.*:\/\/.*@\([^:]*\):.*/\1/p')
    DB_PORT=$(echo $DATABASE_URL | sed -n 's/.*:\([0-9]*\)\/.*/\1/p')
    
    if [ -n "$DB_HOST" ] && [ -n "$DB_PORT" ]; then
        echo "🔍 Checking database connectivity to $DB_HOST:$DB_PORT"
        
        # Wait for database to be available (max 60 seconds)
        timeout=60
        while ! nc -z "$DB_HOST" "$DB_PORT" 2>/dev/null; do
            echo "⏳ Waiting for database at $DB_HOST:$DB_PORT..."
            sleep 2
            timeout=$((timeout - 2))
            if [ $timeout -le 0 ]; then
                echo "⚠️  Database connection timeout. Proceeding anyway..."
                break
            fi
        done
        
        if nc -z "$DB_HOST" "$DB_PORT" 2>/dev/null; then
            echo "✅ Database is ready!"
        fi
    fi
fi

# Wait for Redis if REDIS_HOST is provided
if [ -n "$REDIS_HOST" ]; then
    REDIS_PORT=${REDIS_PORT:-6379}
    echo "🔍 Checking Redis connectivity to $REDIS_HOST:$REDIS_PORT"
    
    timeout=30
    while ! nc -z "$REDIS_HOST" "$REDIS_PORT" 2>/dev/null; do
        echo "⏳ Waiting for Redis at $REDIS_HOST:$REDIS_PORT..."
        sleep 2
        timeout=$((timeout - 2))
        if [ $timeout -le 0 ]; then
            echo "⚠️  Redis connection timeout. Proceeding anyway..."
            break
        fi
    done
    
    if nc -z "$REDIS_HOST" "$REDIS_PORT" 2>/dev/null; then
        echo "✅ Redis is ready!"
    fi
fi

# Set up JVM options
JAVA_OPTS="${JAVA_OPTS} -Djava.security.egd=file:/dev/./urandom"
JAVA_OPTS="${JAVA_OPTS} -Dspring.profiles.active=${SPRING_PROFILES_ACTIVE:-production}"

# Health check endpoint info
echo "🏥 Health check will be available at: http://localhost:${SERVER_PORT:-8080}/actuator/health"

# Log application startup
echo "🎯 Application Profile: ${SPRING_PROFILES_ACTIVE:-production}"
echo "🚪 Application Port: ${SERVER_PORT:-8080}"
echo "☕ Java Options: $JAVA_OPTS"

# Start the application
echo "🎉 Launching iTech Backend..."
exec java $JAVA_OPTS -jar app.jar "$@"
