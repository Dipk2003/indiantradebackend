#!/bin/bash

# iTech Backend - AWS Elastic Beanstalk Deployment Script
# This script builds and deploys the Spring Boot application to AWS Elastic Beanstalk

echo "🚀 Starting iTech Backend Deployment to AWS Elastic Beanstalk..."

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI not found. Please install AWS CLI first."
    exit 1
fi

# Check if EB CLI is installed
if ! command -v eb &> /dev/null; then
    echo "❌ EB CLI not found. Please install EB CLI first."
    echo "Run: pip install awsebcli"
    exit 1
fi

# Set deployment profile
export SPRING_PROFILES_ACTIVE=aws-prod

# Clean and build the application
echo "📦 Building application..."
./mvnw clean package -DskipTests

# Check if build was successful
if [ $? -ne 0 ]; then
    echo "❌ Build failed. Please fix build errors before deploying."
    exit 1
fi

# Check if JAR file exists
JAR_FILE="target/itech-backend-1.0.0.jar"
if [ ! -f "$JAR_FILE" ]; then
    echo "❌ JAR file not found at $JAR_FILE"
    exit 1
fi

echo "✅ Build successful. JAR file: $JAR_FILE"

# Create deployment package
echo "📦 Creating deployment package..."
mkdir -p deploy
cp $JAR_FILE deploy/application.jar
cp Procfile deploy/ 2>/dev/null || echo "Procfile not found, will use default"
cp -r .ebextensions deploy/ 2>/dev/null || echo ".ebextensions not found"

# Initialize EB application if not already done
if [ ! -d ".elasticbeanstalk" ]; then
    echo "🔧 Initializing Elastic Beanstalk application..."
    eb init -p "Corretto 17" itech-backend --region us-west-2
fi

# Deploy to environment
echo "🚀 Deploying to Elastic Beanstalk..."
eb deploy

# Check deployment status
if [ $? -eq 0 ]; then
    echo "✅ Deployment successful!"
    echo "🌐 Getting application URL..."
    eb status
    echo ""
    echo "🎉 Your application is now live!"
    echo "📊 You can monitor your application at: https://console.aws.amazon.com/elasticbeanstalk/"
else
    echo "❌ Deployment failed. Check the logs for more details:"
    echo "eb logs"
    exit 1
fi

# Clean up
rm -rf deploy

echo "✅ Deployment script completed!"
