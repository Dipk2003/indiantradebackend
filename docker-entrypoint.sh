#!/bin/sh

# =============================================================================
# iTech Backend - Docker Entrypoint Script
# =============================================================================

set -e

echo "🚀 Starting iTech Backend Application..."
echo "Profile: ${SPRING_PROFILES_ACTIVE:-development}"
echo "Java Version: $(java -version 2>&1 | head -n 1)"

# Wait for database to be ready (if DATABASE_HOST is provided)
if [ -n "$DATABASE_HOST" ] && [ -n "$DATABASE_PORT" ]; then
    echo "⏳ Waiting for database at ${DATABASE_HOST}:${DATABASE_PORT}..."
    
    # Wait up to 60 seconds for database
    timeout=60
    while ! nc -z "$DATABASE_HOST" "$DATABASE_PORT" && [ $timeout -gt 0 ]; do
        echo "Database not ready, waiting..."
        sleep 2
        timeout=$((timeout - 2))
    done
    
    if [ $timeout -le 0 ]; then
        echo "❌ Database connection timeout after 60 seconds"
        exit 1
    fi
    
    echo "✅ Database is ready!"
fi

# Wait for Redis to be ready (if REDIS_HOST is provided)
if [ -n "$REDIS_HOST" ] && [ -n "$REDIS_PORT" ]; then
    echo "⏳ Waiting for Redis at ${REDIS_HOST}:${REDIS_PORT}..."
    
    timeout=30
    while ! nc -z "$REDIS_HOST" "$REDIS_PORT" && [ $timeout -gt 0 ]; do
        echo "Redis not ready, waiting..."
        sleep 1
        timeout=$((timeout - 1))
    done
    
    if [ $timeout -le 0 ]; then
        echo "⚠️ Redis connection timeout after 30 seconds (continuing without Redis)"
    else
        echo "✅ Redis is ready!"
    fi
fi

# Set default JVM options if not provided
if [ -z "$JAVA_OPTS" ]; then
    export JAVA_OPTS="-Xmx1g -Xms512m -XX:+UseG1GC -XX:MaxGCPauseMillis=200"
fi

# Print memory information
echo "📊 Memory Information:"
echo "Total Memory: $(free -h | awk '/^Mem:/ {print $2}')"
echo "Available Memory: $(free -h | awk '/^Mem:/ {print $7}')"
echo "JVM Options: $JAVA_OPTS"

# Create logs directory if it doesn't exist
mkdir -p /app/logs

# Start the application
echo "🏃 Starting Spring Boot application..."
exec java $JAVA_OPTS -jar /app/app.jar "$@"
