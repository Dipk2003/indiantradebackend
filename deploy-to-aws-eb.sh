#!/bin/bash
# AWS Elastic Beanstalk Deployment Script for iTech Backend
# This script helps deploy your Spring Boot application to AWS Elastic Beanstalk

set -e  # Exit on any error

# Configuration
APP_NAME="itech-backend"
ENV_NAME="itech-backend-prod"
REGION="us-east-1"
PLATFORM="java-21-amazon-linux-2023"
JAR_FILE="target/itech-backend-0.0.1-SNAPSHOT.jar"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}===========================================${NC}"
echo -e "${GREEN}  AWS Elastic Beanstalk Deployment Script${NC}"
echo -e "${GREEN}===========================================${NC}"

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo -e "${RED}❌ AWS CLI is not installed. Please install it first.${NC}"
    echo "Installation: https://aws.amazon.com/cli/"
    exit 1
fi

# Check if EB CLI is installed
if ! command -v eb &> /dev/null; then
    echo -e "${RED}❌ EB CLI is not installed. Please install it first.${NC}"
    echo "Installation: pip install awsebcli"
    exit 1
fi

# Check if JAR file exists
if [ ! -f "$JAR_FILE" ]; then
    echo -e "${YELLOW}⚠️  JAR file not found. Building the application...${NC}"
    mvn clean package -DskipTests
    if [ ! -f "$JAR_FILE" ]; then
        echo -e "${RED}❌ Failed to build JAR file${NC}"
        exit 1
    fi
fi

# Get JAR file size for display
JAR_SIZE=$(du -h "$JAR_FILE" | cut -f1)
echo -e "${GREEN}✅ JAR file found: $JAR_FILE ($JAR_SIZE)${NC}"

# Check AWS credentials
echo -e "${YELLOW}🔍 Checking AWS credentials...${NC}"
if ! aws sts get-caller-identity &> /dev/null; then
    echo -e "${RED}❌ AWS credentials not configured. Please run 'aws configure'${NC}"
    exit 1
fi
echo -e "${GREEN}✅ AWS credentials configured${NC}"

# Initialize EB application if not exists
if [ ! -f ".elasticbeanstalk/config.yml" ]; then
    echo -e "${YELLOW}🔧 Initializing Elastic Beanstalk application...${NC}"
    eb init $APP_NAME --region $REGION --platform "$PLATFORM"
else
    echo -e "${GREEN}✅ Elastic Beanstalk already initialized${NC}"
fi

# Function to create environment
create_environment() {
    echo -e "${YELLOW}🚀 Creating Elastic Beanstalk environment: $ENV_NAME${NC}"
    eb create $ENV_NAME \
        --instance-type t3.medium \
        --min-instances 1 \
        --max-instances 4 \
        --envvars SPRING_PROFILES_ACTIVE=production \
        --timeout 30
}

# Function to deploy to existing environment
deploy_to_environment() {
    echo -e "${YELLOW}📦 Deploying to existing environment: $ENV_NAME${NC}"
    eb deploy $ENV_NAME --timeout 30
}

# Check if environment exists
if eb list | grep -q "$ENV_NAME"; then
    echo -e "${GREEN}✅ Environment $ENV_NAME exists${NC}"
    read -p "Do you want to deploy to existing environment? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        deploy_to_environment
    else
        echo -e "${YELLOW}Deployment cancelled by user${NC}"
        exit 0
    fi
else
    echo -e "${YELLOW}⚠️  Environment $ENV_NAME does not exist${NC}"
    read -p "Do you want to create a new environment? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        create_environment
    else
        echo -e "${YELLOW}Deployment cancelled by user${NC}"
        exit 0
    fi
fi

# Get environment status and URL
echo -e "${YELLOW}📊 Getting deployment status...${NC}"
eb status $ENV_NAME

# Get environment URL
ENV_URL=$(eb status $ENV_NAME | grep "CNAME" | awk '{print $2}')
if [ ! -z "$ENV_URL" ]; then
    echo -e "${GREEN}🌐 Application URL: http://$ENV_URL${NC}"
    echo -e "${GREEN}📋 Health Check: http://$ENV_URL/actuator/health${NC}"
else
    echo -e "${YELLOW}⚠️  Unable to retrieve environment URL${NC}"
fi

echo -e "${GREEN}===========================================${NC}"
echo -e "${GREEN}        Deployment Information${NC}"
echo -e "${GREEN}===========================================${NC}"
echo -e "Application: $APP_NAME"
echo -e "Environment: $ENV_NAME"
echo -e "Region: $REGION"
echo -e "Platform: $PLATFORM"
echo -e "JAR File: $JAR_FILE ($JAR_SIZE)"
echo -e "${GREEN}===========================================${NC}"

echo -e "${GREEN}🎉 Deployment process completed!${NC}"
echo -e "${YELLOW}📝 Next Steps:${NC}"
echo -e "1. Configure environment variables in EB Console"
echo -e "2. Set up RDS database connection"
echo -e "3. Configure domain and SSL certificate"
echo -e "4. Test the application endpoints"
echo ""
echo -e "${YELLOW}⚠️  Important:${NC}"
echo -e "- Update environment variables with actual values"
echo -e "- Configure RDS security groups"
echo -e "- Set up monitoring and alerts"
echo -e "- Review application logs if needed: eb logs"
