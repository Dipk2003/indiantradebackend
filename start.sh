#!/bin/bash

# Startup script for itech-backend on Render.com
echo "Starting itech-backend application..."

# Create necessary directories
mkdir -p /app/uploads
mkdir -p /app/logs

# Set JVM options based on available memory
if [ -z "$JAVA_OPTS" ]; then
    JAVA_OPTS="-Xmx512m -Xms256m -XX:+UseG1GC -XX:+UseStringDeduplication"
fi

# Add additional JVM options for production
JAVA_OPTS="$JAVA_OPTS -Djava.security.egd=file:/dev/./urandom"
JAVA_OPTS="$JAVA_OPTS -Dspring.profiles.active=production"
JAVA_OPTS="$JAVA_OPTS -Dserver.port=${PORT:-8080}"

# Log startup information
echo "Java Options: $JAVA_OPTS"
echo "Spring Profile: $SPRING_PROFILES_ACTIVE"
echo "Port: ${PORT:-8080}"
echo "Database URL: ${DATABASE_URL:-not_set}"

# Start the application
exec java $JAVA_OPTS -jar /app/app.jar
