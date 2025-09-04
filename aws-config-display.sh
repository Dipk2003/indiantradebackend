#!/bin/bash

# AWS Configuration Display Script for CloudShell
# This will show the exact same details as "aws configure" command

echo "AWS Configuration Details"
echo "========================="
echo ""

# Method 1: Show configuration exactly like 'aws configure' command
echo "📋 AWS CONFIGURE OUTPUT:"
echo "------------------------"
echo "AWS Access Key ID [None]: $(aws configure get aws_access_key_id)"
echo "AWS Secret Access Key [None]: $(aws configure get aws_secret_access_key)"
echo "Default region name [None]: $(aws configure get region)"
echo "Default output format [None]: $(aws configure get output)"
echo ""

# Method 2: Complete configuration list
echo "📊 COMPLETE CONFIGURATION LIST:"
echo "-------------------------------"
aws configure list
echo ""

# Method 3: Account Identity & Details
echo "👤 ACCOUNT IDENTITY:"
echo "-------------------"
IDENTITY=$(aws sts get-caller-identity)
ACCOUNT_ID=$(echo $IDENTITY | jq -r '.Account')
USER_ARN=$(echo $IDENTITY | jq -r '.Arn')
USER_ID=$(echo $IDENTITY | jq -r '.UserId')

echo "Account ID: $ACCOUNT_ID"
echo "User ARN: $USER_ARN"
echo "User ID: $USER_ID"
echo ""

# Method 4: Region Information
echo "🌍 REGION INFORMATION:"
echo "---------------------"
CONFIGURED_REGION=$(aws configure get region)
CLOUDSHELL_REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region 2>/dev/null)
AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone 2>/dev/null)

echo "Configured Region: $CONFIGURED_REGION"
echo "CloudShell Region: $CLOUDSHELL_REGION"
echo "Availability Zone: $AZ"
echo ""

# Method 5: Credentials Source
echo "🔑 CREDENTIALS SOURCE:"
echo "---------------------"
echo "AWS_ACCESS_KEY_ID (env): ${AWS_ACCESS_KEY_ID:-'Not set'}"
echo "AWS_SECRET_ACCESS_KEY (env): ${AWS_SECRET_ACCESS_KEY:+'Set'}"
echo "AWS_DEFAULT_REGION (env): ${AWS_DEFAULT_REGION:-'Not set'}"
echo "AWS_PROFILE (env): ${AWS_PROFILE:-'default'}"
echo ""

# Method 6: File locations
echo "📁 CONFIGURATION FILES:"
echo "----------------------"
echo "Config file: ${AWS_CONFIG_FILE:-'~/.aws/config'}"
echo "Credentials file: ${AWS_SHARED_CREDENTIALS_FILE:-'~/.aws/credentials'}"
if [ -f ~/.aws/config ]; then
    echo "Config file exists: ✅"
else
    echo "Config file exists: ❌"
fi
if [ -f ~/.aws/credentials ]; then
    echo "Credentials file exists: ✅"
else
    echo "Credentials file exists: ❌"
fi
echo ""

# Method 7: Test Configuration
echo "🧪 CONFIGURATION TEST:"
echo "---------------------"
echo "Testing AWS credentials..."
if aws sts get-caller-identity > /dev/null 2>&1; then
    echo "✅ Credentials are valid and working"
    echo "✅ Successfully authenticated with AWS"
else
    echo "❌ Credentials test failed"
fi
echo ""

# Method 8: Service Access Summary
echo "🔐 SERVICE ACCESS SUMMARY:"
echo "-------------------------"
echo "Testing access to AWS services..."

# Test different services
SERVICES=("s3:ls" "ec2:describe-instances" "iam:get-user" "lambda:list-functions" "rds:describe-db-instances")
for service in "${SERVICES[@]}"; do
    SERVICE_NAME=$(echo $service | cut -d':' -f1)
    SERVICE_CMD=$(echo $service | cut -d':' -f2)
    
    case $SERVICE_NAME in
        "s3")
            if aws s3 ls > /dev/null 2>&1; then
                echo "✅ $SERVICE_NAME: Access available"
            else
                echo "❌ $SERVICE_NAME: No access"
            fi
            ;;
        "ec2")
            if aws ec2 describe-instances --max-items 1 > /dev/null 2>&1; then
                echo "✅ $SERVICE_NAME: Access available"
            else
                echo "❌ $SERVICE_NAME: No access"
            fi
            ;;
        "iam")
            if aws iam get-user > /dev/null 2>&1; then
                echo "✅ $SERVICE_NAME: Access available"
            else
                echo "❌ $SERVICE_NAME: No access"
            fi
            ;;
        "lambda")
            if aws lambda list-functions --max-items 1 > /dev/null 2>&1; then
                echo "✅ $SERVICE_NAME: Access available"
            else
                echo "❌ $SERVICE_NAME: No access"
            fi
            ;;
        "rds")
            if aws rds describe-db-instances --max-items 1 > /dev/null 2>&1; then
                echo "✅ $SERVICE_NAME: Access available"
            else
                echo "❌ $SERVICE_NAME: No access"
            fi
            ;;
    esac
done
echo ""

# Method 9: Summary in same format as your local
echo "📝 CONFIGURATION SUMMARY (Local Format):"
echo "========================================="
echo "AWS Access Key ID [None]: $(aws configure get aws_access_key_id)"
echo "AWS Secret Access Key [None]: $(aws configure get aws_secret_access_key | head -c 20)..."
echo "Default region name [None]: $(aws configure get region)"
echo "Default output format [None]: $(aws configure get output)"
echo ""

echo "✅ Configuration display completed!"
echo "💾 All your AWS configuration details are displayed above"
