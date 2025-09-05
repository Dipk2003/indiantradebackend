#!/bin/bash

# =============================================================================
# iTech Backend Deployment via CloudShell
# =============================================================================

echo "🚀 Starting iTech Backend Deployment..."
echo "======================================="

# Set region
export AWS_DEFAULT_REGION=ap-south-1

# Create deployment directory
mkdir -p /tmp/itech-deployment
cd /tmp/itech-deployment

echo "📦 Creating deployment package..."

# Create Dockerfile
cat > Dockerfile << 'EOF'
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
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
EOF

# Create Dockerrun.aws.json
cat > Dockerrun.aws.json << 'EOF'
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

echo "⬇️ You need to upload your JAR file to this directory manually"
echo "Or use this command to create a dummy JAR for testing:"

# Create a dummy Spring Boot JAR for testing (remove this in production)
cat > HelloWorldApplication.java << 'EOF'
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@SpringBootApplication
@RestController
public class HelloWorldApplication {
    public static void main(String[] args) {
        SpringApplication.run(HelloWorldApplication.class, args);
    }
    
    @GetMapping("/actuator/health")
    public String health() {
        return "{\"status\":\"UP\"}";
    }
    
    @GetMapping("/")
    public String hello() {
        return "iTech Backend is Running!";
    }
}
EOF

echo "📝 Creating simple JAR for testing..."
# For now, we'll create a placeholder
echo "This would be your application.jar" > application.jar

# Create ZIP package for EB deployment
zip -r itech-backend-deployment.zip Dockerfile Dockerrun.aws.json application.jar

echo "✅ Deployment package created: itech-backend-deployment.zip"

# Initialize Elastic Beanstalk application
echo "🔧 Creating Elastic Beanstalk application..."

aws elasticbeanstalk create-application \
    --application-name itech-backend \
    --description "iTech B2B Marketplace Backend" \
    --region ap-south-1

# Create application version
echo "📋 Creating application version..."

# First, upload to S3
BUCKET_NAME="itech-eb-deployments-$(date +%s)"
aws s3 mb s3://$BUCKET_NAME --region ap-south-1

aws s3 cp itech-backend-deployment.zip s3://$BUCKET_NAME/itech-backend-v1.zip

aws elasticbeanstalk create-application-version \
    --application-name itech-backend \
    --version-label v1.0 \
    --source-bundle S3Bucket=$BUCKET_NAME,S3Key=itech-backend-v1.zip \
    --region ap-south-1

# Create environment
echo "🌍 Creating production environment..."

aws elasticbeanstalk create-environment \
    --application-name itech-backend \
    --environment-name itech-backend-prod \
    --version-label v1.0 \
    --platform-arn "arn:aws:elasticbeanstalk:ap-south-1::platform/Docker running on 64bit Amazon Linux 2/3.0.0" \
    --option-settings \
        Namespace=aws:autoscaling:launchconfiguration,OptionName=InstanceType,Value=t3.medium \
        Namespace=aws:elasticbeanstalk:application:environment,OptionName=SERVER_PORT,Value=8080 \
        Namespace=aws:elasticbeanstalk:application:environment,OptionName=SPRING_PROFILES_ACTIVE,Value=production \
    --region ap-south-1

echo "⏳ Environment creation started. This will take 5-10 minutes..."
echo "🌐 Check status with:"
echo "aws elasticbeanstalk describe-environments --application-name itech-backend --region ap-south-1"

echo "✅ Backend deployment initiated!"
