#!/bin/bash

# Render startup script for Indian Trade Mart Backend
# This script ensures proper port binding and configuration for Render deployment

set -euo pipefail

echo "🚀 Starting Indian Trade Mart Backend on Render..."
echo "📊 Memory limit: 512MB, JVM max heap: 200MB"
echo "🌐 Port: ${PORT:-8080}"
echo "🏷️ Profile: ${SPRING_PROFILES_ACTIVE:-minimal}"

# Set JVM memory options optimized for Render 512MB limit
export JAVA_OPTS="${JAVA_OPTS:--Xmx200m -Xms32m -XX:+UseSerialGC -XX:MaxDirectMemorySize=32m -XX:MaxMetaspaceSize=128m -XX:CompressedClassSpaceSize=32m -XX:ReservedCodeCacheSize=32m -XX:+UseCompressedOops -XX:+UseCompressedClassPointers -Djava.awt.headless=true -XX:+TieredCompilation -XX:TieredStopAtLevel=1 -Dspring.jmx.enabled=false -Dfile.encoding=UTF-8 -Djava.security.egd=file:/dev/./urandom}"

# Ensure the PORT environment variable is properly set
export SERVER_PORT="${PORT:-8080}"

echo "🔧 Java Options: $JAVA_OPTS"
echo "⚙️  Server Port: $SERVER_PORT"

# Start the application with explicit port binding
exec java $JAVA_OPTS \
    -Dserver.port="$SERVER_PORT" \
    -Dserver.address=0.0.0.0 \
    -Dspring.profiles.active="${SPRING_PROFILES_ACTIVE:-minimal}" \
    -jar app.jar
