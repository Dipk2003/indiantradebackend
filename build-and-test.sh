#!/bin/bash

# Build and test script for Docker deployment
echo "🚀 Building itech-backend Docker image..."

# Build the Docker image
docker build -t itech-backend:latest .

if [ $? -eq 0 ]; then
    echo "✅ Docker image built successfully!"
    
    # Test the image locally
    echo "🧪 Testing the Docker image..."
    docker run -d --name itech-backend-test \
        -p 8080:8080 \
        -e SPRING_PROFILES_ACTIVE=production \
        -e DATABASE_URL=jdbc:h2:mem:testdb \
        -e DB_USERNAME=sa \
        -e DB_PASSWORD= \
        -e JWT_SECRET=test-secret-key-for-local-testing \
        itech-backend:latest
    
    # Wait for the application to start
    echo "⏳ Waiting for application to start..."
    sleep 30
    
    # Test the health endpoint
    echo "🔍 Testing health endpoint..."
    curl -f http://localhost:8080/actuator/health
    
    if [ $? -eq 0 ]; then
        echo "✅ Health check passed!"
    else
        echo "❌ Health check failed!"
    fi
    
    # Show container logs
    echo "📋 Container logs:"
    docker logs itech-backend-test
    
    # Cleanup
    echo "🧹 Cleaning up..."
    docker stop itech-backend-test
    docker rm itech-backend-test
    
    echo "🎉 Build and test completed!"
else
    echo "❌ Docker build failed!"
    exit 1
fi
