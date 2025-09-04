#!/bin/bash

# =============================================================================
# iTech Backend - AWS Elastic Beanstalk Deployment Script
# =============================================================================

set -e

echo "🚀 Starting AWS Backend Deployment..."

# Build the application
echo "📦 Building Spring Boot application..."
./mvnw clean package -DskipTests -Pproduction

# Create deployment directory
mkdir -p deployment-backend
cd deployment-backend

# Copy JAR file
cp ../target/*.jar application.jar

# Create Dockerfile for AWS
cat > Dockerfile << EOF
FROM openjdk:21-jdk-slim

# Install curl for health checks
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy JAR file
COPY application.jar app.jar

# Expose port
EXPOSE 8080

# Set JVM options for AWS
ENV JAVA_OPTS="-Xmx1g -Xms512m -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -server"

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/actuator/health || exit 1

# Start application
ENTRYPOINT ["sh", "-c", "java \$JAVA_OPTS -jar app.jar"]
EOF

# Create Dockerrun.aws.json for Elastic Beanstalk
cat > Dockerrun.aws.json << EOF
{
  "AWSEBDockerrunVersion": "1",
  "Image": {
    "Name": "itech-backend",
    "Update": "true"
  },
  "Ports": [
    {
      "ContainerPort": "8080"
    }
  ],
  "Logging": "/var/log/itech-backend"
}
EOF

echo "✅ Backend deployment files ready!"
echo "📁 Files created in: deployment-backend/"

cd ..
